# Design Ref: §2.3, §3.1 SpawnTableData (M3 minimum), Plan FR-03 / FR-13.
# Regular enemies: ramped interval. Bosses: scheduled by run_time triggers from MapData.
extends Node

@export var enemy_pool_path: NodePath
@export var player_path: NodePath
@export var enemy_data: EnemyData
@export var initial_interval: float = 1.5
@export var min_interval: float = 0.15
@export var ramp_seconds: float = 300.0
@export var spawn_radius_min: float = 320.0
@export var spawn_radius_max: float = 480.0
@export var max_alive: int = 500
@export var boss_spawn_radius: float = 280.0

var boss_schedule: Array = []      # set by main.gd from MapData; copy to allow mutation
var _accum: float = 0.0
var _fired_bosses: Array = []      # indexes already triggered
var _pool: Pool
var _player: Node2D

func _ready() -> void:
	_pool = get_node(enemy_pool_path) as Pool
	_player = get_node(player_path) as Node2D
	assert(_pool != null and _player != null, "SpawnDirector: pool/player not set")

func reset_for_new_run(schedule: Array) -> void:
	boss_schedule = schedule.duplicate()
	_fired_bosses.clear()
	_accum = 0.0

func _process(delta: float) -> void:
	if not GameState.is_running:
		return
	_accum += delta
	# Regular spawns
	var interval := _current_interval()
	while _accum >= interval and _pool.active_count() < max_alive:
		_accum -= interval
		_spawn_one()
		interval = _current_interval()
	# Boss schedule check
	for i in boss_schedule.size():
		if i in _fired_bosses:
			continue
		var entry: Dictionary = boss_schedule[i]
		var t: float = float(entry.get("time", 0.0))
		if GameState.run_time >= t:
			_fired_bosses.append(i)
			_spawn_boss(entry.get("enemy", null))

func _current_interval() -> float:
	var t: float = clamp(GameState.run_time / ramp_seconds, 0.0, 1.0)
	return lerp(initial_interval, min_interval, t)

func _spawn_one() -> void:
	if enemy_data == null:
		return
	var angle := randf() * TAU
	var radius := randf_range(spawn_radius_min, spawn_radius_max)
	var pos: Vector2 = _player.global_position + Vector2.RIGHT.rotated(angle) * radius
	_pool.acquire({
		"data": enemy_data,
		"position": pos,
		"target": _player,
	})

func _spawn_boss(boss_data: EnemyData) -> void:
	if boss_data == null:
		push_warning("SpawnDirector: boss schedule entry missing 'enemy'")
		return
	var angle := randf() * TAU
	var pos: Vector2 = _player.global_position + Vector2.RIGHT.rotated(angle) * boss_spawn_radius
	_pool.acquire({
		"data": boss_data,
		"position": pos,
		"target": _player,
	})
