---
template: do-log
feature: bloodline
session: S2
date: 2026-05-18
scope: m1-bootstrap, m1-player
status: implemented
---

# bloodline — Do Log (S2: m1-bootstrap + m1-player)

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

## Next Sessions

| Session | Scope | Command |
|---------|-------|---------|
| S3 | enemy + weapon | `/pdca do bloodline --scope m1-enemy,m1-weapon` |
| S4 | EXP gem + GameOver | `/pdca do bloodline --scope m1-exp` |
| S5 | M1 분석 + 개선 | `/pdca analyze bloodline` |

## Known TODOs / Tech Debt

- [ ] icon.svg는 임시 placeholder — M5 폴리시에서 게임 로고로 교체
- [ ] GUT(테스트 프레임워크)는 m1-enemy 세션 진입 전 셋업 (Design §8.1 L1)
- [ ] CLAUDE.md / docs/01-plan/conventions.md 미작성 (Plan §8 prerequisite) — 다음 세션 첫 단계
