# Design Ref: §5.1 Screen Map — placeholder entry point for M1.
# Will be replaced by MainMenu → CharacterSelect → MapSelect chain in M3.
extends Node2D

func _ready() -> void:
	GameState.reset_run()
	print("[bloodline] M1 bootstrap — run started. Press WASD/arrows/left-stick to move.")
	EventBus.run_started.emit(null, null)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_tree().paused = not get_tree().paused
