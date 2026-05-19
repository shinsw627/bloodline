# Design Ref: Plan §11.2 M4 step 4 — Achievement unlock tree (panel form for M5).
# Lists all registered AchievementSystem entries with locked/unlocked status.
extends CanvasLayer

@onready var _list: VBoxContainer = $Center/Panel/Margin/Layout/List
@onready var _close_button: Button = $Center/Panel/Margin/Layout/Footer/CloseButton
@onready var _progress: Label = $Center/Panel/Margin/Layout/Header/ProgressLabel

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_close_button.pressed.connect(_on_close)

func open() -> void:
	_rebuild()
	show()

func _rebuild() -> void:
	for c in _list.get_children():
		c.queue_free()
	var unlocked := 0
	for a in AchievementSystem.achievements:
		var is_locked: bool = not AchievementSystem.is_unlocked(a.id)
		if not is_locked:
			unlocked += 1
		_list.add_child(_make_row(a, is_locked))
	_progress.text = "%d / %d" % [unlocked, AchievementSystem.achievements.size()]

func _make_row(a: AchievementData, is_locked: bool) -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 38)
	row.add_theme_constant_override("separation", 12)
	# Icon
	var icon := ColorRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	icon.color = a.color if not is_locked else Color(0.25, 0.25, 0.3, 1)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	# Text
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_l := Label.new()
	name_l.text = ("???" if is_locked else a.display_name)
	name_l.add_theme_color_override("font_color",
		Color(0.5, 0.5, 0.55, 1) if is_locked else Color(1, 1, 1, 1))
	name_l.add_theme_font_size_override("font_size", 16)
	v.add_child(name_l)
	var desc := Label.new()
	desc.text = a.description
	desc.add_theme_color_override("font_color",
		Color(0.4, 0.4, 0.45, 1) if is_locked else Color(0.78, 0.78, 0.78, 1))
	desc.add_theme_font_size_override("font_size", 12)
	v.add_child(desc)
	row.add_child(v)
	# Status badge
	var status := Label.new()
	status.text = "🔒" if is_locked else "✓"
	status.add_theme_color_override("font_color",
		Color(0.4, 0.4, 0.45, 1) if is_locked else Color(0.55, 0.95, 0.55, 1))
	status.add_theme_font_size_override("font_size", 20)
	status.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(status)
	return row

func _on_close() -> void:
	hide()
