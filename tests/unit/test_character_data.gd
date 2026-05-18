# Design Ref: §8.2 L1 — CharacterData base_stat_overrides via StatsComponent.
extends GutTest

func _make_stats() -> StatsComponent:
	var s := StatsComponent.new()
	add_child_autofree(s)
	s.current_hp = s.max_hp
	return s

func test_no_overrides_leaves_base() -> void:
	var c := CharacterData.new()
	c.id = &"plain"
	var s := _make_stats()
	s.apply_character_overrides(c)
	assert_eq(s.max_hp, 100.0)
	assert_eq(s.move_speed, 200.0)

func test_max_hp_override() -> void:
	var c := CharacterData.new()
	c.base_stat_overrides = {"max_hp": 0.30}
	var s := _make_stats()
	s.apply_character_overrides(c)
	assert_almost_eq(s.max_hp, 130.0, 0.001)

func test_multiple_overrides() -> void:
	var c := CharacterData.new()
	c.base_stat_overrides = {"max_hp": -0.20, "pickup_radius": 0.50}
	var s := _make_stats()
	s.apply_character_overrides(c)
	assert_almost_eq(s.max_hp, 80.0, 0.001)
	assert_almost_eq(s.pickup_radius, 60.0, 0.001)
	# Move speed untouched
	assert_eq(s.move_speed, 200.0)

func test_null_character_is_safe() -> void:
	var s := _make_stats()
	s.apply_character_overrides(null)
	pass_test("Null character override did not crash")
