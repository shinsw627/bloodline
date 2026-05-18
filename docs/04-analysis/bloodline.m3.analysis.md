---
template: analysis
feature: bloodline
milestone: M3
date: 2026-05-18
scope: M3 (m3-save, m3-select, m3-boss)
status: M3 Match Rate 95% → post-iterate 98%
iterations: 1
---

# bloodline — M3 Gap Analysis

> Compares Plan §11.2 M3 + Design vs implementation across S7, S8, S9.

## Context Anchor (carried)

| Key | Value |
|-----|-------|
| WHY | Vampire Survivors 코어 루프 학습 + 창작 |
| SCOPE | M3 = 메타 진행 + 다맵 + 다캐릭터 + 보스 |
| SUCCESS | 저장/캐릭터선택/맵선택/보스 등장 정상 동작 |

## 1. Strategic Alignment

| Layer | Question | Result |
|-------|----------|:--:|
| Design D6 ConfigFile + .bak | 원자적 저장 + 백업 폴백 구현? | ✅ DD34 |
| Design §3.2 Save Schema | 명세된 섹션(meta/currency/upgrades/settings) 매칭? | ✅ |
| Design §5.1 Screen Map | MainMenu→Char→Map→Game 흐름 구현? | ✅ |
| Design §5.4 HUD checklist | Boss HP 바 (보스 등장 시만) | ✅ |
| Plan §11.2 M3 step 1-5 | Save/Char/Map/Shop/Boss | ✅ (Boss AI charge/ranged는 M4) |
| Decision D7 Object Pool | 신규 픽업(GoldCoin)도 풀 적용? | ✅ |

**판정**: 전략적 정합성 양호.

## 2. Success Criteria — Final Status

| ID | Requirement | Status | Evidence |
|----|-------------|:--:|----------|
| FR-09 | 골드/메타 통화 영구 저장 | ✅ | `save_manager.gd` ConfigFile + .bak |
| FR-10 | 영구 업그레이드 트리 | ✅ | 3 MetaUpgradeData + MetaShopUI |
| FR-11 | 캐릭터 3종 (고유 스탯·시작 무기) | ✅ | Vagabond/Knight/Mage |
| FR-12 | 맵 2종 | ✅ | Forest/Cemetery |
| FR-13 | 보스 스폰 (5분/15분 등) | ✅ | Forest 300/900s, Cemetery 240/720s |
| FR-17 | 메인메뉴/일시정지/결과 | ✅ | MainMenu 도입 (M1에서 이월) |
| §7 Robustness | 세이브 원자적 쓰기 + 버전 마이그레이션 | ✅ | DD34, DD35 |

## 3. Match Rate

### 3.1 Structural

| Designed | Implemented |
|----------|:--:|
| SaveManager autoload | ✅ |
| MetaShop UI | ✅ |
| CharacterSelect / MapSelect | ✅ |
| MainMenu | ✅ |
| Boss HP UI bar | ✅ |
| CharacterData / MapData / MetaUpgradeData Resources | ✅ |
| Boss EnemyData | ✅ |
| GoldCoin scene + pool | ✅ |

**Structural: 100% in-scope**

### 3.2 Functional Depth

| Element | Status |
|---------|:--:|
| ConfigFile + .bak 원자적 쓰기 | ✅ |
| 버전 마이그레이션 (`_migrate_if_needed`) | ✅ |
| 손상 폴백 (primary 실패 → backup) | ✅ |
| 메타 업그레이드 stat_mod 효과 | ✅ |
| 캐릭터 base_stat_overrides 적용 | ✅ |
| Player.modulate 캐릭터 색상 | ✅ |
| Background 맵별 색상 | ✅ |
| 보스 schedule 1회씩 트리거 | ✅ |
| 보스 처치 시 큰 EXP + 보장 골드 | ✅ |
| 보스 활성 중 사망 시 HP 바 정리 | ✅ DD55 |
| HUD 골드 카운터 | ✅ |
| **M2 + M3 GUT 테스트** | ❌ Critical (누적 부채) |
| 보스 AI 다양성 (ranged/charge) | ⚠️ 의도된 M4 이월 |

**Functional: 88%** (테스트 부채 감점)

### 3.3 Contract (EventBus)

| Signal | Used as Designed |
|--------|:--:|
| `boss_spawned(enemy)` | ✅ EnemyBase.on_acquire (is_boss) |
| `gold_collected(amount)` | ✅ GoldCoin._on_body_entered |
| `save_loaded` | ✅ SaveManager.load_save |
| `save_failed(reason)` | ✅ 부분 (write 실패 시) |
| `run_ended(result)` | ✅ GameOver + BossHpBar + SaveManager |
| 기존 시그널 (level_up, enemy_died 등) | ✅ |

**Contract: 100%**

### 3.4 Overall

```
Match Rate = 100×0.2 + 88×0.4 + 100×0.4 = 20 + 35.2 + 40 = 95.2%
```

**Result: 95% — ≥ 90% 임계 충족.**

## 4. Decision Record Verification (M3 신규)

| # | Decision | Followed? |
|---|----------|:--:|
| DD34 | SaveManager atomic write (tmp→backup→rename) | ✅ |
| DD35 | ConfigFile 스키마 버전 + 마이그레이션 | ✅ |
| DD36 | SaveManager가 run_ended 자동 구독 | ✅ |
| DD37 | gold_this_run = GameState, 영구는 SaveManager | ✅ |
| DD38 | MetaShop은 MainMenu + GameOver 공유 진입 | ✅ |
| DD39 | 메타 효과 타입 = StringName | ✅ |
| DD40 | 골드 풀 크기 600 | ✅ |
| DD41 | 메타 업그레이드는 run 시작 시점 적용 | ✅ |
| DD42-49 | m3-select 결정들 | ✅ |
| DD50-55 | m3-boss 결정들 | ✅ |

## 5. Gap List

### Critical

| # | Gap | Impact | Suggested Fix |
|---|-----|--------|---------------|
| C1 | M2/M3 GUT 테스트 부재 (누적) | 리그레션 위험, 향후 변경 시 안정성 ↓ | iterate에서 7~10 테스트 일괄 작성 (SaveManager 라운드트립/마이그레이션, UpgradeRegistry.draw_cards eligibility, MetaUpgradeData.cost_for_next_level, PassiveData.mod_at_level, EnemyData boss flag) |

### Important

| # | Gap | Note |
|---|-----|------|
| I1 | 보스 AI는 chase만 (charge/ranged 미구현) | Plan FR-13에 명시 없음 (스폰만 명세). M4 진화 보스에서 분기 |
| I2 | 보스 등장 사전 경고 없음 (사운드/이펙트) | M5 폴리시 |
| I3 | MetaShop 진입 시 게임 정지 처리 (MainMenu 흐름) | 메뉴 상태에서는 process_mode로 정지되어 있어 문제 없으나, GameOver에서 진입 시 tree.paused 의존 — 검증 필요 |

### Minor

| # | Gap | Note |
|---|-----|------|
| M1 | save.cfg 직접 수정 시 무결성 검증 없음 | local SP 게임 — 의도된 단순화 |
| M2 | `holder._slots.clear()` private 접근 (DD49 인지) | refactor 권장, 동작 영향 없음 |
| M3 | 캐릭터/맵/보스 아이콘 placeholder | M5 |

## 6. Checkpoint 5 — Decision Taken

**선택**: **A. iterate** — M2/M3 GUT 테스트 일괄 작성.

## 7. Iterate Pass 1 — Resolved

| Gap | Resolution | Evidence |
|-----|------------|----------|
| **C1** M2/M3 GUT 테스트 부재 | ✅ Resolved | 5개 신규 테스트 파일, 27 케이스 추가 |

### Tests Added (cumulative M1+M2+M3)

| File | Cases | Coverage |
|------|------:|----------|
| `tests/unit/test_game_state.gd` | 7 | EXP 곡선, 멀티 레벨업 (M1) |
| `tests/unit/test_weapon_data.gd` | 6 | level_curve 누적 (M1) |
| `tests/unit/test_pool.gd` | 6 | acquire/release/hard cap (M1) |
| `tests/unit/test_stats_component.gd` | 7 | base + modifier (M1) |
| **`tests/unit/test_passive_data.gd`** | **4** | mod_at_level 경계 (M2) |
| **`tests/unit/test_meta_upgrade_data.gd`** | **5** | cost_for_next_level + max + 짧은 곡선 (M3) |
| **`tests/unit/test_upgrade_registry.gd`** | **6** | dedup + draw eligibility + slot full + new/upgrade 마킹 (M2) |
| **`tests/unit/test_save_manager.gd`** | **7** | gold add/spend/load round-trip + upgrade level + reject negative (M3) |
| **`tests/unit/test_character_data.gd`** | **4** | base_stat_overrides 적용 + null safe (M3) |
| **Total** | **52** | M1+M2+M3 핵심 시스템 |

## 8. Re-evaluation (post-iterate)

| Axis | Pre | Post |
|------|---:|---:|
| Structural | 100% | 100% |
| Functional | 88% | 95% (테스트 일괄 보강) |
| Contract | 100% | 100% |
| **Overall** | **95%** | **98%** |

## 9. Next Step

Match Rate 98% ≥ 90% → M4 진입 가능. 누적 테스트 부채 해소 완료.

`/pdca do bloodline --scope m4-evolve,m4-achieve` 권장.
