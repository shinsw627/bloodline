# Design Ref: §5.4 LevelUpUI, §2.2 Data Flow level_up → cards → upgrade_chosen.
# Pauses game, shows 3 cards, applies chosen upgrade, resumes.
# Queues subsequent level_ups so multi-level on one frame is handled sequentially.
extends CanvasLayer

const CARD_SCENE_PATH := "res://scenes/ui/upgrade_card.tscn"

@onready var _cards_container: HBoxContainer = $Center/Panel/Margin/Layout/Cards

var _card_scene: PackedScene
var _pending_levels: int = 0
var _is_showing: bool = false
var _current_options: Array = []

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_card_scene = load(CARD_SCENE_PATH)
	EventBus.level_up.connect(_on_level_up)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_showing:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k := event as InputEventKey
		var idx := -1
		match k.keycode:
			KEY_1: idx = 0
			KEY_2: idx = 1
			KEY_3: idx = 2
		if idx >= 0 and idx < _current_options.size():
			_choose(_current_options[idx])
			get_viewport().set_input_as_handled()

func _on_level_up(_new_level: int) -> void:
	_pending_levels += 1
	if not _is_showing:
		_show_next()

func _show_next() -> void:
	var holder := _find_holder()
	var stats := _find_stats()
	if holder == null or stats == null:
		_pending_levels = 0
		return
	var options := UpgradeRegistry.draw_cards(holder, stats, 3)
	if options.is_empty():
		# Nothing to offer (all maxed). Skip future queued events.
		_pending_levels = 0
		return
	_current_options = options
	_build_cards(options)
	_is_showing = true
	show()
	get_tree().paused = true

func _build_cards(options: Array) -> void:
	for c in _cards_container.get_children():
		c.queue_free()
	for option in options:
		var card := _card_scene.instantiate()
		_cards_container.add_child(card)
		card.set_option(option)
		card.chosen.connect(_choose)

func _choose(option: Dictionary) -> void:
	_apply(option)
	EventBus.upgrade_chosen.emit(option)
	_is_showing = false
	hide()
	_current_options.clear()
	_pending_levels -= 1
	if _pending_levels > 0:
		_show_next()
	else:
		get_tree().paused = false

func _apply(option: Dictionary) -> void:
	var holder := _find_holder()
	var stats := _find_stats()
	match option.type:
		"weapon":
			var w := option.data as WeaponData
			if option.is_new:
				holder.add_weapon(w)
			else:
				holder.level_up_weapon(w.id)
		"passive":
			var p := option.data as PassiveData
			stats.apply_passive(p)
		"evolution":
			var source: WeaponData = option.source_weapon
			var evolved: WeaponData = option.data
			holder.remove_weapon(source.id)
			holder.add_weapon(evolved)

func _find_holder() -> WeaponHolder:
	var p := get_tree().get_first_node_in_group(&"player")
	return null if p == null else (p.get_node_or_null("WeaponHolder") as WeaponHolder)

func _find_stats() -> StatsComponent:
	var p := get_tree().get_first_node_in_group(&"player")
	return null if p == null else (p.get_node_or_null("Stats") as StatsComponent)
