# Design Ref: §3.1 — Custom Resource for enemy definition.
# Adding a new enemy = create a new .tres, no code changes (M3+ scaling).
class_name EnemyData
extends Resource

@export var id: StringName = &"slime"
@export var display_name: String = "Slime"
@export var texture: Texture2D
@export var color: Color = Color(0.6, 0.2, 0.3)
@export var hp: float = 10.0
@export var contact_damage: float = 5.0
@export var contact_damage_interval: float = 0.5   # sec between ticks while overlapping
@export var move_speed: float = 60.0
@export var xp_drop: int = 1
@export var gold_drop_chance: float = 0.0
@export var radius: float = 14.0
@export var ai_type: int = 0    # 0=chase (M1), 1=ranged, 2=charge, 3=boss (M3+)
@export var is_boss: bool = false
@export var visual_scale: float = 1.0    # multiplier applied to body visual + collision
