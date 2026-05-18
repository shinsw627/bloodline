# Design Ref: §8.2 L1 — MetaUpgradeData.cost_for_next_level.
extends GutTest

func _make() -> MetaUpgradeData:
	var u := MetaUpgradeData.new()
	u.id = &"test_upgrade"
	u.max_level = 5
	u.cost_per_level = [10, 20, 30, 50, 80]
	u.effect_type = &"stat_mod"
	u.effect_stat = &"max_hp"
	u.effect_value = 0.10
	return u

func test_cost_for_level_zero() -> void:
	var u := _make()
	assert_eq(u.cost_for_next_level(0), 10, "First buy costs 10")

func test_cost_for_middle_level() -> void:
	var u := _make()
	assert_eq(u.cost_for_next_level(2), 30, "L2→L3 costs 30")

func test_cost_for_last_level() -> void:
	var u := _make()
	assert_eq(u.cost_for_next_level(4), 80, "L4→L5 (final) costs 80")

func test_cost_at_max_returns_minus_one() -> void:
	var u := _make()
	assert_eq(u.cost_for_next_level(5), -1, "At max, returns -1 sentinel")
	assert_eq(u.cost_for_next_level(99), -1, "Above max, also -1")

func test_cost_curve_shorter_than_max_clamps() -> void:
	# If cost_per_level shorter than max_level, last value repeats
	var u := _make()
	u.max_level = 7
	# cost_per_level still 5 entries; asking for level 5 (idx 5) → should return last entry
	assert_eq(u.cost_for_next_level(5), 80)
	assert_eq(u.cost_for_next_level(6), 80)
