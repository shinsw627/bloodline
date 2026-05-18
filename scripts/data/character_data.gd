# Design Ref: §3.1 — CharacterData Resource.
# starting_weapon: 시작 무기 (must be in UpgradeRegistry for level-ups).
# base_stat_overrides: optional per-character base stat tweaks (additive %).
class_name CharacterData
extends Resource

@export var id: StringName = &"default"
@export var display_name: String = "Vagabond"
@export var color: Color = Color(0.8, 0.3, 0.3)
@export var description: String = "Balanced fighter."
@export var starting_weapon: WeaponData
# Overrides (additive %): {max_hp: 0.1, move_speed: -0.05, ...}
@export var base_stat_overrides: Dictionary = {}
