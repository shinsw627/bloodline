# Design Ref: §2.2 Data Flow — drop from enemy_died → magnet within pickup_radius → exp_collected.
# Pooled Area2D. on_acquire(position, amount, target). on_release resets state.
extends Area2D

signal released

const ATTRACT_BASE_SPEED := 300.0
const ATTRACT_ACCEL := 1200.0

var amount: int = 1
var _target: Node2D = null
var _stats: StatsComponent = null
var _attracting: bool = false
var _speed: float = ATTRACT_BASE_SPEED

func _ready() -> void:
	add_to_group(&"exp_gem")
	body_entered.connect(_on_body_entered)

func on_acquire(args: Dictionary) -> void:
	amount = args.get("amount", 1)
	global_position = args.get("position", Vector2.ZERO)
	_target = args.get("target", null)
	if _target and _target.has_node("Stats"):
		_stats = _target.get_node("Stats") as StatsComponent
	_attracting = false
	_speed = ATTRACT_BASE_SPEED

func on_release() -> void:
	_attracting = false
	_target = null
	_stats = null

func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var to_target: Vector2 = _target.global_position - global_position
	var dist := to_target.length()
	if not _attracting:
		var radius := _stats.pickup_radius if _stats else 40.0
		if dist <= radius:
			_attracting = true
	if _attracting:
		_speed += ATTRACT_ACCEL * delta
		global_position += to_target.normalized() * _speed * delta

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(&"player"):
		return
	GameState.add_exp(amount)
	released.emit()
