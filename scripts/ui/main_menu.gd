# Design Ref: §5.1 MainMenu, §5.4 Page UI Checklist.
# Entry point for new sessions. Play → CharacterSelect. MetaShop → MetaShopUI overlay.
extends CanvasLayer

signal play_pressed

@onready var _play_button: Button = $Center/Panel/Margin/Layout/Buttons/PlayButton
@onready var _meta_button: Button = $Center/Panel/Margin/Layout/Buttons/MetaButton
@onready var _quit_button: Button = $Center/Panel/Margin/Layout/Buttons/QuitButton
@onready var _version_label: Label = $VersionLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_play_button.pressed.connect(_on_play)
	_meta_button.pressed.connect(_on_meta)
	_quit_button.pressed.connect(_on_quit)
	_version_label.text = "v0.3 — M3"

func _on_play() -> void:
	play_pressed.emit()

func _on_meta() -> void:
	var shop := get_tree().get_first_node_in_group(&"meta_shop")
	var main_node := get_tree().get_first_node_in_group(&"main")
	if shop and main_node and main_node.has_method("get_meta_upgrades"):
		shop.open(main_node.get_meta_upgrades())

func _on_quit() -> void:
	get_tree().quit()
