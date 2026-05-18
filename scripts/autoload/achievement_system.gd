# Design Ref: §4.1 achievement_unlocked, §11.2 M4 step 3.
# Subscribes to EventBus signals, tracks run-scoped progress, unlocks via SaveManager.
# Achievements are unlocked once; never re-fired.
extends Node

var achievements: Array[AchievementData] = []
var _run_boss_kills: int = 0

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.level_up.connect(_on_level_up)
	EventBus.gold_collected.connect(_on_gold_collected)
	EventBus.minute_passed.connect(_on_minute_passed)
	EventBus.run_started.connect(_on_run_started)

func register(a: AchievementData) -> void:
	if a == null:
		return
	for existing in achievements:
		if existing.id == a.id:
			return
	achievements.append(a)

func clear() -> void:
	achievements.clear()
	_run_boss_kills = 0

func is_unlocked(id: StringName) -> bool:
	return SaveManager.get_value_bool("achievements", String(id), false)

func _on_run_started(_character, _map) -> void:
	_run_boss_kills = 0

func _on_enemy_died(enemy: Node, _pos: Vector2) -> void:
	# kill_count tracked via GameState.kills
	_check_type(&"kill_count", float(GameState.kills))
	if enemy != null and enemy.data != null and enemy.data.is_boss:
		_run_boss_kills += 1
		_check_type(&"boss_kill", float(_run_boss_kills))

func _on_level_up(new_level: int) -> void:
	_check_type(&"level_reach", float(new_level))

func _on_gold_collected(_amount: int) -> void:
	_check_type(&"gold_run", float(GameState.gold_this_run))

func _on_minute_passed(_min: int) -> void:
	_check_type(&"survive_sec", float(GameState.run_time))

func _check_type(trigger: StringName, current: float) -> void:
	for a in achievements:
		if a.trigger_type != trigger:
			continue
		if is_unlocked(a.id):
			continue
		if current >= a.threshold:
			_unlock(a)

func _unlock(a: AchievementData) -> void:
	SaveManager.set_value_bool("achievements", String(a.id), true)
	EventBus.achievement_unlocked.emit(a.id)
	print("[bloodline] Achievement unlocked: %s" % a.display_name)
