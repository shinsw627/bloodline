# Design Ref: §4.2 Pool API, §7 (Robustness — hard cap).
# Generic Object Pool: pre-warmed children of `scene`, acquire/release cycle.
# Pooled scene contract:
#   - on_acquire(args := {}): called when reused/created (do setup here)
#   - on_release(): called when returned to pool (reset transient state)
#   - request_release() on the node → forwards to Pool via signal `released`
class_name Pool
extends Node2D

@export var scene: PackedScene
@export var initial_size: int = 32
@export var max_size: int = 800

var _available: Array[Node] = []
var _in_use: Dictionary = {}    # node -> true (O(1) membership)

func _ready() -> void:
	assert(scene != null, "Pool: scene is null on %s" % name)
	for i in initial_size:
		var n := _instantiate_new()
		_deactivate(n)
		_available.append(n)

func _instantiate_new() -> Node:
	var n: Node = scene.instantiate()
	add_child(n)
	if n.has_signal("released"):
		n.released.connect(_on_node_released.bind(n))
	return n

func acquire(args: Dictionary = {}) -> Node:
	var node: Node
	if _available.is_empty():
		if _in_use.size() + _available.size() >= max_size:
			# Hard cap reached. Steal the oldest in-use to keep the game alive.
			push_warning("Pool '%s' hard cap (%d) reached — recycling oldest." % [name, max_size])
			node = _in_use.keys()[0]
			_force_release(node)
		else:
			node = _instantiate_new()
	else:
		node = _available.pop_back()
	_activate(node)
	_in_use[node] = true
	if node.has_method("on_acquire"):
		node.on_acquire(args)
	return node

func release(node: Node) -> void:
	if not _in_use.has(node):
		return
	_force_release(node)

func _force_release(node: Node) -> void:
	if node.has_method("on_release"):
		node.on_release()
	_deactivate(node)
	_in_use.erase(node)
	_available.append(node)

func _activate(node: Node) -> void:
	node.set_process(true)
	node.set_physics_process(true)
	if node is CanvasItem:
		(node as CanvasItem).visible = true
	if node is CollisionObject2D:
		(node as CollisionObject2D).set_deferred("monitoring", true)
		(node as CollisionObject2D).set_deferred("monitorable", true)

func _deactivate(node: Node) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	if node is CanvasItem:
		(node as CanvasItem).visible = false
	if node is CollisionObject2D:
		(node as CollisionObject2D).set_deferred("monitoring", false)
		(node as CollisionObject2D).set_deferred("monitorable", false)
	if node is Node2D:
		(node as Node2D).global_position = Vector2(-99999, -99999)

func _on_node_released(node: Node) -> void:
	release(node)

func active_count() -> int:
	return _in_use.size()

func get_active_nodes() -> Array:
	return _in_use.keys()
