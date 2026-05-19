# Design Ref: §5.1 — bootstrap + selection flow + run start.
# State machine: MENU → CHAR_SELECT → MAP_SELECT → PLAYING.
# After death + Retry, selection persists in GameState → goes straight to PLAYING.
extends Node2D

enum State { MENU, CHAR_SELECT, MAP_SELECT, PLAYING }

# Content registries
const WHIP: WeaponData = preload("res://resources/weapons/Whip.tres")
const MAGIC_WAND: WeaponData = preload("res://resources/weapons/MagicWand.tres")
const KNIFE: WeaponData = preload("res://resources/weapons/Knife.tres")
const GARLIC: WeaponData = preload("res://resources/weapons/Garlic.tres")
const BIBLE: WeaponData = preload("res://resources/weapons/Bible.tres")
# Evolved weapons (registered for evolution lookup; not offered as new-weapon cards)
const CROSS: WeaponData = preload("res://resources/weapons/Cross.tres")
const HOLY_WAND: WeaponData = preload("res://resources/weapons/HolyWand.tres")
const KNIFE_STORM: WeaponData = preload("res://resources/weapons/KnifeStorm.tres")

const ACH_FIRST_BLOOD: AchievementData = preload("res://resources/achievements/FirstBlood.tres")
const ACH_CENTURION: AchievementData = preload("res://resources/achievements/Centurion.tres")
const ACH_SURVIVOR: AchievementData = preload("res://resources/achievements/Survivor.tres")
const ACH_BOSS_SLAYER: AchievementData = preload("res://resources/achievements/BossSlayer.tres")
const ACH_LEVEL_TEN: AchievementData = preload("res://resources/achievements/LevelTen.tres")
const ACH_GREED: AchievementData = preload("res://resources/achievements/Greed.tres")

const PASSIVE_MAX_HP: PassiveData = preload("res://resources/passives/MaxHpUp.tres")
const PASSIVE_MOVE_SPEED: PassiveData = preload("res://resources/passives/MoveSpeedUp.tres")
const PASSIVE_PICKUP_RADIUS: PassiveData = preload("res://resources/passives/PickupRadiusUp.tres")
const PASSIVE_DAMAGE: PassiveData = preload("res://resources/passives/DamageUp.tres")
const PASSIVE_COOLDOWN: PassiveData = preload("res://resources/passives/CooldownDown.tres")

const META_HP: MetaUpgradeData = preload("res://resources/meta/StartHpUp.tres")
const META_SPEED: MetaUpgradeData = preload("res://resources/meta/StartSpeedUp.tres")
const META_PICKUP: MetaUpgradeData = preload("res://resources/meta/StartPickupUp.tres")

const CHAR_VAGABOND: CharacterData = preload("res://resources/characters/Vagabond.tres")
const CHAR_KNIGHT: CharacterData = preload("res://resources/characters/Knight.tres")
const CHAR_MAGE: CharacterData = preload("res://resources/characters/Mage.tres")

const MAP_FOREST: MapData = preload("res://resources/maps/Forest.tres")
const MAP_CEMETERY: MapData = preload("res://resources/maps/Cemetery.tres")

@onready var _player: Player = $Player
@onready var _spawn_director: Node = $SpawnDirector
@onready var _background: ColorRect = $World/Background
@onready var _main_menu: CanvasLayer = $MainMenu
@onready var _character_select: CanvasLayer = $CharacterSelect
@onready var _map_select: CanvasLayer = $MapSelect
@onready var _pause_ui: CanvasLayer = $PauseUI
@onready var _settings_ui: CanvasLayer = $SettingsUI
@onready var _achievement_panel: CanvasLayer = $AchievementPanel

var _state: int = State.MENU

func _ready() -> void:
	_register_content()
	_wire_selection_ui()
	if GameState.has_selection():
		_start_run()
	else:
		_enter_menu()

func _register_content() -> void:
	UpgradeRegistry.clear()
	# Original weapons (5) — eligible for new-weapon and upgrade cards.
	UpgradeRegistry.register_weapon(WHIP)
	UpgradeRegistry.register_weapon(MAGIC_WAND)
	UpgradeRegistry.register_weapon(KNIFE)
	UpgradeRegistry.register_weapon(GARLIC)
	UpgradeRegistry.register_weapon(BIBLE)
	UpgradeRegistry.register_passive(PASSIVE_MAX_HP)
	UpgradeRegistry.register_passive(PASSIVE_MOVE_SPEED)
	UpgradeRegistry.register_passive(PASSIVE_PICKUP_RADIUS)
	UpgradeRegistry.register_passive(PASSIVE_DAMAGE)
	UpgradeRegistry.register_passive(PASSIVE_COOLDOWN)
	# Achievements
	AchievementSystem.clear()
	AchievementSystem.register(ACH_FIRST_BLOOD)
	AchievementSystem.register(ACH_CENTURION)
	AchievementSystem.register(ACH_SURVIVOR)
	AchievementSystem.register(ACH_BOSS_SLAYER)
	AchievementSystem.register(ACH_LEVEL_TEN)
	AchievementSystem.register(ACH_GREED)

func get_meta_upgrades() -> Array:
	return [META_HP, META_SPEED, META_PICKUP]

func get_characters() -> Array:
	return [CHAR_VAGABOND, CHAR_KNIGHT, CHAR_MAGE]

func get_maps() -> Array:
	return [MAP_FOREST, MAP_CEMETERY]

# === Selection flow ===

func _wire_selection_ui() -> void:
	_main_menu.play_pressed.connect(_on_play_pressed)
	_main_menu.achievements_pressed.connect(_on_achievements_pressed)
	_main_menu.settings_pressed.connect(_on_settings_pressed)
	_character_select.selected.connect(_on_character_chosen)
	_character_select.back_pressed.connect(_enter_menu)
	_map_select.selected.connect(_on_map_chosen)
	_map_select.back_pressed.connect(_enter_character_select)
	_pause_ui.resume_pressed.connect(_on_resume_pressed)
	_pause_ui.settings_pressed.connect(_on_settings_pressed)
	_pause_ui.main_menu_pressed.connect(_on_pause_main_menu)

func _on_achievements_pressed() -> void:
	_achievement_panel.open()

func _on_settings_pressed() -> void:
	_settings_ui.open()

func _on_resume_pressed() -> void:
	_pause_ui.visible = false
	get_tree().paused = false

func _on_pause_main_menu() -> void:
	_pause_ui.visible = false
	GameState.clear_selection()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _enter_menu() -> void:
	_state = State.MENU
	GameState.is_running = false
	get_tree().paused = false       # menu navigation
	_main_menu.visible = true
	_character_select.visible = false
	_map_select.visible = false
	_hide_world_briefly(true)

func _enter_character_select() -> void:
	_state = State.CHAR_SELECT
	_main_menu.visible = false
	_character_select.open(get_characters())
	_map_select.visible = false

func _enter_map_select() -> void:
	_state = State.MAP_SELECT
	_main_menu.visible = false
	_character_select.visible = false
	_map_select.open(get_maps())

func _on_play_pressed() -> void:
	_enter_character_select()

func _on_character_chosen(c: CharacterData) -> void:
	GameState.selected_character = c
	_enter_map_select()

func _on_map_chosen(m: MapData) -> void:
	GameState.selected_map = m
	_start_run()

# === Run lifecycle ===

func _start_run() -> void:
	_state = State.PLAYING
	_main_menu.visible = false
	_character_select.visible = false
	_map_select.visible = false
	_hide_world_briefly(false)
	GameState.reset_run()
	# Apply character overrides (override base stats) BEFORE meta upgrades.
	var stats := _player.get_node("Stats") as StatsComponent
	stats.passive_levels.clear()
	stats.max_hp_mod = 0.0
	stats.move_speed_mod = 0.0
	stats.pickup_radius_mod = 0.0
	stats.damage_mod = 0.0
	stats.cooldown_mod = 0.0
	stats.apply_character_overrides(GameState.selected_character)
	_apply_meta_upgrades(stats)
	# Sync current_hp to (possibly) new max_hp.
	stats.current_hp = stats.max_hp
	EventBus.player_health_changed.emit(stats.current_hp, stats.max_hp)
	# Visuals
	_background.color = GameState.selected_map.background_color
	_player.modulate = GameState.selected_character.color
	# Weapons
	var holder: WeaponHolder = _player.get_node("WeaponHolder")
	_reset_weapons(holder)
	if GameState.selected_character.starting_weapon:
		holder.add_weapon(GameState.selected_character.starting_weapon)
	# Spawn director uses map's enemy + boss schedule
	_spawn_director.set("enemy_data", GameState.selected_map.enemy_data)
	if _spawn_director.has_method("reset_for_new_run"):
		_spawn_director.reset_for_new_run(GameState.selected_map.boss_schedule)
	# Start
	EventBus.run_started.emit(GameState.selected_character, GameState.selected_map)
	if not EventBus.player_died.is_connected(_on_player_died):
		EventBus.player_died.connect(_on_player_died)
	print("[bloodline] Run start — char=%s map=%s meta(hp=%d sp=%d pk=%d)" % [
		GameState.selected_character.id, GameState.selected_map.id,
		SaveManager.get_upgrade_level(&"start_hp_up"),
		SaveManager.get_upgrade_level(&"start_speed_up"),
		SaveManager.get_upgrade_level(&"start_pickup_up")])

func _reset_weapons(holder: WeaponHolder) -> void:
	holder.clear_weapons()

func _apply_meta_upgrades(stats: StatsComponent) -> void:
	for up in get_meta_upgrades():
		var lv := SaveManager.get_upgrade_level(up.id)
		if lv <= 0:
			continue
		if up.effect_type == &"stat_mod":
			stats.apply_modifier(up.effect_stat, up.effect_value * lv)

func _hide_world_briefly(hidden: bool) -> void:
	# During selection UI, freeze gameplay nodes. Use process_mode to pause physics.
	# (We don't set tree.paused because selection UIs would also pause without ALWAYS mode.)
	_player.set_physics_process(not hidden)
	_player.visible = not hidden
	for pool_name in [&"enemy_pool", &"projectile_pool", &"exp_gem_pool", &"gold_coin_pool"]:
		var pool := get_tree().get_first_node_in_group(pool_name)
		if pool:
			pool.process_mode = Node.PROCESS_MODE_DISABLED if hidden else Node.PROCESS_MODE_INHERIT
	_spawn_director.process_mode = Node.PROCESS_MODE_DISABLED if hidden else Node.PROCESS_MODE_INHERIT

func _unhandled_input(event: InputEvent) -> void:
	if _state != State.PLAYING:
		return
	if event.is_action_pressed(&"pause"):
		if get_tree().paused:
			_pause_ui.visible = false
			get_tree().paused = false
		else:
			get_tree().paused = true
			_pause_ui.visible = true

func _on_player_died() -> void:
	print("[bloodline] You died — survived %.1fs, kills=%d, level=%d, gold=%d" %
		[GameState.run_time, GameState.kills, GameState.current_level, GameState.gold_this_run])
	GameState.end_run("player_died")
