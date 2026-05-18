# Design Ref: §5.1 — bootstrap entry point.
# Registers M2 content with UpgradeRegistry + applies M3 meta upgrades on run start.
extends Node2D

const WHIP: WeaponData = preload("res://resources/weapons/Whip.tres")
const MAGIC_WAND: WeaponData = preload("res://resources/weapons/MagicWand.tres")
const KNIFE: WeaponData = preload("res://resources/weapons/Knife.tres")

const PASSIVE_MAX_HP: PassiveData = preload("res://resources/passives/MaxHpUp.tres")
const PASSIVE_MOVE_SPEED: PassiveData = preload("res://resources/passives/MoveSpeedUp.tres")
const PASSIVE_PICKUP_RADIUS: PassiveData = preload("res://resources/passives/PickupRadiusUp.tres")

const META_HP: MetaUpgradeData = preload("res://resources/meta/StartHpUp.tres")
const META_SPEED: MetaUpgradeData = preload("res://resources/meta/StartSpeedUp.tres")
const META_PICKUP: MetaUpgradeData = preload("res://resources/meta/StartPickupUp.tres")

const SLIME: EnemyData = preload("res://resources/enemies/Slime.tres")

@onready var _player: Player = $Player
@onready var _spawn_director: Node = $SpawnDirector

func _ready() -> void:
	GameState.reset_run()
	_register_content()
	_apply_meta_upgrades()
	# Equip starting weapon
	var holder: WeaponHolder = _player.get_node("WeaponHolder")
	holder.add_weapon(WHIP)
	# Hand spawn data to director
	_spawn_director.set("enemy_data", SLIME)
	EventBus.run_started.emit(null, null)
	EventBus.player_died.connect(_on_player_died)
	print("[bloodline] M3 run started — meta upgrades: hp=%d, speed=%d, pickup=%d" %
		[SaveManager.get_upgrade_level(&"start_hp_up"),
		SaveManager.get_upgrade_level(&"start_speed_up"),
		SaveManager.get_upgrade_level(&"start_pickup_up")])

func _register_content() -> void:
	UpgradeRegistry.clear()
	UpgradeRegistry.register_weapon(WHIP)
	UpgradeRegistry.register_weapon(MAGIC_WAND)
	UpgradeRegistry.register_weapon(KNIFE)
	UpgradeRegistry.register_passive(PASSIVE_MAX_HP)
	UpgradeRegistry.register_passive(PASSIVE_MOVE_SPEED)
	UpgradeRegistry.register_passive(PASSIVE_PICKUP_RADIUS)

func get_meta_upgrades() -> Array:
	return [META_HP, META_SPEED, META_PICKUP]

func _apply_meta_upgrades() -> void:
	var stats := _player.get_node("Stats") as StatsComponent
	for up in get_meta_upgrades():
		var lv := SaveManager.get_upgrade_level(up.id)
		if lv <= 0:
			continue
		if up.effect_type == &"stat_mod":
			stats.apply_modifier(up.effect_stat, up.effect_value * lv)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_tree().paused = not get_tree().paused

func _on_player_died() -> void:
	print("[bloodline] You died. Survived: %.1fs, Kills: %d, Level: %d, Gold: %d" %
		[GameState.run_time, GameState.kills, GameState.current_level, GameState.gold_this_run])
	GameState.end_run("player_died")
