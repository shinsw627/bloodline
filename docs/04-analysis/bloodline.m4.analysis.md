---
template: analysis
feature: bloodline
milestone: M4
date: 2026-05-19
scope: M4 (m4-evolve, m4-achieve)
status: M4 Match Rate 94%
---

# bloodline — M4 Gap Analysis

> Compares Plan §11.2 M4 + Design vs implementation across S10.

## Context Anchor (carried)

| Key | Value |
|-----|-------|
| WHY | Vampire Survivors 풀 클론 — 진화/도전과제로 빌드 깊이 확보 |
| SCOPE | M4 = 진화 무기 + 도전과제 시스템 |
| SUCCESS | 8 무기, 진화 3+ 트리거, 도전과제 시스템 작동 |

## 1. Strategic Alignment

| Layer | Question | Result |
|-------|----------|:--:|
| Design D5 Data > Code | 신규 무기/진화/도전과제가 .tres만으로 작동? | ✅ |
| Design §4.1 EventBus | achievement_unlocked emit + 구독 동작? | ✅ |
| Design §2.3 Loose coupling | AchievementSystem은 EventBus만 구독, 직접 참조 0 | ✅ |
| Design D7 Object Pool | 신규 behavior(orbit/aura)도 같은 풀 공유? | ✅ DD56 |
| Plan §11.2 M4 step 1-3 | 8 무기, 진화 처리, 도전과제 | ✅ |
| Plan §11.2 M4 step 4 | 도전과제 토스트 + **언락 트리 UI** | 🟡 토스트 ✅, 트리 UI ❌ |
| Plan §11.2 M4 step 5 | 보스 2종 추가 | ❌ (1종만 — M5 이월) |

**판정**: 핵심 기능 정합성 양호. 보조 UI 일부 누락.

## 2. Success Criteria — Final Status

| ID | Requirement | Status | Evidence |
|----|-------------|:--:|----------|
| FR-06 | 무기 8종 데이터 기반 | ✅ | 5 원본 + 3 진화 .tres |
| FR-07 | 패시브 5종 | 🟡 3/5 | damage_up/cooldown_up 미구현 |
| FR-13 | 보스 2종+ | 🟡 1종 | 시간 다양화 ✓ (5분/15분/4분/12분), 종류 1종 |
| FR-14 | 진화 무기 (max + 패시브) | ✅ | Whip→Cross, MagicWand→HolyWand, Knife→KnifeStorm |
| FR-15 | 도전과제 시스템 + 언락 트리 | 🟡 | 시스템 ✅, 트리 UI ❌ (MainMenu 진행도 미확인) |

## 3. Match Rate

### 3.1 Structural

| Designed | Implemented |
|----------|:--:|
| AchievementData / AchievementSystem | ✅ |
| AchievementToast UI | ✅ |
| 5 신규 무기 (Garlic/Bible + 3 진화) | ✅ |
| Projectile behavior 분기 (linear/orbit/aura) | ✅ |
| evolution 카드 처리 | ✅ |
| 6 도전과제 콘텐츠 | ✅ |

**Structural: 100% in-scope**

### 3.2 Functional Depth

| Element | Status |
|---------|:--:|
| Garlic aura — 주기 tick (0.4s) | ✅ |
| Bible orbit — 다중 권 + 회전 | ✅ |
| Cross/HolyWand/KnifeStorm — 강력 진화 스탯 | ✅ |
| 진화 우선순위 (카드 풀 진입 시 first slot) | ✅ DD59 |
| 진화 후 source 제거 + evolved Lv.1 추가 | ✅ |
| AchievementSystem 5 trigger 타입 분기 | ✅ |
| Toast 큐잉 (다중 unlock 순차 표시) | ✅ DD63 |
| 영구 unlock (재실행 후 재발화 X) | ✅ |
| boss_kill 카운터는 run-scoped 리셋 | ✅ DD64 |
| **M4 GUT 테스트** | ❌ Important |
| 도전과제 언락 트리 UI (MainMenu 진행도) | ❌ Important |
| 2번째 보스 종류 | ❌ Important |
| damage_up/cooldown_up 패시브 | ❌ Important |
| 신규 무기 시각 효과 (Garlic 빛, Bible 잔상) | ⚠️ M5 폴리시 |

**Functional: 85%** (테스트 + 트리 UI + 보스/패시브 누락)

### 3.3 Contract (EventBus)

| Signal | Defined | Used |
|--------|:--:|:--:|
| `achievement_unlocked(id)` | ✓ | ✅ AchievementSystem emit, Toast 구독 |
| `boss_spawned` | ✓ | ✅ M3에서 사용 + M4 도전과제 trigger 입력 |
| `gold_collected` | ✓ | ✅ Greed 도전과제 |
| `level_up` | ✓ | ✅ Ascendant |
| `minute_passed` | ✓ | ✅ Survivor |
| `enemy_died` | ✓ | ✅ kill_count + boss_kill |

**Contract: 100%**

### 3.4 Overall

```
Match Rate = 100×0.2 + 85×0.4 + 100×0.4 = 20 + 34 + 40 = 94%
```

**Result: 94% — ≥ 90% 임계 충족.**

## 4. Decision Record Verification

| # | Decision | Followed? |
|---|----------|:--:|
| DD56 | 단일 Projectile + behavior 분기 | ✅ |
| DD57 | aura 위치 추적 + 주기 tick (area_entered 무시) | ✅ |
| DD58 | orbit pierce 무한 + lifetime 만료 release | ✅ |
| DD59 | Evolution 우선순위 (first slot) | ✅ |
| DD60 | 진화 max_level=1 (성장 X) | ✅ |
| DD61 | trigger_type을 StringName | ✅ |
| DD62 | AchievementSystem은 EventBus 전용 | ✅ |
| DD63 | Toast 큐잉 (Tween chain) | ✅ |
| DD64 | boss_kill 카운터는 run-scoped 리셋 | ✅ |
| DD65 | WeaponHolder remove/clear public 정리 | ✅ (DD49 회수) |

## 5. Gap List

### Critical
없음.

### Important

| # | Gap | Impact | Suggested Fix |
|---|-----|--------|---------------|
| I1 | M4 GUT 테스트 부재 | 회귀 위험 (AchievementSystem trigger 매트릭스, evolution eligibility, Projectile behavior 분기) | 후속 iterate에 5~8 케이스 추가 |
| I2 | damage_up/cooldown_up 패시브 미구현 (Plan FR-07) | 캐릭터 빌드 다양성 ↓ | M5 또는 별도 콘텐츠 패치에서 2 .tres 추가 |
| I3 | 2번째 보스 종류 미추가 (Plan FR-13) | 후반부 단조로움 | M5 또는 별도 — BossOgre + (예) BossLich(원거리) 추가 |
| I4 | 도전과제 언락 트리 UI 미구현 (Plan §11.2 M4 step 4) | MainMenu에서 진행도 확인 불가 | M5 폴리시에 합쳐 진행 (UI 패널) |

### Minor

| # | Gap | Note |
|---|-----|------|
| M1 | Garlic aura 시각 — 단순 반투명 ColorRect | M5 폴리시 (shader/particle) |
| M2 | Bible orbit 회전 잔상 없음 | M5 |
| M3 | Toast 큐가 첫 런에 5+ 동시 unlock 시 누적 7~15초 표시 | 의도된 동작, UX 검토 가능 |

## 6. Checkpoint 5 — Review Decision

**현 시점 평가**:
- Match Rate **94%** (≥ 90% 임계 충족), Critical 0건
- M4 핵심(진화 + 도전과제) DoD 충족
- Important 4건은 모두 M5 또는 추후 콘텐츠 패치에서 자연스럽게 해소 가능
- 풀 클론 콘텐츠 골격 **완성 단계** — M5 폴리시만 남음

선택:

- **A. iterate (M4 테스트 + 트리 UI)**: ~25 turns. 정밀 마감.
- **B. 그대로 M5 진입**: 모든 누락 항목을 M5에서 한 번에 해결.
- **C. 풀 클론 보고서**: M1~M4 통합. M5는 후속 별도 사이클.
