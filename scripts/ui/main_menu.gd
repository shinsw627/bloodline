# Design Ref: §5.1 MainMenu — entry point with full button set.
extends CanvasLayer

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
	_play_button.pressed.connect(func(): play_pressed.emit())
	_achievements_button.pressed.connect(func(): achievements_pressed.emit())
	_meta_button.pressed.connect(_on_meta)
	_settings_button.pressed.connect(func(): settings_pressed.emit())
	_quit_button.pressed.connect(func(): get_tree().quit())
	_version_label.text = "v0.5 — M5"

func _on_meta() -> void:
	var shop := get_tree().get_first_node_in_group(&"meta_shop")
	var main_node := get_tree().get_first_node_in_group(&"main")
	if shop and main_node and main_node.has_method("get_meta_upgrades"):
		shop.open(main_node.get_meta_upgrades())
