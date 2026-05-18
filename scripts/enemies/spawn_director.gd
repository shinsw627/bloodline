# Design Ref: §2.3, §3.1 (SpawnTableData), §11.2 M1.
# M1 simple version: fixed enemy + interval that scales down over time.
# M3+ replaces with SpawnTableData phase-based system.
extends Node

@export var enemy_pool_path: NodePath
@export var player_path: NodePath
@export var enemy_data: EnemyData
@export var initial_interval: float = 1.5
@export var min_interval: float = 0.15
@export var ramp_seconds: float = 300.0     # reach min over 5 minutes
@export var spawn_radius_min: float = 320.0
@export var spawn_radius_max: float = 480.0
@export var max_alive: int = 500

var _accum: float = 0.0
var _pool: Pool
var _player: Node2D

func _ready() -> void:
	_pool = get_node(enemy_pool_path) as Pool
	_player = get_node(player_path) as Node2D
	assert(_pool != null and _player != null, "SpawnDirector: pool/player not set")
	assert(enemy_data != null, "SpawnDirector: enemy_data not set")

func _process(delta: float) -> void:
	if not GameState.is_running:
		return
	_accum += delta
	var interval := _current_interval()
	while _accum >= interval and _pool.active_count() < max_alive:
		_accum -= interval
		_spawn_one()
		interval = _current_interval()

func _current_interval() -> float:
	var t: float = clamp(GameState.run_time / ramp_seconds, 0.0, 1.0)
	return lerp(initial_interval, min_interval, t)

func _spawn_one() -> void:
	var angle := randf() * TAU
	var radius := randf_range(spawn_radius_min, spawn_radius_max)
	var pos: Vector2 = _player.global_position + Vector2.RIGHT.rotated(angle) * radius
	_pool.acquire({
		"data": enemy_data,
		"position": pos,
		"target": _player,
	})
