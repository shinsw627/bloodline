# Design Ref: §3.1 — MapData Resource (M3 minimal subset).
# M5 will add bgm + spawn_table phases. M3 uses single enemy + tinted background.
class_name MapData
extends Resource

@export var id: StringName = &"forest"
@export var display_name: String = "Forest"
@export var description: String = "A quiet woodland."
@export var background_color: Color = Color(0.12, 0.09, 0.18, 1)
@export var preview_color: Color = Color(0.25, 0.55, 0.35)
@export var enemy_data: EnemyData     # Primary enemy spawned on this map
