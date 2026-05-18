# Design Ref: §5.1 — M1 bootstrap entry point + M2 content registration.
# Wires up starting weapon, spawn data, and registers all upgradeable content with UpgradeRegistry.
extends Node2D

const WHIP: WeaponData = preload("res://resources/weapons/Whip.tres")
const MAGIC_WAND: WeaponData = preload("res://resources/weapons/MagicWand.tres")
const KNIFE: WeaponData = preload("res://resources/weapons/Knife.tres")

const PASSIVE_MAX_HP: PassiveData = preload("res://resources/passives/MaxHpUp.tres")
const PASSIVE_MOVE_SPEED: PassiveData = preload("res://resources/passives/MoveSpeedUp.tres")
const PASSIVE_PICKUP_RADIUS: PassiveData = preload("res://resources/passives/PickupRadiusUp.tres")

const SLIME: EnemyData = preload("res://resources/enemies/Slime.tres")

@onready var _player: Player = $Player
@onready var _spawn_director: Node = $SpawnDirector

func _ready() -> void:
	GameState.reset_run()
	_register_content()
	# Equip starting weapon
	var holder: WeaponHolder = _player.get_node("WeaponHolder")
	holder.add_weapon(WHIP)
	# Hand spawn data to director
	_spawn_director.set("enemy_data", SLIME)
	EventBus.run_started.emit(null, null)
	EventBus.player_died.connect(_on_player_died)
	print("[bloodline] M2 run started — level up to pick from 3 cards.")

func _register_content() -> void:
	# Plan FR-06: data-driven content; add new .tres here to make it draftable.
	UpgradeRegistry.clear()
	UpgradeRegistry.register_weapon(WHIP)
	UpgradeRegistry.register_weapon(MAGIC_WAND)
	UpgradeRegistry.register_weapon(KNIFE)
	UpgradeRegistry.register_passive(PASSIVE_MAX_HP)
	UpgradeRegistry.register_passive(PASSIVE_MOVE_SPEED)
	UpgradeRegistry.register_passive(PASSIVE_PICKUP_RADIUS)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_tree().paused = not get_tree().paused

func _on_player_died() -> void:
	print("[bloodline] You died. Survived: %.1fs, Kills: %d, Level: %d" %
		[GameState.run_time, GameState.kills, GameState.current_level])
	GameState.end_run("player_died")
