# Design Ref: §5.1, §5.4 CharacterSelect.
# Receives an Array[CharacterData] via open(...). Emits selected(character) on pick.
extends CanvasLayer

signal selected(character)

@onready var _cards_container: HBoxContainer = $Center/Panel/Margin/Layout/Cards
@onready var _back_button: Button = $Center/Panel/Margin/Layout/Footer/BackButton

signal back_pressed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_back_button.pressed.connect(func(): back_pressed.emit())

func open(characters: Array) -> void:
	for c in _cards_container.get_children():
		c.queue_free()
	for char_data in characters:
		_cards_container.add_child(_make_card(char_data))
	show()

func _make_card(c: CharacterData) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(180, 260)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(v)
	# Portrait placeholder
	var portrait := ColorRect.new()
	portrait.custom_minimum_size = Vector2(0, 80)
	portrait.color = c.color
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(portrait)
	# Name
	var name_l := Label.new()
	name_l.text = c.display_name
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.add_theme_font_size_override("font_size", 20)
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(name_l)
	# Weapon
	var wep := Label.new()
	wep.text = "Weapon: %s" % c.starting_weapon.display_name if c.starting_weapon else "Weapon: —"
	wep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wep.add_theme_color_override("font_color", Color(0.65, 0.85, 1, 1))
	wep.add_theme_font_size_override("font_size", 13)
	wep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(wep)
	# Description
	var desc := Label.new()
	desc.text = c.description
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
	desc.add_theme_font_size_override("font_size", 12)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(desc)
	btn.pressed.connect(func(): selected.emit(c))
	return btn
