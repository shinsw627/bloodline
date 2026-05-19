# Design Ref: §5.2 PauseMenu — Plan FR-17.
# Self-contained: Resume/Settings/MainMenu all handled internally via direct calls
# (no dependency on Main script's signal wiring).
extends CanvasLayer

signal resume_pressed
signal settings_pressed
signal main_menu_pressed

@onready var _resume_button: Button = $Center/Panel/Margin/Layout/Buttons/ResumeButton
@onready var _settings_button: Button = $Center/Panel/Margin/Layout/Buttons/SettingsButton
@onready var _menu_button: Button = $Center/Panel/Margin/Layout/Buttons/MenuButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume_button.pressed.connect(_on_resume)
	_settings_button.pressed.connect(_on_settings)
	_menu_button.pressed.connect(_on_main_menu)

func _on_resume() -> void:
	resume_pressed.emit()
	visible = false
	get_tree().paused = false

func _on_settings() -> void:
	settings_pressed.emit()
	var settings := get_tree().get_first_node_in_group(&"settings_ui")
	if settings and settings.has_method("open"):
		settings.open()

func _on_main_menu() -> void:
	main_menu_pressed.emit()
	visible = false
	GameState.clear_selection()
	get_tree().paused = false
	get_tree().reload_current_scene()
