# Design Ref: §5.2 Component List — AchievementToast (M4).
# Subscribes to achievement_unlocked, queues toast notifications top-right with Tween slide.
extends CanvasLayer

const DISPLAY_SECONDS := 3.0
const SLIDE_PX := 320.0

@onready var _panel: PanelContainer = $Anchor/Panel
@onready var _icon: ColorRect = $Anchor/Panel/Margin/Layout/IconRect
@onready var _title: Label = $Anchor/Panel/Margin/Layout/TextBlock/Title
@onready var _name_label: Label = $Anchor/Panel/Margin/Layout/TextBlock/NameLabel

var _queue: Array = []
var _showing: bool = false

func _ready() -> void:
	_panel.modulate.a = 0.0
	_panel.position.x = SLIDE_PX
	EventBus.achievement_unlocked.connect(_on_unlocked)

func _on_unlocked(id: StringName) -> void:
	_queue.append(id)
	if not _showing:
		_show_next()

func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		return
	_showing = true
	var id: StringName = _queue.pop_front()
	var data := _find_data(id)
	if data == null:
		_show_next()
		return
	_icon.color = data.color
	_title.text = "ACHIEVEMENT UNLOCKED"
	_name_label.text = data.display_name
	# Slide in + fade
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_panel, "position:x", 0.0, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.2)
	tween.set_parallel(false)
	tween.tween_interval(DISPLAY_SECONDS)
	tween.set_parallel(true)
	tween.tween_property(_panel, "position:x", SLIDE_PX, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(_panel, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(_show_next)

func _find_data(id: StringName) -> AchievementData:
	for a in AchievementSystem.achievements:
		if a.id == id:
			return a
	return null
