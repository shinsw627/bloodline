# Design Ref: §8.2 L1 #5 #6 — SaveManager round-trip + version migration.
# Uses the real autoload; reset() wipes user save before each test.
extends GutTest

func before_each() -> void:
	SaveManager.reset()

func test_initial_state_is_clean() -> void:
	assert_eq(SaveManager.get_gold(), 0)
	assert_eq(SaveManager.get_total_runs(), 0)

func test_add_gold_accumulates_and_persists() -> void:
	SaveManager.add_gold(50)
	SaveManager.add_gold(25)
	assert_eq(SaveManager.get_gold(), 75)
	# Reload from disk via load_save
	SaveManager.load_save()
	assert_eq(SaveManager.get_gold(), 75, "Gold persists across load")

func test_add_gold_rejects_non_positive() -> void:
	SaveManager.add_gold(0)
	SaveManager.add_gold(-10)
	assert_eq(SaveManager.get_gold(), 0, "Non-positive add ignored")

func test_spend_gold_when_sufficient() -> void:
	SaveManager.add_gold(100)
	var ok := SaveManager.spend_gold(40)
	assert_true(ok)
	assert_eq(SaveManager.get_gold(), 60)

func test_spend_gold_blocks_when_insufficient() -> void:
	SaveManager.add_gold(10)
	var ok := SaveManager.spend_gold(50)
	assert_false(ok)
	assert_eq(SaveManager.get_gold(), 10, "Gold unchanged on failed spend")

func test_upgrade_level_round_trip() -> void:
	SaveManager.set_upgrade_level(&"start_hp_up", 3)
	assert_eq(SaveManager.get_upgrade_level(&"start_hp_up"), 3)
	SaveManager.load_save()
	assert_eq(SaveManager.get_upgrade_level(&"start_hp_up"), 3, "Upgrade level persists")

func test_unknown_upgrade_returns_zero() -> void:
	assert_eq(SaveManager.get_upgrade_level(&"does_not_exist"), 0)
