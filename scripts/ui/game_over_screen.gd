# Design Ref: §5.4 GameOverScreen Page UI Checklist.
# Shown on EventBus.run_ended. Retry → reload. Meta → open MetaShop. Quit → quit.
extends CanvasLayer

@onready var _stats_label: Label = $Center/Panel/Margin/Layout/StatsLabel
@onready var _gold_label: Label = $Center/Panel/Margin/Layout/GoldLabel
@onready var _retry_button: Button = $Center/Panel/Margin/Layout/Buttons/RetryButton
@onready var _meta_button: Button = $Center/Panel/Margin/Layout/Buttons/MetaButton
@onready var _menu_button: Button = $Center/Panel/Margin/Layout/Buttons/MenuButton
@onready var _quit_button: Button = $Center/Panel/Margin/Layout/Buttons/QuitButton

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.run_ended.connect(_on_run_ended)
	_retry_button.pressed.connect(_on_retry)
	_meta_button.pressed.connect(_on_meta_shop)
	_menu_button.pressed.connect(_on_main_menu)
	_quit_button.pressed.connect(_on_quit)

func _on_run_ended(result: Dictionary) -> void:
	var t: float = result.get("survived_sec", 0.0)
	var k: int = result.get("kills", 0)
	var lv: int = result.get("level", 1)
	_stats_label.text = "Survived: %02d:%02d\nKills: %d\nLevel: %d" % [int(t) / 60, int(t) % 60, k, lv]
	_gold_label.text = "Earned: +%d gold (Total: %d)" % [GameState.gold_this_run, SaveManager.get_gold()]
	visible = true
	get_tree().paused = true

func _on_retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_meta_shop() -> void:
	var shop := get_tree().get_first_node_in_group(&"meta_shop")
	if shop == null:
		return
	var ups := get_tree().get_first_node_in_group(&"main") as Node
	if ups and ups.has_method("get_meta_upgrades"):
		shop.open(ups.get_meta_upgrades())
		# Refresh own gold label after potential spending on close — connect once.
		if not shop.visibility_changed.is_connected(_on_shop_closed):
			shop.visibility_changed.connect(_on_shop_closed)

func _on_shop_closed() -> void:
	_gold_label.text = "Earned: +%d gold (Total: %d)" % [GameState.gold_this_run, SaveManager.get_gold()]

func _on_main_menu() -> void:
	GameState.clear_selection()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit() -> void:
	get_tree().quit()
