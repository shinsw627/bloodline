# Design Ref: §5.1, §5.4 MapSelect.
# Receives Array[MapData] via open(...). Emits selected(map) on pick.
extends CanvasLayer

signal selected(map)
signal back_pressed

@onready var _cards_container: HBoxContainer = $Center/Panel/Margin/Layout/Cards
@onready var _back_button: Button = $Center/Panel/Margin/Layout/Footer/BackButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_back_button.pressed.connect(func(): back_pressed.emit())

func open(maps: Array) -> void:
	for c in _cards_container.get_children():
		c.queue_free()
	for m in maps:
		_cards_container.add_child(_make_card(m))
	visible = true

func _make_card(m: MapData) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(220, 220)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(v)
	# Preview
	var preview := ColorRect.new()
	preview.custom_minimum_size = Vector2(0, 90)
	preview.color = m.preview_color
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(preview)
	# Name
	var name_l := Label.new()
	name_l.text = m.display_name
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 20)
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(name_l)
	# Enemy
	var enemy := Label.new()
	enemy.text = "Enemy: %s" % m.enemy_data.display_name if m.enemy_data else "Enemy: —"
	enemy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy.add_theme_color_override("font_color", Color(1, 0.6, 0.6, 1))
	enemy.add_theme_font_size_override("font_size", 13)
	enemy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(enemy)
	# Description
	var desc := Label.new()
	desc.text = m.description
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
	desc.add_theme_font_size_override("font_size", 12)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(desc)
	btn.pressed.connect(func(): selected.emit(m))
	return btn
