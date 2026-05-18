# Design Ref: §2.3 — Player composes StatsComponent + (later) WeaponHolder.
# Movement: InputMap actions only (no raw keys) → v2.0 mobile port maps touch to same actions.
# Plan SC: FR-01 8-directional movement via keyboard/gamepad.
class_name Player
extends CharacterBody2D

@onready var stats: StatsComponent = $Stats

func _ready() -> void:
	add_to_group(&"player")
	stats.hp_changed.connect(_on_hp_changed)

func _physics_process(_delta: float) -> void:
	var input_vec := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = input_vec * stats.move_speed
	move_and_slide()

func _on_hp_changed(current: float, _max_hp: float) -> void:
	if current <= 0.0:
		# Hand off to GameState; actual death flow finalizes in m1-exp module.
		GameState.end_run("player_died")
