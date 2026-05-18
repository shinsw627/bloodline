# Design Ref: §2.2 Data Flow — projectile from pool → travel → hit → enemy_damaged signal.
# Lifecycle: on_acquire(args) → physics → hit → release back to pool (auto on lifetime/pierce out).
extends Area2D

signal released

var damage: float = 10.0
var pierce: int = 0
var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 0.6

var _age: float = 0.0
var _remaining_pierce: int = 0
var _hit_set: Dictionary = {}   # enemy -> true, avoid double-hit on same enemy

@onready var _visual: ColorRect = $Visual

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func on_acquire(args: Dictionary) -> void:
	damage = args.get("damage", 10.0)
	pierce = args.get("pierce", 0)
	speed = args.get("speed", 400.0)
	direction = args.get("direction", Vector2.RIGHT).normalized()
	lifetime = args.get("lifetime", 0.6)
	var pos: Vector2 = args.get("position", Vector2.ZERO)
	var scl: float = args.get("scale", 1.0)
	global_position = pos
	rotation = direction.angle()
	scale = Vector2(scl, scl)
	if _visual:
		_visual.color = args.get("color", Color(1, 0.85, 0.2, 1))
	_age = 0.0
	_remaining_pierce = pierce
	_hit_set.clear()

func on_release() -> void:
	_hit_set.clear()

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		released.emit()
		return
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group(&"enemy"):
		return
	if _hit_set.has(area):
		return
	_hit_set[area] = true
	if area.has_method("take_damage"):
		area.take_damage(damage, self)
	if _remaining_pierce <= 0:
		released.emit()
	else:
		_remaining_pierce -= 1
