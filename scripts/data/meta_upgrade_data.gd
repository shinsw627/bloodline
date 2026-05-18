# Design Ref: §3.1, §11.2 M3 — meta progression definition.
# Effect types:
#   "stat_mod" → applied at run start via StatsComponent.apply_modifier(effect_stat, value * level)
# (M4 will add "starting_weapon" / "starting_passive" effects.)
class_name MetaUpgradeData
extends Resource

@export var id: StringName = &"start_hp_up"
@export var display_name: String = "Vitality Training"
@export var description: String = ""
@export var color: Color = Color(0.9, 0.5, 0.5)
@export var max_level: int = 5
@export var cost_per_level: Array = [10, 20, 30, 50, 80]
@export var effect_type: StringName = &"stat_mod"
@export var effect_stat: StringName = &"max_hp"
@export var effect_value: float = 0.10            # per level (additive %)

func cost_for_next_level(current_level: int) -> int:
	if current_level >= max_level:
		return -1
	if current_level >= cost_per_level.size():
		return cost_per_level[cost_per_level.size() - 1]
	return int(cost_per_level[current_level])
