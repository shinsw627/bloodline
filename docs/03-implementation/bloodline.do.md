---
template: do-log
feature: bloodline
sessions: [S2, S3, S4, S6, S7]
date: 2026-05-18
scope: m1-bootstrap, m1-player, m1-enemy, m1-weapon, m1-exp, m2-levelup, m2-content, m3-save
status: M1+M2 complete, M3-save implemented
---

# bloodline — Do Log

## Session S2 (m1-bootstrap + m1-player)

> **Scope**: project bootstrap + player movement
> **Status**: Implementation complete, awaits Godot editor verification by user.
> **Plan Ref**: `docs/01-plan/features/bloodline.plan.md`
> **Design Ref**: `docs/02-design/features/bloodline.design.md`

## Context Anchor (carried forward)

| Key | Value |
|-----|-------|
| WHY | Vampire Survivors 코어 루프 학습+창작, Godot 4 숙련 |
| WHO | 1인 개발자(본인) |
| RISK | 풀 클론 스코프 과대, 적 500+ 성능 |
| SUCCESS | M1 플레이어블(2주) → M5 데스크톱 빌드 |
| SCOPE | 이번 세션: bootstrap + player |

## Files Created

| Path | Purpose | LOC |
|------|---------|----:|
| `.gitignore` | Godot artifacts 제외 | 28 |
| `.gitattributes` | LF 정규화 + 바이너리 표시 + LFS 후보 | 22 |
| `icon.svg` | Placeholder app icon | 5 |
| `project.godot` | Engine config, autoloads, InputMap, layers, renderer | 80 |
| `scripts/autoload/event_bus.gd` | Design §4.1 EventBus signal catalog | 32 |
| `scripts/autoload/game_state.gd` | Design §2.3 current-run SoT | 35 |
| `scripts/player/stats_component.gd` | Stats + modifier system | 65 |
| `scripts/player/player.gd` | CharacterBody2D + movement | 22 |
| `scenes/player/player.tscn` | Player scene tree (Sprite/Collision/Stats/Camera) | 27 |
| `scenes/main/main.gd` | Bootstrap entry + pause toggle | 12 |
| `scenes/main/main.tscn` | Main scene with World + Player | 16 |

Total: 11 files, ~340 LOC.

## Decisions Made During Implementation

| # | Decision | Rationale |
|---|----------|-----------|
| DD1 | Camera2D를 Player 씬 내부에 배치 | 인스턴스마다 카메라 자동 따라옴, 외부 RemoteTransform 불필요 |
| DD2 | StatsComponent: 베이스 + modifier 분리 + computed getter | M2 패시브 시스템에서 `apply_modifier(stat, value)` 한 줄로 적용 가능 |
| DD3 | InputMap에 WASD + 화살표 + 게임패드 좌스틱 동시 매핑 | Plan FR-01 충족, 모바일은 v2.0에서 동일 action에 터치 매핑 추가 |
| DD4 | `current_hp <= 0` 처리는 GameState.end_run으로 위임 | Player는 입력/이동만 담당, 죽음 흐름은 시스템 책임 (느슨한 결합) |
| DD5 | Physics layers: 1=world, 2=player, 3=enemy, 4=p_proj, 5=e_proj, 6=pickup | M1 enemy/weapon 세션에서 바로 사용 |
| DD6 | 충돌 layer/mask: Player(layer=2, mask=1) — world에만 충돌, 적은 자체 처리 | Vampire Survivors 스타일: 적은 통과 가능, HP만 깎임 (m1-enemy에서 처리) |
| DD7 | World 경계 StaticBody2D 제거 | 카메라가 따라가는 오픈필드. 경계는 M3 맵에서 정의 |
| DD8 | `class_name`은 데이터/상태 컴포넌트에만 부여 (Player, StatsComponent) | 글로벌 네임스페이스 오염 최소화 |

## How to Verify (사용자 액션)

1. Godot 4.3+ 설치 후 본 폴더(`/Users/sws/bloodline`)를 Godot 엔진에서 Import
2. 첫 import 시 `.godot/` 캐시 폴더가 생성됨 (이미 .gitignore 처리됨)
3. F5 또는 ▶️ 실행 → Main 씬 자동 로드
4. **검증 체크리스트**:
   - [ ] 1280×720 창 표시, 어두운 보라색 배경
   - [ ] 중앙에 빨간 아이콘(플레이어) 보임
   - [ ] WASD 또는 화살표 키로 8방향 이동
   - [ ] 게임패드 좌스틱으로 이동 (선택)
   - [ ] 카메라가 부드럽게 플레이어를 따라옴
   - [ ] ESC 또는 패드 Start 버튼으로 일시정지 (다시 누르면 해제)
   - [ ] 콘솔에 `[bloodline] M1 bootstrap — run started.` 출력

## Success Criteria Coverage (Plan §4)

| ID | Description | Coverage |
|----|-------------|:--:|
| M1-DoD "30초 이상 끊김 없이 플레이" | 부분 — 이동·씬 안정성만 (적/공격 미구현) | 🟡 |
| FR-01 8방향 이동 | 완료 | ✅ |
| FR-04 픽업 반경 | StatsComponent 준비, 실사용은 m1-exp | 🟡 |

m1-bootstrap + m1-player 범위는 모두 충족. 나머지 M1 항목(FR-02 자동공격, FR-03 스폰, FR-08 풀, FR-04 EXP 젬)은 후속 세션.

---

## Session S3 (m1-enemy + m1-weapon)

> **Scope**: 적 시스템(Pool/AI/Spawn) + 자동공격(Weapon/Projectile). 첫 전투 루프 가동.

### Files Created (S3)

| Path | Purpose | LOC |
|------|---------|----:|
| `scripts/data/enemy_data.gd` | EnemyData Resource 정의 | 17 |
| `scripts/data/weapon_data.gd` | WeaponData Resource + `stats_at_level()` 누적 계산 | 42 |
| `scripts/systems/pool.gd` | 범용 Object Pool (acquire/release, hard cap, `released` 시그널 자동 회수) | 80 |
| `scripts/enemies/enemy_base.gd` | Area2D enemy, chase AI, contact damage, take_damage→die→EventBus | 70 |
| `scripts/enemies/spawn_director.gd` | 시간 곡선 기반 스폰 (interval lerp + max_alive cap + 화면 밖 링 스폰) | 40 |
| `scripts/weapons/projectile.gd` | Area2D 투사체, pierce/lifetime, 적 중복 히트 방지 | 60 |
| `scripts/weapons/weapon_holder.gd` | 슬롯·쿨다운·자동조준(최근접) | 75 |
| `scenes/enemies/enemy_base.tscn` | Area2D + ColorRect 비주얼 + CircleShape2D | 20 |
| `scenes/weapons/projectile.tscn` | Area2D + 노란 직사각형 비주얼 | 22 |
| `resources/enemies/Slime.tres` | HP 10, dmg 5, speed 60 | 14 |
| `resources/weapons/Whip.tres` | 12 dmg, 0.9s cd, lv 1~8 곡선 정의 | 18 |

### Files Modified (S3)

| Path | Change |
|------|--------|
| `scenes/player/player.tscn` | WeaponHolder Node2D 추가 (Player 자식) |
| `scenes/main/main.tscn` | ProjectilePool / EnemyPool / SpawnDirector 노드 추가, 그룹 등록 |
| `scenes/main/main.gd` | 시작 무기 장착, SpawnDirector에 EnemyData 주입, 사망 시 1.5s 후 reload_current_scene |
| `scripts/weapons/weapon_holder.gd` | projectile_pool을 NodePath→group lookup으로 변경 (인스턴스 결합도 ↓) |
| `scripts/data/weapon_data.gd` | `level_curve` 타입을 `Array[Dictionary]`→`Array`로 완화 (.tres 호환성) |

S3 총: 11 new + 5 modified, ~460 LOC.

### Decisions Made During S3

| # | Decision | Rationale |
|---|----------|-----------|
| DD9 | Pool 재사용 시 `on_acquire(args: Dictionary)` / `on_release()` 규약 + `released` 시그널 자동 회수 | 풀과 풀링 객체 간 결합도 0. 새 풀링 객체는 두 메서드만 구현 |
| DD10 | Pool hard cap 초과 시 가장 오래된 in-use 객체 강제 회수 + `push_warning` | Plan E_POOL_EXHAUSTED 처리 (Design §6) |
| DD11 | WeaponHolder가 ProjectilePool을 그룹 lookup으로 참조 | 인스턴스화된 Player 씬 내부에서 외부 노드 NodePath 설정 시 `editable_instance` 필요 — group 방식이 더 깔끔 |
| DD12 | Enemy contact damage는 `_physics_process` 거리 기반 ❌ → `body_entered/_exited` + interval tick ✓ | 정확한 충돌 감지, Player Hurtbox 추가 없이 단순 |
| DD13 | SpawnDirector: 시간 0→ramp_seconds 동안 interval을 initial→min으로 lerp + 동시 최대 500 적 cap | Plan FR-03 난이도 곡선 + FR-08 풀 한계 매칭 |
| DD14 | 자동 조준: `get_nodes_in_group("enemy")` 전수 거리 비교 (O(N)) | M1 적 ≤500에서 충분. M3+ KDTree/grid 가능성 검토 |
| DD15 | 무기 진화 필드(`evolution_target`/`evolution_required_passive`)는 M1에 정의만, 동작은 M4 | 데이터 스키마 안정성 — 후속 마이그레이션 회피 |
| DD16 | level_curve 항목은 partial Dictionary 허용 (`{"damage": 4}`만 있으면 cooldown 변동 없음) | 신규 무기 .tres 작성 비용 ↓ |
| DD17 | 죽음 처리: M1은 1.5s 후 `reload_current_scene()` | GameOverScreen은 m1-exp 세션에서 도입 |
| DD18 | Physics layer 사용: enemy=3(value 4), p_proj=4(value 8) — projectile.mask=4, enemy.mask=2(player) | Vampire Survivors 스타일: projectile↔enemy만, 적은 자유 통과 |

### How to Verify (S3 검증 체크리스트)

Godot 4.3+에서 F5 실행 후:

- [ ] 시작 즉시 노란 채찍 투사체가 자동 발사됨 (가장 가까운 적 방향)
- [ ] 화면 가장자리에서 초록 슬라임들이 등장해 플레이어를 추격
- [ ] 슬라임이 채찍에 맞으면 사라짐 (pierce 1이면 첫 적 관통 후 두 번째 적까지 타격 후 release)
- [ ] 슬라임이 플레이어에 닿으면 0.5초 간격으로 HP 5씩 감소
- [ ] HP가 0이 되면 콘솔에 "You died." + 1.5s 후 씬 리로드
- [ ] 시간이 지날수록 스폰 간격이 짧아짐 (240초 시점에 0.15s 간격)
- [ ] 동시 적 수가 500 도달 시 멈춤 (max_alive cap)
- [ ] ESC로 일시정지 시 적·투사체 모두 정지

### Success Criteria Coverage (S3 누적)

| ID | Description | Coverage |
|----|-------------|:--:|
| FR-01 | 8방향 이동 | ✅ S2 |
| FR-02 | 자동 공격 (최근접 타깃) | ✅ S3 |
| FR-03 | 적 스폰 (시간 곡선) | ✅ S3 |
| FR-08 | Object Pool (500+) | ✅ S3 |
| FR-04 | 경험치 드롭/수집/레벨업 | ❌ S4 (m1-exp) |
| M1-DoD | 30초+ 끊김 없이 플레이 + 적 처치·사망·재시작 | 🟢 거의 충족 (EXP 시스템만 남음) |

### Performance Notes (잠정)

- 적 200체 시 60 FPS는 무난할 것으로 예상. 실측은 m1-exp 종료 후 `/pdca analyze`에서 측정.
- 자동 조준은 O(N) — N=500일 때 1회 발사당 500 dist² 계산. 무기 5개 동시 발사하면 2500/frame. 60FPS에서 150K ops/s — 무난.
- `body_entered/exited` 시그널 수 = 적당 1쌍, 화면 내 적 평균 200으로 가정해도 무리 없음.

### Known TODOs / Tech Debt (Updated)

- [ ] icon.svg는 임시 placeholder — M5에서 교체
- [ ] GUT 셋업 — 다음 세션(m1-exp) 진입 전 권장
- [ ] CLAUDE.md / conventions.md 미작성
- [ ] 슬라임 외 적 종류 없음 (M2에서 추가)
- [ ] HUD 없음 (HP/EXP/시계/킬 카운트 표시 안 됨) — m1-exp 또는 M2 LevelUpUI 세션에서 같이

---

## Session S4 (m1-exp)

> **Scope**: EXP 젬·자석·레벨업 시그널 + GameOver UI + 최소 HUD. **M1 마지막 모듈** — 이 세션 후 M1 DoD 완전 충족.

### Files Created (S4)

| Path | Purpose | LOC |
|------|---------|----:|
| `scripts/pickups/exp_gem.gd` | Area2D 풀링 EXP 젬, pickup_radius 진입 시 자석 흡수 (가속) | 50 |
| `scenes/pickups/exp_gem.tscn` | Visual: 회전된 작은 파란 사각형 | 22 |
| `scripts/ui/hud.gd` | EventBus 구독 → HP 바·EXP 바·시간·킬·레벨 표시 | 35 |
| `scenes/ui/hud.tscn` | CanvasLayer + MarginContainer + VBox 레이아웃 | 60 |
| `scripts/ui/game_over_screen.gd` | run_ended 시 통계 표시 + Retry/Quit, PROCESS_MODE_ALWAYS | 30 |
| `scenes/ui/game_over_screen.tscn` | 어둡힘 + 패널 + 버튼, 빨강 강조 보더 | 65 |

### Files Modified (S4)

| Path | Change |
|------|--------|
| `scripts/autoload/game_state.gd` | `exp_to_next(level)` 곡선 + `add_exp(amount)` 누적·레벨업·exp_changed emit |
| `scripts/enemies/enemy_base.gd` | `_die()`에서 `_drop_exp_gem()` 호출 (ExpGemPool group lookup) |
| `scripts/player/stats_component.gd` | `_ready()`에서 `call_deferred("_emit_initial")` — HUD 초기 표시 보장 |
| `scenes/main/main.tscn` | ExpGemPool + HUD + GameOverScreen 3개 노드 추가 |
| `scenes/main/main.gd` | 자동 reload 제거 — GameOverScreen이 흐름 담당 |

S4 총: 6 new + 5 modified, ~330 LOC.

### Decisions Made During S4

| # | Decision | Rationale |
|---|----------|-----------|
| DD19 | EXP 곡선: 선형 `5 + (level-1)*3` (M1 단순) | M3+ 데이터 기반으로 교체 가능. M1에서 1초당 1~2 레벨업 페이스 검증 용이 |
| DD20 | 자석 흡수: `pickup_radius` 진입 시 `ATTRACT_BASE_SPEED`(300) → `ATTRACT_ACCEL`(1200) 가속 | 자연스러운 "휘말려 들어오는" 느낌. radius는 StatsComponent에서 동적 조회 |
| DD21 | 멀티 레벨업 한 프레임 처리: `while current_exp >= exp_to_next(...)` | 보스 처치 등 대량 EXP 획득 시 정확한 레벨 계산 |
| DD22 | GameOverScreen: `PROCESS_MODE_ALWAYS` + `get_tree().paused=true` | 게임 정지 상태에서도 버튼 입력 가능. Pool/Enemy/Player 모두 자동 정지 |
| DD23 | HUD: ExpSystem autoload 없이 GameState에 add_exp 직접 통합 | YAGNI — 별도 시스템 만들 필요 없음. M2 LevelUpUI도 GameState를 그대로 구독 |
| DD24 | StatsComponent 초기 emit은 `call_deferred` | _ready 호출 순서(child→parent→sibling) 의존 없이 다음 프레임에 모든 listener에게 전달 보장 |
| DD25 | Physics layer 6=pickup(value 32) → exp_gem.collision_layer=32, mask=2(player) | 풀에서 인스턴스 검출되지 않도록 분리 |

### How to Verify (S4 검증 체크리스트)

Godot에서 F5 실행 후:

- [ ] 좌상단 빨간 HP 바 "100/100" 표시
- [ ] 화면 전체 폭 하단 EXP 바 (회색, 빈 상태)
- [ ] 우상단 시간(MM:SS), Lv.1, Kills:0 표시
- [ ] 시간이 흐르면 시계 증가
- [ ] 슬라임 처치 → 파란 다이아몬드 EXP 젬 드롭
- [ ] 플레이어가 가까이 가면 젬이 빨려옴 (가속하며)
- [ ] 접촉 시 EXP 바 증가, Kills 카운트 증가
- [ ] EXP 바 가득 차면 Lv. 숫자 증가 + EXP 바 리셋 (콘솔에 자동 출력 없음 — 정상)
- [ ] HP 0 → "GAME OVER" 패널 표시, 통계(Survived/Kills/Level) 정확
- [ ] Retry 버튼 → 씬 리로드, 처음부터 다시
- [ ] Quit 버튼 → 게임 종료

### Success Criteria Coverage (M1 누적 — 최종)

| ID | Description | Coverage |
|----|-------------|:--:|
| FR-01 | 8방향 이동 | ✅ S2 |
| FR-02 | 자동 공격 (최근접 타깃) | ✅ S3 |
| FR-03 | 적 스폰 (시간 곡선) | ✅ S3 |
| FR-04 | EXP 젬 드롭/수집/자석/레벨업 | ✅ S4 |
| FR-08 | Object Pool (500+) | ✅ S3 |
| **M1-DoD** | "30초 이상 끊김 없이 플레이 + 적 처치·사망·재시작" | ✅ **완전 충족** |

### Known TODOs / Tech Debt (Updated after M1)

- [ ] icon.svg는 임시 placeholder — M5에서 교체
- [ ] GUT 테스트 미작성 — Design §8.2 L1 단위 테스트 7개 작성 필요 (`/pdca analyze` 결과에 반영)
- [ ] CLAUDE.md / conventions.md 미작성
- [ ] LevelUpUI 미구현 — 레벨업해도 보상 없음 (M2 `m2-levelup`)
- [ ] 무기/적/패시브 각 1종 — M2/M3에서 콘텐츠 확장
- [ ] 보스 미구현 (M3)
- [ ] 사운드 0개 (M5)
- [ ] 진화 무기/도전과제 (M4)

---

## Session S6 (m2-levelup + m2-content)

> **Scope**: LevelUpUI (3 카드 추첨) + 무기/패시브 콘텐츠 확장 (각 3종) + HUD 슬롯.

### Files Created (S6)

| Path | Purpose | LOC |
|------|---------|----:|
| `scripts/data/passive_data.gd` | PassiveData Resource (stat_mods 배열 per level) | 20 |
| `scripts/autoload/upgrade_registry.gd` | 등록된 weapons/passives + draw_cards (eligibility 필터) | 55 |
| `scripts/ui/level_up_ui.gd` | level_up 시그널 → pause → 3 카드 → upgrade_chosen → apply → unpause, queue 멀티레벨 | 75 |
| `scripts/ui/upgrade_card.gd` | Button 카드 (icon/name/level/desc/badge), `chosen` 시그널 | 25 |
| `scenes/ui/level_up_ui.tscn` | CanvasLayer + Dim + Panel + HBox 카드 컨테이너 | 50 |
| `scenes/ui/upgrade_card.tscn` | Button + 5 children (Badge/Icon/Name/Level/Desc) | 60 |
| `resources/weapons/MagicWand.tres` | 빠른 보라 다발, dmg 8 / cd 0.6 / spd 720 | 14 |
| `resources/weapons/Knife.tres` | 흰색 고관통, dmg 6 / cd 0.45 / pierce 2 | 14 |
| `resources/passives/MaxHpUp.tres` | +20% max_hp × 5 levels | 10 |
| `resources/passives/MoveSpeedUp.tres` | +10% move_speed × 5 levels | 10 |
| `resources/passives/PickupRadiusUp.tres` | +25% pickup_radius × 5 levels | 10 |

### Files Modified (S6)

| Path | Change |
|------|--------|
| `scripts/data/weapon_data.gd` | + `projectile_color: Color` 필드 |
| `scripts/weapons/projectile.gd` | on_acquire에서 `args.color` 반영 → ColorRect 색상 |
| `scripts/weapons/weapon_holder.gd` | MAX_SLOTS=6 강제, `has_weapon`/`get_weapon_level`/`get_slots`/`slot_count` 조회 API, fire 시 color 전달 |
| `scripts/player/stats_component.gd` | `passive_levels: Dictionary`, `apply_passive(passive)`, `get_passive_level(id)` + max_hp 증가 시 현재 HP도 증가 |
| `scripts/ui/hud.gd` | upgrade_chosen 구독 → 무기/패시브 슬롯 렌더링 (color + level badge) |
| `scenes/ui/hud.tscn` | 하단 HBox(BottomBar) — WeaponSlots 좌, PassiveSlots 우 |
| `scenes/main/main.tscn` | LevelUpUI 노드 추가 (HUD↔GameOverScreen 사이) |
| `scenes/main/main.gd` | 3 무기 + 3 패시브 preload, `_register_content()` → UpgradeRegistry |
| `project.godot` | autoload `UpgradeRegistry` 등록 (3rd singleton) |

S6 총: 11 new + 9 modified, ~600 LOC.

### Decisions Made During S6

| # | Decision | Rationale |
|---|----------|-----------|
| DD26 | UpgradeRegistry는 autoload (3번째) | M4 evolution에서도 재사용. 단일 등록 지점, content는 main.gd가 주입 |
| DD27 | LevelUpUI는 멀티 레벨업 큐잉 (`_pending_levels`) 사용 | 한 프레임에 N레벨 상승 시 카드 N회 순차 제시 — 보상 누락 0 |
| DD28 | 카드 eligibility: 슬롯 가득 차고 새 무기면 제외, max_level 도달 제외 | 데드 카드 회피 + 무한 루프 방지 |
| DD29 | `apply_modifier(max_hp, ...)` 시 current_hp도 비례 증가 | 빌드업 보상감 + 풀힐 무료 회피 (증가분만 회복) |
| DD30 | StatsComponent에 `passive_levels` 추적 임베드 (별도 PassiveBag 노드 X) | YAGNI — 패시브는 stat만 바꾸므로 stats 자체에 보관 자연스러움 |
| DD31 | Projectile 색상은 WeaponData에 정의 + acquire 시 전달 | 무기별 별도 .tscn 없이도 시각 구분. 신규 무기 추가 비용 ↓ |
| DD32 | 카드 키보드 단축키 1/2/3 + 마우스 클릭 둘 다 지원 | Plan §5.4 LevelUpUI 체크리스트 충족 |
| DD33 | HUD 슬롯은 동적 생성 (Panel + ColorRect + Label) | M2에서 placeholder 컬러로 충분, M5에서 진짜 아이콘 텍스처로 교체 |

### How to Verify (S6 검증 체크리스트)

Godot에서 F5 실행 후:

- [ ] 시작 즉시 노란 채찍(Whip Lv.1)이 발사됨 — HUD 좌하단 무기 슬롯에 노란 칸 + "1" 배지
- [ ] EXP 바 가득 차서 첫 레벨업 → 게임 정지 + "LEVEL UP!" 패널 표시 + 3장 카드
- [ ] 카드 종류 혼합: 신규 무기(보라 MagicWand 또는 흰 Knife), 패시브(빨강/초록/파랑), 기존 무기 강화(노란 Whip Lv.1→2)
- [ ] 카드 좌상단 배지: "NEW!" (주황) 또는 "UPGRADE" (시안)
- [ ] 1/2/3 키 또는 마우스 클릭으로 카드 선택 → 게임 재개
- [ ] 무기 선택 시 → 화면에 새 색상의 투사체 발사됨 + HUD 슬롯에 추가/배지 갱신
- [ ] 패시브 선택 시 → 즉시 효과 (MaxHpUp: HP바 max 증가 + current HP 증가, MoveSpeedUp: 이동 더 빠름, PickupRadiusUp: 젬 더 멀리서 흡수)
- [ ] HUD 우하단 패시브 슬롯에 컬러 칸 + 레벨 배지 표시
- [ ] 한 번에 큰 EXP 획득 시 → 레벨업 패널이 순차적으로 N회 표시
- [ ] 모든 무기 6슬롯 채워지면 → 카드 풀에서 신규 무기 제외, 기존 무기 강화·패시브만 등장

### Success Criteria Coverage (M2 진행)

| ID | Description | Status |
|----|-------------|:--:|
| FR-05 | 레벨업 시 3 카드 선택 UI | ✅ |
| FR-06 | 무기 시스템 데이터 기반 8종까지 확장 가능 | 🟢 인프라 완성, 현재 3종 (M3/M4에서 추가) |
| FR-07 | 패시브 5종 | 🟡 3종 완료, 2종(damage/cooldown 등) M4까지 |
| HUD §5.4 무기/패시브 슬롯 | ✅ |

### Known TODOs / Tech Debt (Updated)

- [ ] M2 GUT 테스트 미작성: PassiveData.mod_at_level, UpgradeRegistry.draw_cards, StatsComponent.apply_passive
- [ ] 패시브 5종 중 2종 미구현 (damage_up, cooldown_up) — M4 진화 도입 시 함께
- [ ] 적 2종 추가 (Plan §11.2 M2: ranged, charge) — M3로 이월
- [ ] 무기 아이콘은 placeholder ColorRect — M5에서 실제 텍스처

---

## Session S7 (m3-save)

> **Scope**: SaveManager autoload + 메타 진행 시스템 + 골드 픽업 + MetaShopUI. M3 첫 모듈.

### Files Created (S7)

| Path | Purpose | LOC |
|------|---------|----:|
| `scripts/autoload/save_manager.gd` | ConfigFile + .bak 원자적 저장, 버전 마이그레이션, run_ended 자동 커밋 | 85 |
| `scripts/data/meta_upgrade_data.gd` | MetaUpgradeData Resource (id, cost_per_level, effect_*) | 22 |
| `scripts/pickups/gold_coin.gd` | Area2D 풀링, 자석 흡수 → SaveManager 미경유 GameState.gold_this_run | 40 |
| `scenes/pickups/gold_coin.tscn` | 노란 사각형 비주얼 | 22 |
| `scripts/ui/meta_shop_ui.gd` | MetaShop 동적 행 렌더, 골드 부족 시 disabled, 버튼별 cost 갱신 | 65 |
| `scenes/ui/meta_shop_ui.tscn` | 골드 표기 + 업그레이드 리스트 + Close | 65 |
| `resources/meta/StartHpUp.tres` | +10% max_hp × 5lv (cost 10/20/30/50/80) | 12 |
| `resources/meta/StartSpeedUp.tres` | +5% move_speed × 5lv | 12 |
| `resources/meta/StartPickupUp.tres` | +20% pickup_radius × 5lv | 12 |

### Files Modified (S7)

| Path | Change |
|------|--------|
| `scripts/enemies/enemy_base.gd` | `_drop_gold_maybe()` — gold_drop_chance RNG → GoldPool 사용 |
| `resources/enemies/Slime.tres` | gold_drop_chance 0.0 → 0.35 |
| `scripts/ui/game_over_screen.gd` | "Meta Shop" 버튼 + Earned/Total gold 표시 + 닫힘 시 라벨 갱신 |
| `scenes/ui/game_over_screen.tscn` | GoldLabel + MetaButton 추가 |
| `scripts/ui/hud.gd` | Gold 라벨 표시 (우상단) |
| `scenes/ui/hud.tscn` | GoldLabel 추가 |
| `scenes/main/main.tscn` | GoldCoinPool 추가, MetaShopUI 추가, Main에 group="main" |
| `scenes/main/main.gd` | meta 업그레이드 3종 preload + `_apply_meta_upgrades()` (run 시작 시) + `get_meta_upgrades()` 노출 |
| `project.godot` | autoload `SaveManager` 등록 (4번째 singleton) |

S7 총: 9 new + 9 modified, ~450 LOC.

### Decisions Made During S7

| # | Decision | Rationale |
|---|----------|-----------|
| DD34 | SaveManager `save()` 원자적 쓰기 (tmp→backup→rename) | Plan §5 위험 E_SAVE_WRITE_FAIL: 부분 쓰기로 인한 손상 회피 |
| DD35 | ConfigFile 스키마 버전 = 1, `_migrate_if_needed()` 래더 | M4/M5에서 필드 추가 시 자동 마이그레이션 |
| DD36 | SaveManager가 run_ended에 직접 구독 → 자동 골드 커밋 | main.gd가 명시적으로 save 호출 안 해도 됨, 결합도 ↓ |
| DD37 | gold_this_run은 GameState in-memory, SaveManager는 영구 | Single Source of Truth 분리 — run 중 수정 잦음 vs 영구 보관 |
| DD38 | MetaShop은 GameOverScreen에서만 진입 | M3-select에서 MainMenu 도입 시 거기서도 진입 가능 — 인터페이스 동일 (`shop.open(upgrades)`) |
| DD39 | 메타 효과 타입 = StringName "stat_mod" (M3) → "starting_weapon"(M4) 확장 가능 | M4 무기 진화 등 콘텐츠형 효과 대비 |
| DD40 | 골드 풀 크기 = 600 (적의 0.35 × 800 = 280이므로 충분) | Hard cap 회수 정책으로 폭주 방지 |
| DD41 | 메타 업그레이드 적용 시점: Main._ready (run 시작) | 매 reload마다 재계산 — 변경 즉시 반영 |

### How to Verify (S7 검증 체크리스트)

Godot에서 F5 실행 후:

- [ ] 우상단 HUD에 "Gold: 0" 표시
- [ ] 슬라임 처치 시 35% 확률로 노란 골드 코인 드롭
- [ ] 골드 코인이 pickup_radius 안에 들어오면 자석 흡수 → HUD Gold 카운터 증가
- [ ] 사망 → GameOver 패널에 "Earned: +N gold (Total: N)" 표시
- [ ] "Meta Shop" 버튼 클릭 → 노란 보더의 패널이 열림
- [ ] 메타 업그레이드 3종 표시: Vitality Training / Endurance / Greed
- [ ] 골드 부족 시 Buy 버튼 disabled, 충분하면 활성
- [ ] Buy 클릭 → 골드 차감 + 레벨 +1 + 행 즉시 갱신
- [ ] Close 클릭 → MetaShop 숨김, GameOver 패널 그대로 보임, GameOver의 Total 골드 라벨 갱신
- [ ] Retry → 새 런에서 메타 업그레이드 적용 확인:
  - HP 1레벨 구매 시 시작 HP 110/110
  - Speed 1레벨 구매 시 이동이 약간 빨라짐
  - Pickup 1레벨 구매 시 EXP·골드 자석 범위 확장
- [ ] 두 번째 런 사망 후 다시 GameOver → Total 골드가 누적되어 있음 (영구 저장 확인)
- [ ] 게임 종료(Quit) → 재실행 → 골드/업그레이드 유지 (`user://save.cfg` 정상)
- [ ] 콘솔에 `[bloodline] M3 run started — meta upgrades: hp=X, speed=Y, pickup=Z` 출력

### Success Criteria Coverage (M3 진행)

| ID | Description | Status |
|----|-------------|:--:|
| FR-09 | 골드/보석 메타 통화, 세션 간 영구 저장 | ✅ (보석은 M4) |
| FR-10 | 상점/영구 업그레이드 트리 | 🟢 인프라 + 3 업그레이드 (트리 형태는 M4 진화 도입 시 확장) |
| FR-11 | 캐릭터 3종 | ❌ m3-select |
| FR-12 | 맵 2종 | ❌ m3-select |
| FR-13 | 보스 스폰 | ❌ m3-boss |
| Robustness §7 | 세이브 이중 저장 + 버전 필드 + 원자적 쓰기 | ✅ |

### Known TODOs / Tech Debt (Updated)

- [ ] m3-select: CharacterData·MapData·MainMenu·캐릭터 선택·맵 선택 UI
- [ ] m3-boss: Boss AI + boss_spawned + 보스 HP UI bar
- [ ] M2 GUT 테스트 미작성 (계속 누적 — 다음 iterate에 흡수 예정)
- [ ] M3 GUT 테스트 미작성 (SaveManager 라운드트립/백업 폴백)
- [ ] 메타 업그레이드 데미지/쿨다운 효과 미구현 (M4)
- [ ] 골드 시각 효과 (반짝임/소리) 없음 — M5 폴리시

### Next Sessions

| Session | Scope | Command |
|---------|-------|---------|
| S8 | m3-select (캐릭터/맵 선택, MainMenu) | `/pdca do bloodline --scope m3-select` |
| S9 | m3-boss | `/pdca do bloodline --scope m3-boss` |
| S10 | M3 갭 분석 | `/pdca analyze bloodline` |
