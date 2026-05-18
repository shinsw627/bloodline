# Design Ref: §2.2 Data Flow.
# Behaviors:
#   "linear" — moves along direction (default, M1)
#   "orbit"  — orbits target at orbit_radius, orbit_speed rad/s (M4 Bible / King Bible-like)
#   "aura"   — follows target, periodic damage tick to overlapping enemies (M4 Garlic)
extends Area2D

signal released

var behavior: StringName = &"linear"
var damage: float = 10.0
var pierce: int = 0
var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 0.6

# orbit/aura state
var target: Node2D = null
var orbit_radius: float = 90.0
var orbit_speed: float = 4.0     # rad/sec
var orbit_angle: float = 0.0
var aura_tick_interval: float = 0.4
var _aura_tick: float = 0.0

var _age: float = 0.0
var _remaining_pierce: int = 0
var _hit_set: Dictionary = {}

@onready var _visual: ColorRect = $Visual

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func on_acquire(args: Dictionary) -> void:
	behavior = args.get("behavior", &"linear")
	damage = args.get("damage", 10.0)
	pierce = args.get("pierce", 0)
	speed = args.get("speed", 400.0)
	direction = args.get("direction", Vector2.RIGHT).normalized()
	lifetime = args.get("lifetime", 0.6)
	target = args.get("target", null)
	orbit_radius = args.get("orbit_radius", 90.0)
	orbit_speed = args.get("orbit_speed", 4.0)
	orbit_angle = args.get("orbit_start_angle", 0.0)
	aura_tick_interval = args.get("aura_tick_interval", 0.4)
	var pos: Vector2 = args.get("position", Vector2.ZERO)
	var scl: float = args.get("scale", 1.0)
	global_position = pos
	rotation = direction.angle() if behavior == &"linear" else 0.0
	scale = Vector2(scl, scl)
	if _visual:
		_visual.color = args.get("color", Color(1, 0.85, 0.2, 1))
	_age = 0.0
	_aura_tick = 0.0
	_remaining_pierce = pierce
	_hit_set.clear()

func on_release() -> void:
	_hit_set.clear()
	target = null

func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		released.emit()
		return
	match behavior:
		&"linear":
			global_position += direction * speed * delta
		&"orbit":
			if target != null and is_instance_valid(target):
				orbit_angle += orbit_speed * delta
				global_position = target.global_position + Vector2.RIGHT.rotated(orbit_angle) * orbit_radius
				rotation = orbit_angle + PI * 0.5
		&"aura":
			if target != null and is_instance_valid(target):
				global_position = target.global_position
			_aura_tick -= delta
			if _aura_tick <= 0.0:
				_aura_tick = aura_tick_interval
				_tick_aura_damage()

func _tick_aura_damage() -> void:
	for area in get_overlapping_areas():
		if area.is_in_group(&"enemy") and area.has_method("take_damage"):
			area.take_damage(damage, self)

func _on_area_entered(area: Area2D) -> void:
	if behavior == &"aura":
		return  # aura uses periodic tick
	if not area.is_in_group(&"enemy"):
		return
	if _hit_set.has(area):
		return
	_hit_set[area] = true
	if area.has_method("take_damage"):
		area.take_damage(damage, self)
	if behavior == &"orbit":
		return  # orbit projectiles persist; pierce/lifetime decide
	if _remaining_pierce <= 0:
		released.emit()
	else:
		_remaining_pierce -= 1
