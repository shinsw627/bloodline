# Design Ref: §5.4 HUD Page UI Checklist (minimal M1 subset).
# M1: HP bar, EXP bar, time, kills, level. Weapon/passive slots in M2.
extends CanvasLayer

@onready var _hp_bar: ProgressBar = $Margin/Layout/TopRow/HPGroup/HPBar
@onready var _hp_label: Label = $Margin/Layout/TopRow/HPGroup/HPLabel
@onready var _exp_bar: ProgressBar = $Margin/Layout/ExpBar
@onready var _time_label: Label = $Margin/Layout/TopRow/RightGroup/TimeLabel
@onready var _kills_label: Label = $Margin/Layout/TopRow/RightGroup/KillsLabel
@onready var _level_label: Label = $Margin/Layout/TopRow/RightGroup/LevelLabel

func _ready() -> void:
	EventBus.player_health_changed.connect(_on_hp_changed)
	EventBus.exp_changed.connect(_on_exp_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.minute_passed.connect(_on_minute_passed)
	_refresh_initial()

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
	# Design §5.4 HUD checklist — flash time label on minute change.
	var tween := create_tween()
	tween.tween_property(_time_label, "modulate", Color(1.5, 1.2, 0.5, 1), 0.08)
	tween.tween_property(_time_label, "modulate", Color.WHITE, 0.35)
