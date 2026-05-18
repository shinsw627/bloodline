# Design Ref: §8.2 L1 #7 — Pool acquire/release size stability.
# Uses a minimal dummy scene to avoid coupling to real Enemy/Projectile.
extends GutTest

const _DUMMY_SCRIPT_SOURCE := """extends Node2D
signal released
var acquire_count := 0
var release_count := 0
func on_acquire(_args: Dictionary) -> void:
	acquire_count += 1
func on_release() -> void:
	release_count += 1
"""

var _dummy_scene: PackedScene

func before_all() -> void:
	# Build a PackedScene at runtime so tests don't depend on a saved .tscn file.
	var script := GDScript.new()
	script.source_code = _DUMMY_SCRIPT_SOURCE
	script.reload()
	var node := Node2D.new()
	node.set_script(script)
	# `released` signal is now defined via script; pack
	_dummy_scene = PackedScene.new()
	_dummy_scene.pack(node)
	node.free()

func _make_pool(initial: int = 4, max_n: int = 16) -> Pool:
	var p := Pool.new()
	p.scene = _dummy_scene
	p.initial_size = initial
	p.max_size = max_n
	add_child_autofree(p)
	# Pool._ready runs on add; wait one frame for deferred ops if any
	return p

func test_pool_prewarms_initial_size() -> void:
	var p := _make_pool(4)
	assert_eq(p.get_child_count(), 4, "Pool prewarms initial_size children")
	assert_eq(p.active_count(), 0, "Nothing in use after prewarm")

func test_acquire_returns_inactive_node_first() -> void:
	var p := _make_pool(2)
	var n := p.acquire({})
	assert_not_null(n)
	assert_eq(p.active_count(), 1, "1 node in use")
	assert_eq(p.get_child_count(), 2, "No new instantiation needed")

func test_release_returns_to_pool() -> void:
	var p := _make_pool(2)
	var n := p.acquire({})
	p.release(n)
	assert_eq(p.active_count(), 0, "Released node leaves in-use set")
	# Re-acquire should reuse the same node
	var n2 := p.acquire({})
	assert_eq(p.active_count(), 1)
	assert_eq(p.get_child_count(), 2, "No new node instantiated on reuse")

func test_acquire_beyond_initial_instantiates_new() -> void:
	var p := _make_pool(2, 8)
	p.acquire({}); p.acquire({})
	var n3 := p.acquire({})
	assert_not_null(n3, "3rd acquire instantiates new child")
	assert_eq(p.get_child_count(), 3)

func test_hard_cap_recycles_oldest() -> void:
	var p := _make_pool(2, 2)
	var first := p.acquire({})
	var second := p.acquire({})
	# At cap. Next acquire should recycle the oldest in-use.
	var third := p.acquire({})
	assert_not_null(third, "Hard cap acquire returns recycled node, not null")
	# The first one should have been forced-released and re-activated
	assert_eq(p.active_count(), 2, "In-use stays at cap")

func test_signal_released_auto_returns_to_pool() -> void:
	var p := _make_pool(1)
	var n := p.acquire({})
	n.released.emit()
	assert_eq(p.active_count(), 0, "released signal triggers release()")
