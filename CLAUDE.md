# bloodline — Project Context for AI Collaboration

> Godot 4 Vampire Survivors-style roguelike survival game.
> Read this file at session start to align with project conventions and current state.

## Project Snapshot

- **Engine**: Godot 4.3+ (Compatibility renderer)
- **Language**: GDScript (no C#)
- **Target (v1.0)**: Desktop only — Win / Mac / Linux. Mobile is v2.0 (separate PDCA cycle).
- **Architecture**: Pragmatic (Option C from Design §2) — Composition + EventBus + Resource(.tres) + Object Pool

## PDCA Documents (read in this order)

| Phase | Path |
|-------|------|
| Plan | `docs/01-plan/features/bloodline.plan.md` |
| Design | `docs/02-design/features/bloodline.design.md` |
| Conventions | `docs/01-plan/conventions.md` |
| Do log | `docs/03-implementation/bloodline.do.md` |
| Analysis | `docs/04-analysis/bloodline.analysis.md` |

## Current Milestone

**M1: Core Loop — COMPLETE** (S2~S4)
- Player movement (8-direction InputMap)
- Auto-attack (nearest enemy targeting)
- Enemy spawn (time-ramped interval)
- Object Pool (Enemy 800, Projectile 400, ExpGem 1000)
- EXP collection + level-up + HUD + GameOver UI

**Next**: M2 — LevelUpUI (3-card pick) + 무기/패시브 콘텐츠 확장

## Architecture Cheatsheet

### Autoloads (singletons)
- `EventBus` (scripts/autoload/event_bus.gd) — 19-signal catalog for cross-system events
- `GameState` (scripts/autoload/game_state.gd) — current-run state (run_time, kills, level, exp)

### Service Locator (via groups)
- `projectile_pool`, `enemy_pool`, `exp_gem_pool` — Pool instances accessible by `get_tree().get_first_node_in_group(...)`
- `player`, `enemy`, `exp_gem` — entity groups for queries

### Object Pool contract
Pooled scenes must implement:
- `func on_acquire(args: Dictionary)` — setup when reused
- `func on_release()` — reset transient state
- `signal released` — emit to auto-return to pool

### Data > Code
- Weapon/Enemy balancing → `.tres` files in `resources/`
- Logic only in `.gd` files

### Cross-system communication
- **EventBus signal**: when crossing system boundaries (Enemy → UI, Pickup → GameState)
- **Local signal**: same-scene parent-child (Button.pressed)
- **Direct call**: within same actor (Player → WeaponHolder)

## Conventions (see conventions.md for full)

| Item | Rule |
|------|------|
| Files | `snake_case.gd` / `snake_case.tscn` |
| Nodes | `PascalCase` |
| Classes | `class_name PascalCase` |
| Functions/vars | `snake_case` |
| Constants | `UPPER_SNAKE_CASE` |
| Signals | `snake_case`, past-tense (`enemy_died`) |
| Resources | `PascalCase_id.tres` (e.g., `Whip.tres`) |

## When Adding a New Feature

1. Plan/Design 문서에 명세 추가 (또는 `/pdca plan {feature}`)
2. Resource(.tres) 정의가 필요한가? 데이터 vs 로직 분리 원칙
3. Pool 사용해야 하는가? 빈번 생성/소멸 객체면 YES
4. EventBus 시그널 추가 시 Design §4.1 카탈로그 갱신 + Decision Record 기록
5. 새 Module이 Design §11.3 Module Map에 있는가? 세션 분할 권장
6. `/pdca do {feature} --scope <module-key>` 로 한 모듈씩 진행

## Performance Targets (Plan §3.2)

| Metric | Target |
|--------|--------|
| Desktop FPS @ 1080p | ≥ 60 |
| 적 500체 동시 | ≥ 55 FPS |
| RAM | < 500 MB |
| Build size | < 200 MB |

성능 측정: Godot Monitor (Debugger → Monitors → fps, video.video_mem) + `--print-fps` flag.

## Git

- 커밋 규칙: `[타입] 한 줄 요약` + bullet 변경사항 + 특이사항
- 타입: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- 브랜치: `main` (현재 원격 없음, 로컬 only)
- 사용자: `shinsw627 <shinsw627@naver.com>`
- Claude Co-Author trailer **금지** (`.claude/skills/commit/SKILL.md` 규약)

## Known TODOs / Tech Debt

- [x] ~~GUT 테스트 셋업~~ — addons/gut/SETUP_INSTRUCTIONS.md 참조, 테스트 4개 작성 완료
- [x] ~~conventions.md~~ — docs/01-plan/conventions.md 작성 완료
- [ ] icon.svg는 placeholder — M5 폴리시에서 교체
- [ ] 60 FPS @500 적 실측 미수행 (사용자 액션 필요)
- [ ] M2 콘텐츠 (LevelUpUI, 무기 3종, 패시브 3종)

## How to Run

1. Godot 4.3+ 에디터 실행
2. `/Users/sws/bloodline` 폴더 Import
3. F5 → Main 씬 자동 로드
4. WASD/화살표/패드 좌스틱 = 이동, ESC = 일시정지
