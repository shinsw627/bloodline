# Design Ref: §5.1 MainMenu — entry point with full button set.
# All button handlers use group lookup directly (no signal-back-to-main dependency)
# to keep MainMenu functional even if Main._ready partially failed.
extends CanvasLayer

# Legacy signals (kept for backward compat if Main connects them; not required).
signal play_pressed
signal achievements_pressed
signal settings_pressed

@onready var _play_button: Button = $Center/Panel/Margin/Layout/Buttons/PlayButton
@onready var _achievements_button: Button = $Center/Panel/Margin/Layout/Buttons/AchievementsButton
@onready var _meta_button: Button = $Center/Panel/Margin/Layout/Buttons/MetaButton
@onready var _settings_button: Button = $Center/Panel/Margin/Layout/Buttons/SettingsButton
@onready var _quit_button: Button = $Center/Panel/Margin/Layout/Buttons/QuitButton
@onready var _version_label: Label = $VersionLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_play_button.pressed.connect(_on_play)
	_achievements_button.pressed.connect(_on_achievements)
	_meta_button.pressed.connect(_on_meta)
	_settings_button.pressed.connect(_on_settings)
	_quit_button.pressed.connect(_on_quit)
	_version_label.text = "v0.5 — M5"

func _on_play() -> void:
	# Emit signal for any external listener AND directly invoke main.
	play_pressed.emit()
	var main_node := get_tree().get_first_node_in_group(&"main")
	if main_node and main_node.has_method("_enter_character_select"):
		main_node._enter_character_select()

func _on_achievements() -> void:
	achievements_pressed.emit()
	var panel := get_tree().get_first_node_in_group(&"achievement_panel")
	if panel and panel.has_method("open"):
		panel.open()

func _on_meta() -> void:
	var shop := get_tree().get_first_node_in_group(&"meta_shop")
	var main_node := get_tree().get_first_node_in_group(&"main")
	if shop and main_node and main_node.has_method("get_meta_upgrades"):
		shop.open(main_node.get_meta_upgrades())

func _on_settings() -> void:
	settings_pressed.emit()
	var settings := get_tree().get_first_node_in_group(&"settings_ui")
	if settings and settings.has_method("open"):
		settings.open()

func _on_quit() -> void:
	get_tree().quit()
