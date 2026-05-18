# Design Ref: §8.2 L1 — UpgradeRegistry.draw_cards eligibility logic.
# Uses a fake WeaponHolder/StatsComponent with controllable state.
extends GutTest

func before_each() -> void:
	UpgradeRegistry.clear()

func _make_weapon(id: StringName) -> WeaponData:
	var w := WeaponData.new()
	w.id = id
	w.display_name = String(id)
	w.max_level = 8
	return w

func _make_passive(id: StringName) -> PassiveData:
	var p := PassiveData.new()
	p.id = id
	p.display_name = String(id)
	p.max_level = 5
	return p

func _make_holder() -> WeaponHolder:
	var h := WeaponHolder.new()
	add_child_autofree(h)
	return h

func _make_stats() -> StatsComponent:
	var s := StatsComponent.new()
	add_child_autofree(s)
	s.current_hp = s.max_hp
	return s

func test_register_weapon_dedup() -> void:
	var w := _make_weapon(&"whip")
	UpgradeRegistry.register_weapon(w)
	UpgradeRegistry.register_weapon(w)
	assert_eq(UpgradeRegistry.weapons.size(), 1, "Same id not registered twice")

func test_draw_cards_returns_at_most_n() -> void:
	UpgradeRegistry.register_weapon(_make_weapon(&"w1"))
	UpgradeRegistry.register_weapon(_make_weapon(&"w2"))
	UpgradeRegistry.register_passive(_make_passive(&"p1"))
	var holder := _make_holder()
	var stats := _make_stats()
	var cards := UpgradeRegistry.draw_cards(holder, stats, 2)
	assert_eq(cards.size(), 2, "Returns exactly 2 cards when 3 eligible")

func test_draw_excludes_maxed_weapon() -> void:
	var w := _make_weapon(&"maxed")
	w.max_level = 1
	UpgradeRegistry.register_weapon(w)
	var holder := _make_holder()
	holder.add_weapon(w)  # now at level 1 = max
	var stats := _make_stats()
	var cards := UpgradeRegistry.draw_cards(holder, stats, 3)
	assert_eq(cards.size(), 0, "Maxed weapon not offered")

func test_draw_marks_new_for_unowned_weapon() -> void:
	var w := _make_weapon(&"fresh")
	UpgradeRegistry.register_weapon(w)
	var holder := _make_holder()
	var stats := _make_stats()
	var cards := UpgradeRegistry.draw_cards(holder, stats, 1)
	assert_eq(cards.size(), 1)
	assert_true(cards[0].is_new, "Unowned weapon → is_new=true")
	assert_eq(cards[0].current_level, 0)
	assert_eq(cards[0].next_level, 1)

func test_draw_marks_upgrade_for_owned() -> void:
	var w := _make_weapon(&"owned")
	UpgradeRegistry.register_weapon(w)
	var holder := _make_holder()
	holder.add_weapon(w)
	var stats := _make_stats()
	var cards := UpgradeRegistry.draw_cards(holder, stats, 1)
	assert_eq(cards.size(), 1)
	assert_false(cards[0].is_new, "Owned weapon → is_new=false")
	assert_eq(cards[0].current_level, 1)
	assert_eq(cards[0].next_level, 2)

func test_draw_excludes_full_slots_for_new_weapons() -> void:
	# Fill all 6 slots
	var holder := _make_holder()
	for i in WeaponHolder.MAX_SLOTS:
		var w := _make_weapon(StringName("filler_%d" % i))
		holder.add_weapon(w)
	# Register a 7th weapon (not in holder)
	var new_w := _make_weapon(&"seventh")
	UpgradeRegistry.register_weapon(new_w)
	var stats := _make_stats()
	var cards := UpgradeRegistry.draw_cards(holder, stats, 3)
	for c in cards:
		if c.type == "weapon":
			assert_false((c.data as WeaponData).id == &"seventh", "7th weapon excluded when slots full")
