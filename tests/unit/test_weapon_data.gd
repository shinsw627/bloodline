# Design Ref: §8.2 L1 #3 — WeaponData.stats_at_level aggregate stats.
extends GutTest

func _make_whip() -> WeaponData:
	var d := WeaponData.new()
	d.base_damage = 10.0
	d.base_cooldown = 1.0
	d.base_projectile_count = 1
	d.base_pierce = 0
	d.base_speed = 400.0
	d.base_lifetime = 0.6
	d.base_area_scale = 1.0
	d.max_level = 8
	d.level_curve = [
		{"damage": 4.0},
		{"cooldown": -0.05},
		{"damage": 4.0, "pierce": 1},
		{"count": 1},
	]
	return d

func test_stats_at_level_1_returns_base() -> void:
	var d := _make_whip()
	var s := d.stats_at_level(1)
	assert_eq(s.damage, 10.0, "L1 damage = base")
	assert_eq(s.cooldown, 1.0, "L1 cooldown = base")
	assert_eq(s.count, 1, "L1 count = base")

func test_stats_at_level_3_accumulates() -> void:
	var d := _make_whip()
	var s := d.stats_at_level(3)
	# L1→L2 applies curve[0] (+4 damage); L2→L3 applies curve[1] (-0.05 cooldown)
	assert_eq(s.damage, 14.0, "L3 damage = 10 + 4")
	assert_almost_eq(s.cooldown, 0.95, 0.001, "L3 cooldown = 1.0 - 0.05")

func test_stats_at_level_5_full_curve() -> void:
	var d := _make_whip()
	var s := d.stats_at_level(5)
	# Apply curve[0..3]: damage +4 +4 = 18, cooldown -0.05 = 0.95, pierce +1 = 1, count +1 = 2
	assert_eq(s.damage, 18.0, "L5 damage accumulates curve[0]+curve[2]")
	assert_eq(s.pierce, 1, "L5 pierce = curve[2].pierce")
	assert_eq(s.count, 2, "L5 count = base + curve[3].count")

func test_partial_curve_dict_only_affects_named_stats() -> void:
	var d := _make_whip()
	var s := d.stats_at_level(2)
	# curve[0] = {"damage": 4}; cooldown, count etc unchanged
	assert_eq(s.damage, 14.0)
	assert_eq(s.cooldown, 1.0)
	assert_eq(s.count, 1)
	assert_eq(s.pierce, 0)

func test_player_stats_multipliers_applied() -> void:
	var d := _make_whip()
	var s := d.stats_at_level(1, {"damage_mult": 1.5, "cooldown_mult": 0.8})
	assert_eq(s.damage, 15.0, "damage *= 1.5")
	assert_almost_eq(s.cooldown, 0.8, 0.001, "cooldown *= 0.8")

func test_level_capped_by_curve_size() -> void:
	# Curve has 4 entries; asking for L8 should not crash (uses min(level-1, size))
	var d := _make_whip()
	var s := d.stats_at_level(8)
	assert_eq(s.damage, 18.0, "Stats stop accumulating once curve is exhausted")
