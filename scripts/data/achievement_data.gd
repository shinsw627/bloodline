# Design Ref: §3.1, §4.1 — AchievementData Resource.
# trigger_type:
#   "kill_count"   — total kills >= threshold (in single run)
#   "survive_sec"  — run_time >= threshold (single run)
#   "boss_kill"    — N boss kills (single run)
#   "level_reach"  — current_level >= threshold (single run)
#   "gold_run"     — gold_this_run >= threshold (single run)
class_name AchievementData
extends Resource

@export var id: StringName = &"first_blood"
@export var display_name: String = "First Blood"
@export var description: String = "Defeat your first enemy."
@export var color: Color = Color(0.95, 0.7, 0.3, 1)
@export var trigger_type: StringName = &"kill_count"
@export var threshold: float = 1.0
