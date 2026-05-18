---
template: do-log
feature: bloodline
sessions: [S2, S3]
date: 2026-05-18
scope: m1-bootstrap, m1-player, m1-enemy, m1-weapon
status: implemented
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

### Next Sessions

| Session | Scope | Command |
|---------|-------|---------|
| S4 | EXP gem + GameOver + 최소 HUD | `/pdca do bloodline --scope m1-exp` |
| S5 | M1 갭 분석 | `/pdca analyze bloodline` |
| S6+ | M2 콘텐츠 (무기/패시브/레벨업 UI) | `/pdca do bloodline --scope m2-levelup,m2-content` |
