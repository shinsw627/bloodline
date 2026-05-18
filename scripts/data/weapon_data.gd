# Design Ref: §3.1 — Custom Resource for weapon definition.
# level_curve: per-level additive modifiers, e.g. {damage: 5, cooldown: -0.1, count: 1}
# evolution_target/evolution_required_passive: M4 evolution feature, optional in M1/M2.
class_name WeaponData
extends Resource

@export var id: StringName = &"whip"
@export var display_name: String = "Whip"
@export var icon: Texture2D
@export var description: String = "Strikes in front of the player."
@export var max_level: int = 8
@export var projectile_scene: PackedScene
@export var base_damage: float = 10.0
@export var base_cooldown: float = 1.0          # seconds between fires
@export var base_projectile_count: int = 1
@export var base_pierce: int = 0
@export var base_speed: float = 400.0
@export var base_lifetime: float = 0.6
@export var base_area_scale: float = 1.0
@export var projectile_color: Color = Color(1, 0.85, 0.2, 1)   # visual differentiation per weapon
@export var level_curve: Array = []  # per level deltas: [{damage:+5, cooldown:-0.1}, ...]
@export var evolution_target: Resource = null    # WeaponData (avoid circular ref)
@export var evolution_required_passive: Resource = null  # PassiveData (M4)

# Aggregate stats up to a given level (1-indexed).
func stats_at_level(level: int, stats_mult: Dictionary = {}) -> Dictionary:
	var d := {
		"damage": base_damage,
		"cooldown": base_cooldown,
		"count": base_projectile_count,
		"pierce": base_pierce,
		"speed": base_speed,
		"lifetime": base_lifetime,
		"area_scale": base_area_scale,
	}
	for i in min(level - 1, level_curve.size()):
		var delta: Dictionary = level_curve[i]
		for key in delta:
			if d.has(key):
				d[key] += delta[key]
	# Apply player stats modifiers (damage_mult, cooldown_mult)
	d.damage *= stats_mult.get("damage_mult", 1.0)
	d.cooldown *= stats_mult.get("cooldown_mult", 1.0)
	return d
