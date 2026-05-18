# Design Ref: §2.3 — Single Source of Truth for the active run (in-memory).
# Persistent meta-progress lives in SaveManager (M3). This holds only current-run data.
extends Node

var run_time: float = 0.0
var elapsed_minutes: int = 0
var kills: int = 0
var current_level: int = 1
var current_exp: int = 0
var gold_this_run: int = 0
var is_running: bool = false

func reset_run() -> void:
	run_time = 0.0
	elapsed_minutes = 0
	kills = 0
	current_level = 1
	current_exp = 0
	gold_this_run = 0
	is_running = true

func _process(delta: float) -> void:
	if not is_running:
		return
	run_time += delta
	var new_minutes := int(run_time / 60.0)
	if new_minutes > elapsed_minutes:
		elapsed_minutes = new_minutes
		EventBus.minute_passed.emit(elapsed_minutes)

func end_run(cause: String) -> void:
	is_running = false
	var result := {
		"survived_sec": run_time,
		"kills": kills,
		"level": current_level,
		"cause": cause,
	}
	EventBus.run_ended.emit(result)
