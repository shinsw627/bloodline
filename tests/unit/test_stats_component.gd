# Design Ref: §8.2 L1 — StatsComponent modifier composition + damage flow.
# Plan SC: FR-04 pickup_radius is derived from this component.
extends GutTest

func _make() -> StatsComponent:
	var s := StatsComponent.new()
	# Bypass _ready's call_deferred to keep tests synchronous
	s.current_hp = s.max_hp
	return s

func test_base_stats() -> void:
	var s := _make()
	assert_eq(s.max_hp, 100.0)
	assert_eq(s.move_speed, 200.0)
	assert_eq(s.pickup_radius, 40.0)
	assert_eq(s.damage_mult, 1.0)
	assert_eq(s.cooldown_mult, 1.0)

func test_apply_modifier_additive() -> void:
	var s := _make()
	s.apply_modifier(&"move_speed", 0.10)
	s.apply_modifier(&"move_speed", 0.15)
	assert_almost_eq(s.move_speed, 200.0 * 1.25, 0.001, "Additive %: 25% speed up")

func test_cooldown_modifier_reduces() -> void:
	var s := _make()
	s.apply_modifier(&"cooldown", 0.20)
	assert_almost_eq(s.cooldown_mult, 0.80, 0.001, "cooldown_mod reduces cooldown_mult")

func test_take_damage_reduces_hp() -> void:
	var s := _make()
	s.take_damage(30.0)
	assert_eq(s.current_hp, 70.0)

func test_take_damage_clamps_to_zero() -> void:
	var s := _make()
	s.take_damage(9999.0)
	assert_eq(s.current_hp, 0.0, "HP clamped to 0")

func test_heal_clamps_to_max() -> void:
	var s := _make()
	s.take_damage(20.0)
	s.heal(9999.0)
	assert_eq(s.current_hp, s.max_hp, "Heal clamped to max_hp")

func test_apply_modifier_unknown_stat_warns_not_crashes() -> void:
	var s := _make()
	# Should not crash; just push_warning
	s.apply_modifier(&"nonexistent_stat", 1.0)
	pass_test("Unknown stat did not crash")
