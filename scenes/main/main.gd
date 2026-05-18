# Design Ref: §5.1 — M1 bootstrap entry point.
# Wires up starting weapon and spawn data. M3 replaces with menu → character/map flow.
extends Node2D

const WHIP: WeaponData = preload("res://resources/weapons/Whip.tres")
const SLIME: EnemyData = preload("res://resources/enemies/Slime.tres")

@onready var _player: Player = $Player
@onready var _spawn_director: Node = $SpawnDirector

func _ready() -> void:
	GameState.reset_run()
	# Equip starting weapon
	var holder: WeaponHolder = _player.get_node("WeaponHolder")
	holder.add_weapon(WHIP)
	# Hand spawn data to director
	_spawn_director.set("enemy_data", SLIME)
	EventBus.run_started.emit(null, null)
	EventBus.player_died.connect(_on_player_died)
	print("[bloodline] M1 run started — survive!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_tree().paused = not get_tree().paused

func _on_player_died() -> void:
	print("[bloodline] You died. Survived: %.1fs, Kills: %d" % [GameState.run_time, GameState.kills])
	GameState.end_run("player_died")
	# M1: restart on death after short delay. Replaced by GameOverScreen in m1-exp module.
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
