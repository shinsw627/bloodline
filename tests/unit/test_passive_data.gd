# Design Ref: §8.2 L1 — PassiveData.mod_at_level.
extends GutTest

func _make() -> PassiveData:
	var p := PassiveData.new()
	p.id = &"test_passive"
	p.max_level = 3
	p.stat_mods = [
		{"stat": "move_speed", "value": 0.10},
		{"stat": "move_speed", "value": 0.15},
		{"stat": "move_speed", "value": 0.20},
	]
	return p

func test_mod_at_level_first() -> void:
	var p := _make()
	var mod := p.mod_at_level(1)
	assert_eq(mod.stat, "move_speed")
	assert_almost_eq(mod.value, 0.10, 0.001)

func test_mod_at_level_middle() -> void:
	var p := _make()
	var mod := p.mod_at_level(2)
	assert_almost_eq(mod.value, 0.15, 0.001)

func test_mod_at_level_zero_returns_empty() -> void:
	var p := _make()
	var mod := p.mod_at_level(0)
	assert_true(mod.is_empty(), "level 0 returns empty dict (no modifier)")

func test_mod_at_level_over_max_returns_empty() -> void:
	var p := _make()
	var mod := p.mod_at_level(99)
	assert_true(mod.is_empty(), "Beyond stat_mods size returns empty")
