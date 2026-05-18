# Design Ref: §5.4 GameOverScreen Page UI Checklist.
# Shown on EventBus.run_ended. Retry → reload current scene. Quit → quit (M1: 메인메뉴는 M3).
extends CanvasLayer

@onready var _stats_label: Label = $Center/Panel/Margin/Layout/StatsLabel
@onready var _retry_button: Button = $Center/Panel/Margin/Layout/Buttons/RetryButton
@onready var _quit_button: Button = $Center/Panel/Margin/Layout/Buttons/QuitButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS  # work while tree is paused
	EventBus.run_ended.connect(_on_run_ended)
	_retry_button.pressed.connect(_on_retry)
	_quit_button.pressed.connect(_on_quit)

func _on_run_ended(result: Dictionary) -> void:
	var t: float = result.get("survived_sec", 0.0)
	var k: int = result.get("kills", 0)
	var lv: int = result.get("level", 1)
	_stats_label.text = "Survived: %02d:%02d\nKills: %d\nLevel: %d" % [int(t) / 60, int(t) % 60, k, lv]
	show()
	get_tree().paused = true

func _on_retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit() -> void:
	get_tree().quit()
