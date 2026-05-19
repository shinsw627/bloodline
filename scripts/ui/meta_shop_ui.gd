# Design Ref: §5.1 MetaShop UI, §11.2 M3 step 4.
# Shows current gold + 3 upgrades with cost / level / buy button.
# Opened from GameOverScreen ("Meta Shop"). Closed via "Close" button.
extends CanvasLayer

@onready var _gold_label: Label = $Center/Panel/Margin/Layout/Header/GoldLabel
@onready var _upgrades_container: VBoxContainer = $Center/Panel/Margin/Layout/Upgrades
@onready var _close_button: Button = $Center/Panel/Margin/Layout/Footer/CloseButton

var _upgrades: Array = []

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_close_button.pressed.connect(_on_close)

func open(upgrades: Array) -> void:
	_upgrades = upgrades
	_rebuild()
	visible = true

func _rebuild() -> void:
	_gold_label.text = "Gold: %d" % SaveManager.get_gold()
	for c in _upgrades_container.get_children():
		c.queue_free()
	for u in _upgrades:
		_upgrades_container.add_child(_make_row(u))

func _make_row(up: MetaUpgradeData) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 40)
	row.add_theme_constant_override("separation", 12)
	# Icon
	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	icon.color = up.color
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	# Text block
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_label := Label.new()
	var lv := SaveManager.get_upgrade_level(up.id)
	name_label.text = "%s — Lv. %d / %d" % [up.display_name, lv, up.max_level]
	name_label.add_theme_font_size_override("font_size", 16)
	info.add_child(name_label)
	var desc := Label.new()
	desc.text = up.description
	desc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 1))
	desc.add_theme_font_size_override("font_size", 12)
	info.add_child(desc)
	row.add_child(info)
	# Buy button
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(110, 32)
	var cost := up.cost_for_next_level(lv)
	if cost < 0:
		btn.text = "MAX"
		btn.disabled = true
	else:
		btn.text = "Buy %d g" % cost
		btn.disabled = SaveManager.get_gold() < cost
	btn.pressed.connect(_on_buy.bind(up))
	row.add_child(btn)
	return row

func _on_buy(up: MetaUpgradeData) -> void:
	var lv := SaveManager.get_upgrade_level(up.id)
	var cost := up.cost_for_next_level(lv)
	if cost < 0:
		return
	if not SaveManager.spend_gold(cost):
		return
	SaveManager.set_upgrade_level(up.id, lv + 1)
	_rebuild()

func _on_close() -> void:
	visible = false
