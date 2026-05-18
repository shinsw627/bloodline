# Design Ref: §8.2 L1 #1 #2 — EXP curve + multi level-up.
# Plan SC: FR-04 EXP system correctness.
extends GutTest

func before_each() -> void:
	GameState.reset_run()

func test_exp_to_next_level_1() -> void:
	assert_eq(GameState.exp_to_next(1), 5, "Level 1 → next is 5 EXP")

func test_exp_to_next_level_3() -> void:
	assert_eq(GameState.exp_to_next(3), 11, "Level 3 → next is 5 + 2*3 = 11 EXP")

func test_add_exp_single_level_up() -> void:
	GameState.add_exp(5)
	assert_eq(GameState.current_level, 2, "5 EXP from L1 triggers L2")
	assert_eq(GameState.current_exp, 0, "Remainder is 0")

func test_add_exp_multi_level_up_single_frame() -> void:
	# 5 (L1→L2) + 8 (L2→L3) + 11 (L3→L4) = 24
	GameState.add_exp(24)
	assert_eq(GameState.current_level, 4, "24 EXP from L1 jumps to L4 in one call")
	assert_eq(GameState.current_exp, 0, "Remainder is 0 after triple level up")

func test_add_exp_with_remainder() -> void:
	GameState.add_exp(7)
	assert_eq(GameState.current_level, 2, "5 of 7 used for L1→L2")
	assert_eq(GameState.current_exp, 2, "2 EXP remainder")

func test_add_exp_ignored_when_not_running() -> void:
	GameState.end_run("test")
	GameState.add_exp(100)
	assert_eq(GameState.current_level, 1, "EXP ignored after run ended")
	assert_eq(GameState.current_exp, 0, "No EXP accumulated")

func test_run_time_advances_in_process() -> void:
	GameState.reset_run()
	GameState._process(0.5)
	GameState._process(0.7)
	assert_almost_eq(GameState.run_time, 1.2, 0.001, "run_time accumulates delta")
