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
	var evolutions: Array = []   # Always prioritized when available
	var pool: Array = []
	var slot_open: bool = holder.slot_count() < WeaponHolder.MAX_SLOTS
	# Weapons + evolution checks
	for w in weapons:
		var lv: int = holder.get_weapon_level(w.id)
		if lv == 0 and slot_open:
			pool.append({"type": "weapon", "data": w, "current_level": 0, "next_level": 1, "is_new": true})
		elif lv > 0 and lv < w.max_level:
			pool.append({"type": "weapon", "data": w, "current_level": lv, "next_level": lv + 1, "is_new": false})
		elif lv > 0 and lv >= w.max_level and w.evolution_target != null:
			# Evolution eligibility: max-level weapon + required passive owned
			if w.evolution_required_passive == null:
				continue
			var passive_id: StringName = (w.evolution_required_passive as PassiveData).id
			if stats != null and stats.get_passive_level(passive_id) >= 1:
				evolutions.append({
					"type": "evolution",
					"data": w.evolution_target,
					"source_weapon": w,
					"current_level": 0,
					"next_level": 1,
					"is_new": true,
				})
	# Passives
	for p in passives:
		var lv := stats.get_passive_level(p.id) if stats else 0
		if lv < p.max_level:
			pool.append({"type": "passive", "data": p, "current_level": lv, "next_level": lv + 1, "is_new": lv == 0})
	# Prioritize evolutions: fill from evolutions first, then random pool.
	if not evolutions.is_empty():
		evolutions.shuffle()
		var result: Array = evolutions.slice(0, min(count, evolutions.size()))
		var remaining := count - result.size()
		if remaining > 0:
			pool.shuffle()
			result.append_array(pool.slice(0, min(remaining, pool.size())))
		return result
	pool.shuffle()
	if pool.size() <= count:
		return pool
	return pool.slice(0, count)
