# Design Ref: §2.3, §3.1 — Registry of all available weapons/passives.
# Used by LevelUpUI to draw 3 eligible upgrade cards on level_up.
# main.gd registers content at run start (Plan FR-06: data-driven content).
extends Node

var weapons: Array[WeaponData] = []
var passives: Array[PassiveData] = []

func clear() -> void:
	weapons.clear()
	passives.clear()

func register_weapon(w: WeaponData) -> void:
	if w == null:
		return
	for existing in weapons:
		if existing.id == w.id:
			return
	weapons.append(w)

func register_passive(p: PassiveData) -> void:
	if p == null:
		return
	for existing in passives:
		if existing.id == p.id:
			return
	passives.append(p)

# Returns up to `count` upgrade option dictionaries:
#   {type: "weapon"|"passive", data: Resource, current_level: int, next_level: int, is_new: bool}
# Eligibility:
#   - Weapon: existing slot below max_level, OR slot available + not yet owned
#   - Passive: not at max_level
func draw_cards(holder: WeaponHolder, stats: StatsComponent, count: int = 3) -> Array:
	var pool: Array = []
	var slot_open: bool = holder.slot_count() < WeaponHolder.MAX_SLOTS
	# Weapons
	for w in weapons:
		var lv: int = holder.get_weapon_level(w.id)
		if lv == 0 and slot_open:
			pool.append({"type": "weapon", "data": w, "current_level": 0, "next_level": 1, "is_new": true})
		elif lv > 0 and lv < w.max_level:
			pool.append({"type": "weapon", "data": w, "current_level": lv, "next_level": lv + 1, "is_new": false})
	# Passives
	for p in passives:
		var lv := stats.get_passive_level(p.id) if stats else 0
		if lv < p.max_level:
			pool.append({"type": "passive", "data": p, "current_level": lv, "next_level": lv + 1, "is_new": lv == 0})
	pool.shuffle()
	if pool.size() <= count:
		return pool
	return pool.slice(0, count)
