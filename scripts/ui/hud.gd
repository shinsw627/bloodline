# Design Ref: §5.4 HUD Page UI Checklist.
# M1 baseline + M2 slot bar (weapons left, passives right).
extends CanvasLayer

const SLOT_SIZE := Vector2(36, 36)

@onready var _hp_bar: ProgressBar = $Margin/Layout/TopRow/HPGroup/HPBar
@onready var _hp_label: Label = $Margin/Layout/TopRow/HPGroup/HPLabel
@onready var _exp_bar: ProgressBar = $Margin/Layout/ExpBar
@onready var _time_label: Label = $Margin/Layout/TopRow/RightGroup/TimeLabel
@onready var _kills_label: Label = $Margin/Layout/TopRow/RightGroup/KillsLabel
@onready var _level_label: Label = $Margin/Layout/TopRow/RightGroup/LevelLabel
@onready var _weapon_slots: HBoxContainer = $BottomBar/WeaponSlots
@onready var _passive_slots: HBoxContainer = $BottomBar/PassiveSlots

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_hp_changed)
	EventBus.exp_changed.connect(_on_exp_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.minute_passed.connect(_on_minute_passed)
	EventBus.upgrade_chosen.connect(_on_upgrade_chosen)
	_refresh_initial()
	# Slot UI also needs a refresh when the player equips the starting weapon (post _ready)
	call_deferred("_refresh_slots")

func _refresh_initial() -> void:
	_on_level_up(GameState.current_level)
	_on_exp_changed(GameState.current_exp, GameState.exp_to_next(GameState.current_level))

func _process(_delta: float) -> void:
	_time_label.text = "%02d:%02d" % [int(GameState.run_time) / 60, int(GameState.run_time) % 60]
	_kills_label.text = "Kills: %d" % GameState.kills

func _on_hp_changed(current: float, max_hp: float) -> void:
	_hp_bar.max_value = max_hp
	_hp_bar.value = current
	_hp_label.text = "%d / %d" % [int(current), int(max_hp)]

func _on_exp_changed(current: int, to_next: int) -> void:
	_exp_bar.max_value = to_next
	_exp_bar.value = current

func _on_level_up(new_level: int) -> void:
	_level_label.text = "Lv. %d" % new_level

func _on_minute_passed(_elapsed_min: int) -> void:
	var tween := create_tween()
	tween.tween_property(_time_label, "modulate", Color(1.5, 1.2, 0.5, 1), 0.08)
	tween.tween_property(_time_label, "modulate", Color.WHITE, 0.35)

func _on_upgrade_chosen(_choice: Dictionary) -> void:
	_refresh_slots()

func _refresh_slots() -> void:
	var p := get_tree().get_first_node_in_group(&"player")
	if p == null:
		return
	var holder := p.get_node_or_null("WeaponHolder") as WeaponHolder
	var stats := p.get_node_or_null("Stats") as StatsComponent
	_build_weapon_slots(holder)
	_build_passive_slots(stats)

func _clear(container: Node) -> void:
	for c in container.get_children():
		c.queue_free()

func _build_weapon_slots(holder: WeaponHolder) -> void:
	_clear(_weapon_slots)
	if holder == null:
		return
	for slot in holder.get_slots():
		var w: WeaponData = slot.data
		_weapon_slots.add_child(_make_slot(w.projectile_color, slot.level))

func _build_passive_slots(stats: StatsComponent) -> void:
	_clear(_passive_slots)
	if stats == null:
		return
	for id in stats.passive_levels.keys():
		var lv: int = stats.passive_levels[id]
		var col := Color(0.7, 0.7, 0.7, 1)
		# Lookup color from UpgradeRegistry-known passives
		for p in UpgradeRegistry.passives:
			if p.id == id:
				col = p.color
				break
		_passive_slots.add_child(_make_slot(col, lv))

func _make_slot(color: Color, level: int) -> Control:
	var root := Panel.new()
	root.custom_minimum_size = SLOT_SIZE
	var rect := ColorRect.new()
	rect.color = color
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.offset_left = 4
	rect.offset_top = 4
	rect.offset_right = -4
	rect.offset_bottom = -4
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(rect)
	var lvl := Label.new()
	lvl.text = str(level)
	lvl.anchor_right = 1.0
	lvl.anchor_bottom = 1.0
	lvl.offset_right = -2
	lvl.offset_bottom = -2
	lvl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lvl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	lvl.add_theme_font_size_override("font_size", 12)
	lvl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(lvl)
	return root
