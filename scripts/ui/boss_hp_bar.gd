# Design Ref: §5.4 HUD checklist — Boss HP bar (top, only while boss alive).
# Subscribes: boss_spawned (show), enemy_damaged (update if same boss), enemy_died (hide).
extends CanvasLayer

@onready var _name_label: Label = $Margin/Layout/NameLabel
@onready var _bar: ProgressBar = $Margin/Layout/Bar

var _boss: Node = null

func _ready() -> void:
	hide()
	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.enemy_damaged.connect(_on_enemy_damaged)
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.run_ended.connect(_on_run_ended)

func _on_boss_spawned(boss: Node) -> void:
	_boss = boss
	var data: EnemyData = boss.data
	_name_label.text = data.display_name.to_upper()
	_bar.max_value = data.hp
	_bar.value = data.hp
	show()

func _on_enemy_damaged(enemy: Node, _amount: float, _source: Node) -> void:
	if enemy != _boss:
		return
	_bar.value = enemy.current_hp

func _on_enemy_died(enemy: Node, _pos: Vector2) -> void:
	if enemy != _boss:
		return
	_boss = null
	hide()

func _on_run_ended(_result: Dictionary) -> void:
	_boss = null
	hide()
