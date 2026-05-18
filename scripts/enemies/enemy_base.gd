# Design Ref: §2.3, §3.1 — pooled Area2D enemy with chase AI + contact damage.
# Cross-system events go through EventBus (enemy_damaged, enemy_died).
extends Area2D

signal released

@export var data: EnemyData
var current_hp: float = 0.0
var _player: Node2D = null
var _touch_player: bool = false
var _contact_cooldown: float = 0.0

@onready var _visual: ColorRect = $Visual
@onready var _shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group(&"enemy")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func on_acquire(args: Dictionary) -> void:
	if args.has("data"):
		data = args["data"]
	assert(data != null, "EnemyBase acquired without EnemyData")
	current_hp = data.hp
	_visual.color = data.color
	var r := data.radius
	_visual.offset_left = -r
	_visual.offset_top = -r
	_visual.offset_right = r
	_visual.offset_bottom = r
	if _shape.shape is CircleShape2D:
		(_shape.shape as CircleShape2D).radius = r
	# Reset scale (in case previous user was a boss)
	scale = Vector2(data.visual_scale, data.visual_scale)
	global_position = args.get("position", Vector2.ZERO)
	_player = args.get("target", null)
	_touch_player = false
	_contact_cooldown = 0.0
	if data.is_boss:
		if not is_in_group(&"boss"):
			add_to_group(&"boss")
		EventBus.boss_spawned.emit(self)
	else:
		if is_in_group(&"boss"):
			remove_from_group(&"boss")
	EventBus.enemy_spawned.emit(self)

func on_release() -> void:
	_touch_player = false
	_player = null
	scale = Vector2.ONE
	if is_in_group(&"boss"):
		remove_from_group(&"boss")

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	# Chase
	var to_player: Vector2 = _player.global_position - global_position
	var dist := to_player.length()
	if dist > 1.0:
		global_position += to_player.normalized() * data.move_speed * delta
	# Contact damage tick
	if _touch_player:
		_contact_cooldown -= delta
		if _contact_cooldown <= 0.0:
			_contact_cooldown = data.contact_damage_interval
			if _player.has_node("Stats"):
				(_player.get_node("Stats") as StatsComponent).take_damage(data.contact_damage)

func take_damage(amount: float, source: Node) -> void:
	if current_hp <= 0.0:
		return
	current_hp -= amount
	EventBus.enemy_damaged.emit(self, amount, source)
	if current_hp <= 0.0:
		_die()

func _die() -> void:
	GameState.kills += 1
	_drop_exp_gem()
	_drop_gold_maybe()
	EventBus.enemy_died.emit(self, global_position)
	released.emit()

func _drop_exp_gem() -> void:
	if data == null or data.xp_drop <= 0:
		return
	var pool := get_tree().get_first_node_in_group(&"exp_gem_pool") as Pool
	if pool == null:
		return
	pool.acquire({
		"position": global_position,
		"amount": data.xp_drop,
		"target": _player,
	})

func _drop_gold_maybe() -> void:
	if data == null or data.gold_drop_chance <= 0.0:
		return
	if randf() > data.gold_drop_chance:
		return
	var pool := get_tree().get_first_node_in_group(&"gold_coin_pool") as Pool
	if pool == null:
		return
	# Bosses guarantee gold and drop a higher-value coin.
	var coin_value := 12 if data.is_boss else 1
	pool.acquire({
		"position": global_position,
		"amount": coin_value,
		"target": _player,
	})

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"player"):
		_touch_player = true
		_contact_cooldown = 0.0  # apply immediately on first contact

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(&"player"):
		_touch_player = false
