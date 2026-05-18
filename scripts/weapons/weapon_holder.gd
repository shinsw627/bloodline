# Design Ref: §2.3, §3.1 (WeaponData), §11.2 M1/M2.
# Owns equipped weapons + their levels, ticks cooldowns, fires when ready.
# M2: LevelUpUI adds via add_weapon() / level_up_weapon(); M4: evolution.
class_name WeaponHolder
extends Node2D

const MAX_SLOTS := 6  # Plan FR-06 / Design §5.4 HUD slot count

var _projectile_pool: Pool
var _slots: Array[Dictionary] = []     # [{data: WeaponData, level: int, cooldown: float}]
var _stats: StatsComponent

func _ready() -> void:
	_projectile_pool = get_tree().get_first_node_in_group(&"projectile_pool") as Pool
	# Player parent has Stats sibling
	var parent := get_parent()
	if parent and parent.has_node("Stats"):
		_stats = parent.get_node("Stats") as StatsComponent

func add_weapon(data: WeaponData) -> bool:
	if has_weapon(data.id):
		return false
	if _slots.size() >= MAX_SLOTS:
		push_warning("WeaponHolder: max slots (%d) reached, cannot add %s" % [MAX_SLOTS, data.id])
		return false
	_slots.append({"data": data, "level": 1, "cooldown": 0.0})
	return true

func level_up_weapon(weapon_id: StringName) -> bool:
	for slot in _slots:
		var d: WeaponData = slot.data
		if d.id == weapon_id and slot.level < d.max_level:
			slot.level += 1
			return true
	return false

func remove_weapon(weapon_id: StringName) -> bool:
	for i in range(_slots.size() - 1, -1, -1):
		if (_slots[i].data as WeaponData).id == weapon_id:
			_slots.remove_at(i)
			return true
	return false

func clear_weapons() -> void:
	_slots.clear()

func has_weapon(weapon_id: StringName) -> bool:
	for slot in _slots:
		if (slot.data as WeaponData).id == weapon_id:
			return true
	return false

func get_weapon_level(weapon_id: StringName) -> int:
	for slot in _slots:
		if (slot.data as WeaponData).id == weapon_id:
			return slot.level
	return 0

func get_slots() -> Array:
	return _slots.duplicate()

func slot_count() -> int:
	return _slots.size()

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
	var owner_node := get_parent()    # Player (target for orbit/aura)
	for i in count:
		_spawn_projectile(data, s, origin, owner_node, i, count)

func _spawn_projectile(data: WeaponData, s: Dictionary, origin: Vector2, owner_node: Node, i: int, count: int) -> void:
	var args := {
		"behavior": data.behavior,
		"damage": s.damage,
		"pierce": s.pierce,
		"speed": s.speed,
		"lifetime": s.lifetime,
		"position": origin,
		"scale": s.area_scale,
		"color": data.projectile_color,
		"target": owner_node,
		"orbit_radius": data.orbit_radius,
		"orbit_speed": data.orbit_speed,
		"aura_tick_interval": data.aura_tick_interval,
	}
	match data.behavior:
		&"linear":
			var dir := _aim_direction(origin)
			var spread_angle := 0.0
			if count > 1:
				var spread := deg_to_rad(15.0)
				spread_angle = lerp(-spread, spread, float(i) / float(count - 1))
			args["direction"] = dir.rotated(spread_angle)
		&"orbit":
			args["orbit_start_angle"] = TAU * float(i) / float(count)
		&"aura":
			args["direction"] = Vector2.RIGHT
	_projectile_pool.acquire(args)

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
