# Design Ref: §3.2 Save Data Schema, §6 (E_SAVE_LOAD_FAIL / E_SAVE_WRITE_FAIL), §7 Robustness.
# ConfigFile + .bak atomic save. Versioned for future migration.
# Subscribes to run_ended to auto-commit run gold.
extends Node

const SAVE_PATH := "user://save.cfg"
const BACKUP_PATH := "user://save.cfg.bak"
const SCHEMA_VERSION := 1

var _cfg: ConfigFile = ConfigFile.new()

func _ready() -> void:
	load_save()
	EventBus.run_ended.connect(_on_run_ended)

# === Public API ===

func get_gold() -> int:
	return int(_cfg.get_value("currency", "gold", 0))

func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	_cfg.set_value("currency", "gold", get_gold() + amount)
	save()

func spend_gold(amount: int) -> bool:
	if amount < 0 or get_gold() < amount:
		return false
	_cfg.set_value("currency", "gold", get_gold() - amount)
	save()
	return true

func get_upgrade_level(id: StringName) -> int:
	return int(_cfg.get_value("upgrades", String(id), 0))

func set_upgrade_level(id: StringName, level: int) -> void:
	_cfg.set_value("upgrades", String(id), level)
	save()

func get_total_runs() -> int:
	return int(_cfg.get_value("meta", "total_runs", 0))

func get_total_play_seconds() -> int:
	return int(_cfg.get_value("meta", "total_play_seconds", 0))

# Generic boolean accessors (M4: achievements).
func get_value_bool(section: String, key: String, default: bool = false) -> bool:
	return bool(_cfg.get_value(section, key, default))

func set_value_bool(section: String, key: String, value: bool) -> void:
	_cfg.set_value(section, key, value)
	save()

# === Persistence ===

func load_save() -> void:
	var err := _cfg.load(SAVE_PATH)
	if err == OK:
		_migrate_if_needed()
		EventBus.save_loaded.emit()
		return
	# Try backup
	err = _cfg.load(BACKUP_PATH)
	if err == OK:
		push_warning("SaveManager: primary save corrupted, loaded backup.")
		_migrate_if_needed()
		EventBus.save_loaded.emit()
		save()  # restore primary
		return
	# Fresh start
	_init_defaults()
	EventBus.save_loaded.emit()

func save() -> void:
	# Atomic write: write temp → backup current → rename temp to primary.
	var tmp_path := SAVE_PATH + ".tmp"
	var err := _cfg.save(tmp_path)
	if err != OK:
		push_error("SaveManager: failed to write temp save (err %d)" % err)
		EventBus.save_failed.emit("write_temp_failed")
		return
	# Move existing primary to backup (best-effort)
	if FileAccess.file_exists(SAVE_PATH):
		var dir := DirAccess.open("user://")
		if dir:
			dir.rename(SAVE_PATH, BACKUP_PATH)
	# Promote temp to primary
	var dir2 := DirAccess.open("user://")
	if dir2:
		dir2.rename(tmp_path, SAVE_PATH)

func reset() -> void:
	_cfg = ConfigFile.new()
	_init_defaults()
	save()

# === Internal ===

func _init_defaults() -> void:
	_cfg.set_value("meta", "version", SCHEMA_VERSION)
	_cfg.set_value("meta", "total_runs", 0)
	_cfg.set_value("meta", "total_play_seconds", 0)
	_cfg.set_value("currency", "gold", 0)

func _migrate_if_needed() -> void:
	var v: int = int(_cfg.get_value("meta", "version", 0))
	if v >= SCHEMA_VERSION:
		return
	# Migration ladder. v0 → v1: ensure currency.gold exists.
	if v < 1:
		if not _cfg.has_section_key("currency", "gold"):
			_cfg.set_value("currency", "gold", 0)
	_cfg.set_value("meta", "version", SCHEMA_VERSION)
	save()

func _on_run_ended(result: Dictionary) -> void:
	# Commit run stats
	_cfg.set_value("meta", "total_runs", get_total_runs() + 1)
	_cfg.set_value("meta", "total_play_seconds",
		get_total_play_seconds() + int(result.get("survived_sec", 0.0)))
	add_gold(int(GameState.gold_this_run))
