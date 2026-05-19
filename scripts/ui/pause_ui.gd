# Design Ref: §5.2 PauseMenu — Plan FR-17.
# Subscribes to pause action via Main's _unhandled_input; toggled via show()/hide().
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
	_resume_button.pressed.connect(func(): resume_pressed.emit())
	_settings_button.pressed.connect(func(): settings_pressed.emit())
	_menu_button.pressed.connect(func(): main_menu_pressed.emit())
