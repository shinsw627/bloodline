# Design Ref: §2.3, §3.1 (WeaponData), §11.2 M1.
# Owns equipped weapons + their levels, ticks cooldowns, fires when ready.
# M2: LevelUpUI adds via add_weapon() / level_up_weapon(); M4: evolution.
class_name WeaponHolder
extends Node2D

var _projectile_pool: Pool
var _slots: Array[Dictionary] = []     # [{data: WeaponData, level: int, cooldown: float}]
var _stats: StatsComponent

func _ready() -> void:
	_projectile_pool = get_tree().get_first_node_in_group(&"projectile_pool") as Pool
	# Player parent has Stats sibling
	var parent := get_parent()
	if parent and parent.has_node("Stats"):
		_stats = parent.get_node("Stats") as StatsComponent

func add_weapon(data: WeaponData) -> void:
	assert(data != null)
	_slots.append({"data": data, "level": 1, "cooldown": 0.0})

func level_up_weapon(weapon_id: StringName) -> void:
	for slot in _slots:
		var d: WeaponData = slot.data
		if d.id == weapon_id and slot.level < d.max_level:
			slot.level += 1
			return

func _physics_process(delta: float) -> void:
	if _projectile_pool == null or _slots.is_empty():
		return
	for slot in _slots:
		slot.cooldown -= delta
		if slot.cooldown <= 0.0:
			_fire(slot)

func _fire(slot: Dictionary) -> void:
	var data: WeaponData = slot.data
	var stats_mult := {"damage_mult": 1.0, "cooldown_mult": 1.0}
	if _stats:
		stats_mult.damage_mult = _stats.damage_mult
		stats_mult.cooldown_mult = _stats.cooldown_mult
	var s: Dictionary = data.stats_at_level(slot.level, stats_mult)
	slot.cooldown += s.cooldown
	var count: int = s.count
	var origin: Vector2 = global_position
	# Direction: nearest enemy or fallback to facing-right
	var dir := _aim_direction(origin)
	for i in count:
		# Slight spread across multiple projectiles
		var spread_angle := 0.0
		if count > 1:
			var spread := deg_to_rad(10.0)
			spread_angle = lerp(-spread, spread, float(i) / float(count - 1))
		var d2 := dir.rotated(spread_angle)
		var p := _projectile_pool.acquire({
			"damage": s.damage,
			"pierce": s.pierce,
			"speed": s.speed,
			"direction": d2,
			"lifetime": s.lifetime,
			"position": origin,
			"scale": s.area_scale,
		})
		if p == null:
			return  # pool exhausted, skip

func _aim_direction(origin: Vector2) -> Vector2:
	var nearest: Node2D = null
	var best_d2 := INF
	for e in get_tree().get_nodes_in_group(&"enemy"):
		if not is_instance_valid(e):
			continue
		var d2: float = (e.global_position - origin).length_squared()
		if d2 < best_d2:
			best_d2 = d2
			nearest = e
	if nearest:
		return (nearest.global_position - origin).normalized()
	return Vector2.RIGHT
