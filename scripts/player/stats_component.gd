# Design Ref: §2.3, §3 — Player stats container. Passive modifiers stack here (M2+).
# Single component holds base stats + applied modifiers, exposes computed getters.
# Plan SC: FR-04 (pickup radius for EXP magnet)
class_name StatsComponent
extends Node

signal hp_changed(current: float, max_hp: float)

# === Base stats (configurable per CharacterData in M3) ===
@export var base_max_hp: float = 100.0
@export var base_move_speed: float = 200.0     # px/sec
@export var base_pickup_radius: float = 40.0   # px
@export var base_damage_mult: float = 1.0
@export var base_cooldown_mult: float = 1.0

# === Modifiers (additive, applied as percentage) ===
var max_hp_mod: float = 0.0
var move_speed_mod: float = 0.0
var pickup_radius_mod: float = 0.0
var damage_mod: float = 0.0
var cooldown_mod: float = 0.0

# === Live state ===
var current_hp: float

# Tracks passive levels by PassiveData id. Used by UpgradeRegistry to determine eligibility.
var passive_levels: Dictionary = {}     # StringName -> int

func _ready() -> void:
	current_hp = max_hp
	# Emit initial state on next frame so listeners (HUD) are connected.
	call_deferred("_emit_initial")

func _emit_initial() -> void:
	hp_changed.emit(current_hp, max_hp)
	EventBus.player_health_changed.emit(current_hp, max_hp)

# === Computed getters ===
var max_hp: float:
	get: return base_max_hp * (1.0 + max_hp_mod)

var move_speed: float:
	get: return base_move_speed * (1.0 + move_speed_mod)

var pickup_radius: float:
	get: return base_pickup_radius * (1.0 + pickup_radius_mod)

var damage_mult: float:
	get: return base_damage_mult * (1.0 + damage_mod)

var cooldown_mult: float:
	get: return base_cooldown_mult * (1.0 - cooldown_mod)   # cooldown reduction

# === Mutations ===
func take_damage(amount: float) -> void:
	if amount <= 0.0 or current_hp <= 0.0:
		return
	current_hp = max(0.0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	EventBus.player_health_changed.emit(current_hp, max_hp)
	if current_hp <= 0.0:
		EventBus.player_died.emit()

func heal(amount: float) -> void:
	if amount <= 0.0:
		return
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(current_hp, max_hp)
	EventBus.player_health_changed.emit(current_hp, max_hp)

func apply_modifier(stat: StringName, value: float) -> void:
	# Design Ref: §11.2 M2 — passive system uses this entry point.
	var old_max := max_hp
	match stat:
		&"max_hp":         max_hp_mod += value
		&"move_speed":     move_speed_mod += value
		&"pickup_radius":  pickup_radius_mod += value
		&"damage":         damage_mod += value
		&"cooldown":       cooldown_mod += value
		_:
			push_warning("StatsComponent: unknown stat '%s'" % stat)
			return
	# When max_hp grows, scale current_hp proportionally (don't let player heal to full free).
	if stat == &"max_hp" and old_max > 0.0:
		current_hp = min(current_hp + (max_hp - old_max), max_hp)
		hp_changed.emit(current_hp, max_hp)
		EventBus.player_health_changed.emit(current_hp, max_hp)

func apply_passive(passive: PassiveData) -> void:
	# Apply the next-level modifier and bump the recorded level.
	var current_level: int = passive_levels.get(passive.id, 0)
	if current_level >= passive.max_level:
		return
	var next_level := current_level + 1
	var mod: Dictionary = passive.mod_at_level(next_level)
	if mod.has("stat") and mod.has("value"):
		apply_modifier(StringName(mod.stat), float(mod.value))
	passive_levels[passive.id] = next_level

func get_passive_level(id: StringName) -> int:
	return passive_levels.get(id, 0)
