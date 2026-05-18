# Design Ref: §4.1 EventBus Signal Catalog — global signal hub for loose coupling.
# Cross-system communication goes through these signals. Same-actor calls stay direct.
# Adding a signal: update Design §4.1 catalog and §12 Decision Record.
extends Node

# === Run lifecycle ===
signal run_started(character, map)
signal run_ended(result)                    # Dictionary {survived_sec, kills, level, cause}

# === Player ===
signal player_health_changed(current: float, max_hp: float)
signal player_died

# === Enemies ===
signal enemy_spawned(enemy: Node2D)
signal enemy_damaged(enemy: Node2D, amount: float, source: Node)
signal enemy_died(enemy: Node2D, position: Vector2)

# === Pickups / EXP ===
signal exp_collected(amount: int)
signal exp_changed(current: int, to_next: int)
signal gold_collected(amount: int)
signal item_pickup(kind: StringName)

# === Leveling / Upgrades ===
signal level_up(new_level: int)
signal upgrade_offered(cards: Array)        # Array[Dictionary]
signal upgrade_chosen(choice: Dictionary)

# === Combat / Time ===
signal boss_spawned(enemy: Node2D)
signal minute_passed(elapsed_min: int)

# === Achievements (M4) ===
signal achievement_unlocked(id: StringName)

# === Meta ===
signal save_loaded
signal save_failed(reason: String)
