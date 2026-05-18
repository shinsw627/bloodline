# Design Ref: §3.1 PassiveData Custom Resource.
# Each level applies a stat modifier via StatsComponent.apply_modifier(stat, value).
# stat_mods is an Array of {stat: StringName, value: float} per level (1-indexed via array order).
class_name PassiveData
extends Resource

@export var id: StringName = &"max_hp_up"
@export var display_name: String = "Vitality"
@export var icon: Texture2D
@export var color: Color = Color(0.9, 0.5, 0.5)        # used as icon placeholder
@export var description: String = ""
@export var max_level: int = 5
# Per-level deltas applied additively to StatsComponent.
# e.g. [{stat: "max_hp", value: 0.20}, {stat: "max_hp", value: 0.20}, ...]
@export var stat_mods: Array = []

func mod_at_level(level: int) -> Dictionary:
	# Returns the modifier dict to apply when reaching `level` (level 1 = first entry).
	if level - 1 < 0 or level - 1 >= stat_mods.size():
		return {}
	return stat_mods[level - 1]
