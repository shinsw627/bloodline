---
template: design
version: 1.3
feature: bloodline
date: 2026-05-18
author: swshin@addeep.co.kr
project: bloodline
status: Draft
---

# bloodline Design Document

> **Summary**: Godot 4 + GDScript 기반 Vampire Survivors 풀 클론. **C: Pragmatic (Composition + EventBus)** 아키텍처 채택. Resource(.tres) 데이터 모델 + EventBus 전역 시그널 + Object Pool로 적 500+ 동시 처리. 데스크톱(Win/Mac/Linux) v1.0, 모바일은 v2.0.
>
> **Project**: bloodline
> **Version**: 0.1.0
> **Author**: swshin
> **Date**: 2026-05-18
> **Status**: Draft
> **Planning Doc**: [bloodline.plan.md](../../01-plan/features/bloodline.plan.md)

---

## Context Anchor

| Key | Value |
|-----|-------|
| **WHY** | Vampire Survivors 코어 루프 학습+창작, Godot 4 숙련 |
| **WHO** | 1인 개발자(본인) / 캐주얼 로그라이크 팬 |
| **RISK** | 풀 클론 스코프 과대, 에셋 일관성, 동시 적 500+ 성능. 모바일 분기는 v2.0 |
| **SUCCESS** | M1 플레이어블(2주) → M3 풀 게임플레이(7주) → M5 데스크톱 빌드(~10주) |
| **SCOPE** | M1 코어 → M2 무기/레벨업 → M3 메타·다맵·다캐릭터 → M4 진화/도전과제 → M5 데스크톱 폴리시 |

---

## 1. Overview

### 1.1 Design Goals

1. **확장성**: 무기/패시브/적/캐릭터를 코드 수정 없이 `.tres` 파일만으로 추가 가능
2. **성능**: 적 500+ 동시 + 투사체 200+ 환경에서 60 FPS 유지 (Desktop 1080p)
3. **느슨한 결합**: 시스템 간 직접 참조 최소화 → `EventBus` 시그널 허브 경유
4. **테스트 용이성**: 로직-노드 분리, 핵심 시스템(EXP/Spawner/Damage)은 단위 테스트(GUT) 가능
5. **모바일 대비**: 입력은 `InputMap` Action 추상화, UI는 Control + anchor 기반으로 v2.0 이식 비용 최소화

### 1.2 Design Principles

- **Composition over inheritance** — Player/Enemy는 베이스 노드 + 컴포넌트성 자식(WeaponHolder/StatsComponent) 조합
- **Data > Code** — 밸런싱·콘텐츠는 `Resource(.tres)`에, 로직만 `.gd`에
- **Loose coupling via signals** — 크로스 시스템은 `EventBus` 전역 시그널, 같은 씬 내는 직접 호출
- **Pool first** — 빈번 생성·소멸 객체(Enemy, Projectile, Pickup)는 무조건 Object Pool 경유
- **Single Source of Truth** — `GameState`(현재 런), `SaveManager`(영구 데이터) 단일 출처

---

## 2. Architecture Options

### 2.0 Architecture Comparison

| Criteria | A: Minimal | B: Clean (ECS-lite) | C: Pragmatic |
|----------|:-:|:-:|:-:|
| Approach | 노드 스크립트에 직접 | 컴포넌트 노드 조합 | Composition + EventBus + Resource |
| New Files (M1) | ~8 | ~20 | ~12 |
| Complexity | Low | High | Medium |
| Maintainability | Medium | High | High |
| Effort | Low | High | Medium |
| Extensibility (M4) | Low | High | High |
| Risk | M3+ 리팩토링 | 초반 과설계 | 균형 |

**Selected**: **Option C — Pragmatic**
**Rationale**: 풀 클론 스코프(M1~M5)와 학습 목적 균형. Resource 기반 데이터로 진화 무기/도전과제 확장 비용을 미리 낮추되, 초반 학습 곡선은 ECS-lite보다 완만. EventBus로 시스템 간 결합도를 낮춰 단계별 추가/교체가 쉬움.

### 2.1 Component Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        Autoloads (Singletons)                │
│   EventBus    GameState    SaveManager    AudioManager       │
└──────────────────────────────────────────────────────────────┘
        ▲              ▲             ▲              ▲
        │ signals      │ read/write  │ persist      │ play
┌───────┴──────────────┴─────────────┴──────────────┴──────────┐
│                       GameWorld.tscn                         │
│   ┌──────────┐  ┌─────────────┐  ┌──────────┐  ┌──────────┐  │
│   │  Player  │  │EnemySpawner │  │  Pools   │  │   HUD    │  │
│   │  + Stats │  │ + Director  │  │ Enemy /  │  │ +LevelUp │  │
│   │  +Weapons│  │             │  │Projectile│  │   UI     │  │
│   └────┬─────┘  └─────┬───────┘  └────┬─────┘  └─────┬────┘  │
│        │              │               │              │       │
│        └──────────────┴───────────────┴──────────────┘       │
│                       (via EventBus)                         │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

```
[Input] → Player.move()
       → WeaponHolder.tick() → spawn Projectile from Pool
       → Projectile.area_entered(Enemy) → EventBus.enemy_damaged
       → Enemy.take_damage() → die() → EventBus.enemy_died
       → ExpGem.spawn(pos) → Player.area_entered → EventBus.exp_collected
       → GameState.add_exp() → if level_up → EventBus.level_up
       → LevelUpUI.show(3 cards) → user selects → EventBus.upgrade_chosen
       → Player.apply_upgrade()
```

### 2.3 Dependencies

| Component | Depends On | Purpose |
|-----------|-----------|---------|
| Player | EventBus, GameState, WeaponHolder, StatsComponent | 입력→이동, 무기 보유, 스탯 |
| WeaponHolder | EventBus, ProjectilePool, WeaponData(.tres) | 무기 슬롯/쿨다운/발사 |
| EnemySpawner | EventBus, EnemyPool, SpawnTable(.tres), GameState (run_time) | 시간 곡선 기반 스폰 |
| ExpSystem | EventBus, GameState | 경험치/레벨 |
| LevelUpUI | EventBus, WeaponRegistry, PassiveRegistry | 3장 카드 추첨/표시 |
| SaveManager | GameState | 메타 데이터 영속화 |
| AchievementSystem (M4) | EventBus, SaveManager | 시그널 구독 → 진행도 갱신 |

---

## 3. Data Model

Godot Custom Resource(.tres) 기반. 모두 `Resource`를 상속.

### 3.1 Core Resources

```gdscript
# resources/weapons/WeaponData.gd
class_name WeaponData
extends Resource

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var description: String
@export var max_level: int = 8
@export var projectile_scene: PackedScene
@export var base_damage: float = 10.0
@export var base_cooldown: float = 1.0       # seconds
@export var base_projectile_count: int = 1
@export var base_pierce: int = 0
@export var base_area: float = 1.0
@export var level_curve: Array[Dictionary]    # [{damage:+5, cooldown:-0.1}, ...]
@export var evolution_target: WeaponData      # M4: 진화 결과
@export var evolution_required_passive: PassiveData  # M4: 진화 조건
```

```gdscript
# resources/passives/PassiveData.gd
class_name PassiveData
extends Resource

@export var id: StringName
@export var display_name: String
@export var icon: Texture2D
@export var max_level: int = 5
@export var stat_mods: Array[Dictionary]   # per level: {move_speed:+0.05, ...}
```

```gdscript
# resources/enemies/EnemyData.gd
class_name EnemyData
extends Resource

@export var id: StringName
@export var sprite_frames: SpriteFrames
@export var hp: float
@export var damage: float
@export var move_speed: float
@export var xp_drop: int = 1
@export var gold_drop_chance: float = 0.0
@export var ai_type: int  # 0=chase, 1=ranged, 2=charge, 3=boss
```

```gdscript
# resources/characters/CharacterData.gd
class_name CharacterData
extends Resource

@export var id: StringName
@export var display_name: String
@export var portrait: Texture2D
@export var sprite_frames: SpriteFrames
@export var base_stats: Dictionary  # {max_hp, move_speed, pickup_radius, ...}
@export var starting_weapon: WeaponData
```

```gdscript
# resources/maps/MapData.gd
class_name MapData
extends Resource

@export var id: StringName
@export var scene: PackedScene
@export var bgm: AudioStream
@export var spawn_table: SpawnTableData
@export var boss_schedule: Array[Dictionary]  # [{time:300, enemy:boss_a}, ...]
```

```gdscript
# resources/spawn/SpawnTableData.gd
class_name SpawnTableData
extends Resource

# time(sec) -> weighted pool
@export var phases: Array[Dictionary]
# Example: {start_time:0, end_time:60, spawn_interval:1.0,
#          max_alive:50, enemies:[{data:slime, weight:1.0}, ...]}
```

### 3.2 Save Data Schema (ConfigFile)

```ini
[meta]
version = 1
total_runs = 12
total_play_seconds = 4500

[currency]
gold = 1250
gems = 3

[upgrades]                  # 영구 강화 (M3)
max_hp_level = 2
move_speed_level = 1

[unlocks]                   # M3~M4
characters = ["default", "knight"]
weapons = ["whip", "magic_wand"]
maps = ["forest"]

[achievements]              # M4
"kill_1000" = true
"survive_10min" = false

[settings]
master_volume = 1.0
bgm_volume = 0.8
sfx_volume = 1.0
fullscreen = false
```

- 파일: `user://save.cfg` + `user://save.cfg.bak` (자동 1세대 백업)
- 버전 필드로 마이그레이션 지원

---

## 4. API Specification

> Godot 게임 — HTTP API 없음. 대신 **EventBus 시그널 카탈로그**가 시스템 간 계약(contract)이다.

### 4.1 EventBus Signal Catalog

```gdscript
# scripts/autoload/EventBus.gd
extends Node

# === Run lifecycle ===
signal run_started(character: CharacterData, map: MapData)
signal run_ended(result: Dictionary)        # {survived_sec, kills, level, cause}

# === Player ===
signal player_health_changed(current: float, max_hp: float)
signal player_died

# === Enemies ===
signal enemy_spawned(enemy: Node2D)
signal enemy_damaged(enemy: Node2D, amount: float, source: Node)
signal enemy_died(enemy: Node2D, position: Vector2)

# === Pickups / EXP ===
signal exp_collected(amount: int)
signal exp_changed(current: int, to_next: int)
signal gold_collected(amount: int)
signal item_pickup(kind: StringName)

# === Leveling / Upgrades ===
signal level_up(new_level: int)
signal upgrade_offered(cards: Array)        # Array[Dictionary{weapon|passive, ...}]
signal upgrade_chosen(choice: Dictionary)

# === Combat / Time ===
signal boss_spawned(enemy: Node2D)
signal minute_passed(elapsed_min: int)

# === Achievements (M4) ===
signal achievement_unlocked(id: StringName)

# === Meta ===
signal save_loaded
signal save_failed(reason: String)
```

**규약**:
- `_damaged`/`_died`는 항상 `position` 또는 노드 참조 포함 → 이펙트·드롭 처리 가능
- payload는 Dictionary 또는 primitive만 (PackedScene/타입 객체는 자제 — 직렬화 호환)
- 새 시그널 추가 시 본 카탈로그 갱신 + Decision Record에 기록

### 4.2 Object Pool API

```gdscript
# scripts/systems/Pool.gd
class_name Pool
extends Node

func acquire() -> Node             # 비활성 객체 1개 반환 (없으면 instantiate)
func release(node: Node) -> void   # 비활성화 + 풀로 반환
func warm(n: int) -> void          # 초기 예열
```

EnemyPool, ProjectilePool, ExpGemPool 3종 사용.

---

## 5. UI/UX Design

### 5.1 Screen Map

```
┌───────────────┐    ┌────────────────┐    ┌──────────────────┐
│   MainMenu    │───▶│ CharacterSelect│───▶│   MapSelect      │
│ Play / Shop / │    │                │    │                  │
│ Settings/Quit │    └────────┬───────┘    └────────┬─────────┘
└──────┬────────┘             │                     │
       │ (Shop M3)            └─────────┬───────────┘
       ▼                                 ▼
┌──────────────┐                ┌─────────────────┐
│ MetaShop UI  │                │   GameWorld     │
│ (upgrades)   │                │ + HUD + LevelUp │
└──────────────┘                │ + Pause + Over  │
                                └─────────────────┘
```

### 5.2 Component List

| Component | Location | Responsibility |
|-----------|----------|----------------|
| MainMenu | `scenes/ui/main_menu.tscn` | 타이틀, Play/Shop/Settings/Quit |
| CharacterSelect | `scenes/ui/character_select.tscn` | 캐릭터 카드 그리드 (M3) |
| MapSelect | `scenes/ui/map_select.tscn` | 맵 선택 (M3) |
| MetaShop | `scenes/ui/meta_shop.tscn` | 영구 업그레이드 트리 (M3) |
| HUD | `scenes/ui/hud.tscn` | HP바, EXP바, 시계, 킬카운트, 골드, 무기/패시브 아이콘 |
| LevelUpUI | `scenes/ui/level_up.tscn` | 3장 카드 선택 |
| PauseMenu | `scenes/ui/pause.tscn` | Resume/Restart/Quit |
| GameOverScreen | `scenes/ui/game_over.tscn` | 결과 통계, Continue/Quit |
| AchievementToast | `scenes/ui/achievement_toast.tscn` | 우상단 슬라이드 알림 (M4) |

### 5.3 User Flow (게임 1런)

```
MainMenu → CharacterSelect → MapSelect → (countdown 3..2..1)
  → GameWorld 시작 (run_started)
  → 매 분: minute_passed (난이도 ↑)
  → 5분/15분: boss_spawned
  → Level up: pause → LevelUpUI (3 cards) → resume
  → Death: GameOverScreen (run_ended) → 골드 정산 → MetaShop or MainMenu
```

### 5.4 Page UI Checklist

#### HUD (게임 중 상시)

- [ ] HP 바 (좌상단, 현재/최대)
- [ ] EXP 바 (상단 전체 폭, 현재 레벨/다음까지)
- [ ] 시계 (상단 중앙, MM:SS, 분 단위 변경 시 깜빡)
- [ ] 킬 카운트 (우상단)
- [ ] 골드 (우상단 아이콘 + 수)
- [ ] 무기 아이콘 슬롯 6개 (하단 좌측, 레벨 배지)
- [ ] 패시브 아이콘 슬롯 6개 (하단 우측, 레벨 배지)
- [ ] 보스 HP 바 (상단, 보스 등장 시만)

#### LevelUpUI

- [ ] 배경 어둡게 + 게임 일시정지
- [ ] 3장 카드 (가로 배치)
- [ ] 각 카드: 아이콘, 이름, 레벨(현재→다음), 설명, 신규/업그레이드 배지
- [ ] 카드 클릭 시 `upgrade_chosen` 시그널 발신 후 닫힘
- [ ] 키보드 1/2/3 단축키 지원

#### GameOverScreen

- [ ] "GAME OVER" 헤더
- [ ] 통계: 생존 시간, 킬 수, 최종 레벨, 획득 골드
- [ ] 사용 무기/패시브 아이콘 리스트
- [ ] 골드 정산 → SaveManager 반영 확인 메시지
- [ ] Continue (메인메뉴) / Retry / Quit 버튼

#### MainMenu

- [ ] 타이틀 로고
- [ ] Play, Shop(M3), Achievements(M4), Settings, Quit 버튼
- [ ] 버전 표기 (우하단)

---

## 6. Error Handling

게임 컨텍스트 — HTTP 코드 대신 **장애 시나리오** 매핑.

| Code | Situation | Cause | Handling |
|------|-----------|-------|----------|
| E_SAVE_LOAD_FAIL | 세이브 파일 읽기 실패 | 파일 손상/없음 | `.bak` 시도 → 실패 시 기본값 + 토스트 알림 |
| E_SAVE_WRITE_FAIL | 저장 실패 | 디스크 권한/공간 | 1회 재시도, 실패 시 인게임 알림 |
| E_RES_LOAD_FAIL | Resource(.tres) 로드 실패 | 누락/스키마 변경 | 콘솔 push_error + 해당 콘텐츠 skip, 런 계속 |
| E_POOL_EXHAUSTED | 풀 한계 도달 | 적/투사체 과다 | warn 로그, hard cap에서 가장 오래된 객체 강제 회수 |
| E_INPUT_NO_DEVICE | 패드 분리 등 | 디바이스 분실 | 일시정지 후 안내 |

`push_error()` / `push_warning()` 사용, 디버그 빌드는 화면 우상단 디버그 패널로 노출.

---

## 7. Security & Robustness

> 오프라인 게임. 보안 대신 견고성(Robustness).

- [ ] 세이브 파일 이중 저장(`save.cfg` + `save.cfg.bak`) + 원자적 쓰기(tmp→rename)
- [ ] 세이브 버전 필드 + 마이그레이션 함수
- [ ] 입력 검증: 키 리바인딩 시 중복/예약키 차단
- [ ] Resource 로드 시 필수 필드 nil 체크
- [ ] 풀 사이즈 hard cap (Enemy 800, Projectile 400, ExpGem 1000)
- [ ] 인게임 치트(디버그 빌드 한정): F1 패널로만 노출, 릴리스 빌드 export 시 제거

---

## 8. Test Plan

### 8.1 Test Scope

| Type | Target | Tool | Phase |
|------|--------|------|-------|
| L1: Unit (GDScript) | EXP 계산, 레벨업 곡선, SpawnTable 추첨, SaveManager 직렬화 | GUT (Godot Unit Test) | Do |
| L2: Scene/Integration | Player↔Enemy 데미지, WeaponHolder 쿨다운, Pool acquire/release | GUT scene tests | Do |
| L3: Manual Playthrough | 5분 런/30분 런, 레벨업 카드 선택, 보스, 진화 무기 | 수동 체크리스트 | Check |
| L4: Performance | 적 500체 시 FPS, 메모리 | Godot Monitor + profiler | Check |
| L5: Build Smoke | Win/Mac/Linux export 후 1런 완주 | 실기기 수동 | M5 / Check |

### 8.2 L1 Unit Scenarios

| # | Target | Description | Expected |
|---|--------|-------------|----------|
| 1 | ExpSystem | level 1→2 필요 EXP 계산 | curve 함수 출력 일치 |
| 2 | ExpSystem | 한 프레임에 EXP 다량 획득 → 다중 레벨업 처리 | level_up 시그널 N회 발신 |
| 3 | WeaponData.level_curve | level 1→8 누적 스탯 | 정의된 합산값과 일치 |
| 4 | SpawnTable | phase 경계 시간에 enemies 풀 전환 | 60.0초에 phase 1 종료 |
| 5 | SaveManager | save → load 라운드트립 | 모든 키 동일 |
| 6 | SaveManager | 손상된 파일 로드 → `.bak` 폴백 | 백업 데이터로 복구, save_failed 미발신 |
| 7 | Pool | acquire/release N회 → 풀 크기 안정 | 메모리 누수 없음 |

### 8.3 L2 Scene Test Scenarios

| # | Scene | Action | Expected |
|---|-------|--------|----------|
| 1 | Player + Enemy | 접촉 시 player HP 감소 | EventBus.player_health_changed |
| 2 | WeaponHolder + Projectile | 쿨다운 경과 → 자동 발사 | spawn_count = floor(t / cooldown) |
| 3 | Projectile vs Enemy | hit → 데미지 적용, pierce 0이면 release | enemy_damaged, projectile 회수 |
| 4 | ExpGem + Player | pickup_radius 안에 들어오면 자석 흡수 | exp_collected |
| 5 | LevelUpUI | level_up 시그널 → 카드 3장 표시, 클릭 → upgrade_chosen | 게임 resume |

### 8.4 L3 Manual Playthrough

| # | Scenario | Steps | Success |
|---|----------|-------|---------|
| 1 | M1 코어 런 (30초) | 시작 → 이동/자동공격 → 죽음 | 크래시 없음 |
| 2 | 5분 런 | 무기 3종 + 패시브로 5분 생존 | 레벨업 UI 5+회 정상 |
| 3 | 15분 보스 | 보스 1체 처치 | 보스 hp바 표시/감소 |
| 4 | 진화 무기 | 무기 max + 조건 패시브 보유 → 다음 레벨업에서 진화 카드 등장 | evolution_target 무기로 교체 |
| 5 | 도전과제 | "1000킬" 조건 충족 | toast 알림 + 세이브 반영 |
| 6 | 30분 런 완주 | 무한 모드/엔드 | FPS 평균 ≥ 55, 크래시 0 |

### 8.5 L4 Performance Targets

| Metric | Target | Measurement |
|--------|:------:|-------------|
| FPS @ enemies=200 | ≥ 60 | monitor.fps |
| FPS @ enemies=500 | ≥ 55 | monitor.fps |
| Frame time spike | < 50ms | profiler |
| RAM | < 500MB | Godot monitor |
| Pool reuse rate | ≥ 95% | Pool 디버그 로그 |

### 8.6 Seed Data

| Resource | Min Count | M-stage |
|----------|:--:|:--:|
| WeaponData | 1 (M1) → 3 (M2) → 8 (M4) | progressive |
| PassiveData | 0 (M1) → 3 (M2) → 5+ (M4) | progressive |
| EnemyData | 1 (M1) → 3 (M2) → 8+ (M3) | progressive |
| CharacterData | 1 (M1) → 3 (M3) | progressive |
| MapData | 1 (M1) → 2 (M3) | progressive |

---

## 9. Layer Structure (Godot Adaptation)

> 전통적 Clean Architecture 4계층을 Godot 컨텍스트로 매핑.

| Layer | Responsibility | Location |
|-------|---------------|----------|
| **Presentation (Scenes/UI)** | `.tscn` 씬, Control 노드, HUD | `scenes/ui/`, `scripts/ui/` |
| **Game Logic (Behavior)** | Player/Enemy/Weapon 동작 스크립트 | `scripts/player/`, `scripts/enemies/`, `scripts/weapons/` |
| **Systems (Application)** | EXP/Spawner/LevelUp/Achievement 시스템 | `scripts/systems/` |
| **Domain (Data)** | Resource(.tres) 정의, 순수 데이터 클래스 | `resources/`, `scripts/data/` |
| **Infrastructure (Autoload)** | EventBus, SaveManager, AudioManager | `scripts/autoload/` |

**의존 규칙**:
- Domain Resource는 어떤 것도 import 하지 않음 (순수 데이터)
- Systems는 Domain + Infrastructure만 참조
- Behavior는 Systems, Domain, Infrastructure 참조 가능
- UI는 EventBus 시그널 구독 + 시스템 직접 호출 가능, 단 Behavior 직접 조작 금지

---

## 10. Coding Convention (GDScript)

### 10.1 Naming

| Target | Rule | Example |
|--------|------|---------|
| File (script) | snake_case.gd | `enemy_spawner.gd` |
| File (scene) | snake_case.tscn | `level_up.tscn` |
| Node in tree | PascalCase | `WeaponHolder`, `HealthBar` |
| Class | PascalCase | `class_name WeaponData` |
| Function | snake_case | `apply_upgrade()` |
| Variable | snake_case | `var move_speed` |
| Constant | UPPER_SNAKE_CASE | `const MAX_ENEMIES = 800` |
| Signal | snake_case past-tense | `enemy_died`, `upgrade_chosen` |
| Resource(.tres) | PascalCase_id.tres | `Whip_Lv1.tres`, `Slime.tres` |

### 10.2 File Header Convention

```gdscript
# Design Ref: §X.Y — {decision summary}
# Plan SC: {success criteria id}  (only on critical scripts)
class_name Foo
extends Bar
```

### 10.3 Signal vs Direct Call

- **EventBus 시그널**: 시스템 경계를 넘는 통신 (Enemy→UI, Pickup→GameState)
- **로컬 시그널**: 같은 씬 부모-자식 (Button.pressed)
- **직접 호출**: 같은 액터 내 컴포넌트 간 (Player → WeaponHolder)

### 10.4 Magic Numbers

금지. 다음 중 하나로:
1. 콘텐츠/밸런싱 → `Resource(.tres)`
2. 시스템 상수 → `const`
3. 튜닝 파라미터 → `@export var` (인스펙터 노출)

---

## 11. Implementation Guide

### 11.1 File Structure

```
bloodline/
├── project.godot
├── export_presets.cfg
├── scenes/
│   ├── main/        main.tscn, game_world.tscn
│   ├── player/      player.tscn
│   ├── enemies/     enemy_base.tscn, slime.tscn, ...
│   ├── weapons/     weapon_base.tscn, whip.tscn, magic_wand.tscn
│   ├── pickups/     exp_gem.tscn, gold.tscn
│   ├── ui/          hud.tscn, level_up.tscn, main_menu.tscn, ...
│   └── maps/        map_forest.tscn, map_cemetery.tscn
├── scripts/
│   ├── autoload/    event_bus.gd, game_state.gd, save_manager.gd, audio_manager.gd
│   ├── data/        weapon_data.gd, passive_data.gd, enemy_data.gd, ...
│   ├── player/      player.gd, stats_component.gd
│   ├── enemies/     enemy_base.gd, ai_chase.gd, ai_ranged.gd
│   ├── weapons/     weapon_holder.gd, projectile.gd, weapon_evolution.gd
│   ├── systems/     exp_system.gd, spawn_director.gd, pool.gd, achievement_system.gd
│   └── ui/          hud.gd, level_up_card.gd, main_menu.gd
├── resources/
│   ├── weapons/     Whip.tres, MagicWand.tres, ...
│   ├── passives/    MaxHpUp.tres, MoveSpeedUp.tres, ...
│   ├── enemies/     Slime.tres, Bat.tres, Boss_A.tres
│   ├── characters/  Default.tres, Knight.tres
│   ├── maps/        Forest.tres, Cemetery.tres
│   └── spawn/       SpawnTable_Forest.tres
├── assets/
│   ├── sprites/     (Kenney / itch.io)
│   ├── audio/
│   └── fonts/
├── tests/           (GUT tests)
└── docs/            (PDCA)
```

### 11.2 Implementation Order (per Milestone)

**M1 — Core Loop (2주)**
1. [ ] Godot 프로젝트 초기화, autoload 등록 (EventBus, GameState)
2. [ ] WeaponData/EnemyData Resource 정의 + 샘플 1종씩
3. [ ] Pool 시스템 + EnemyPool / ProjectilePool
4. [ ] Player(이동, StatsComponent, WeaponHolder)
5. [ ] Enemy_base + chase AI + take_damage
6. [ ] Weapon_base + Projectile + 자동 발사
7. [ ] EnemySpawner(타이머 + 카운트 기반)
8. [ ] ExpGem + 자석 흡수 + ExpSystem(레벨업 시그널만)
9. [ ] GameOver 처리 → 메인 화면 복귀
10. [ ] GUT 환경 셋업 + L1 테스트 4개 (EXP/Pool/Save 기본)

**M2 — Weapons & Level-up (2주)**
1. [ ] WeaponData level_curve 적용
2. [ ] PassiveData + StatsComponent 모디파이어 합성
3. [ ] LevelUpUI (3 카드 추첨 — 가중치, 중복 방지)
4. [ ] 무기 2종 추가 (총 3종), 패시브 3종
5. [ ] 적 2종 추가 (ranged, charge)
6. [ ] HUD 무기/패시브 아이콘 슬롯

**M3 — Meta / Maps / Chars (3주)**
1. [ ] SaveManager + ConfigFile + 백업
2. [ ] CharacterData + CharacterSelect UI
3. [ ] MapData + MapSelect UI + 2번째 맵
4. [ ] MetaShop (영구 업그레이드 트리)
5. [ ] 보스 1종 + 보스 HP 바

**M4 — Evolutions & Achievements (3주)**
1. [ ] 무기 5종 추가 (총 8종)
2. [ ] evolution_target/required_passive 처리 + 진화 카드
3. [ ] AchievementSystem (EventBus 구독 기반)
4. [ ] 도전과제 토스트 + 언락 트리 UI
5. [ ] 보스 2종 추가

**M5 — Desktop Polish (2주)**
1. [ ] 메인 메뉴/일시정지/설정/결과 화면 폴리시
2. [ ] BGM/SFX 풀 + AudioManager + 볼륨 설정
3. [ ] 해상도/풀스크린/UI 스케일
4. [ ] 입력 리바인딩
5. [ ] export_presets.cfg (Win/Mac/Linux) + 빌드 자동화 스크립트
6. [ ] L4/L5 통과

### 11.3 Session Guide

#### Module Map

| Module | Scope Key | Description | Estimated Turns |
|--------|-----------|-------------|:---------------:|
| M1 Bootstrap & Autoloads | `m1-bootstrap` | project.godot, EventBus, GameState, 폴더 구조 | 15-20 |
| M1 Player & Input | `m1-player` | Player.tscn, 이동, StatsComponent | 15-20 |
| M1 Enemy & Pool | `m1-enemy` | EnemyBase, chase AI, EnemyPool, Spawner | 25-30 |
| M1 Weapon & Projectile | `m1-weapon` | WeaponHolder, Projectile, ProjectilePool, 첫 무기(Whip) | 25-30 |
| M1 EXP & GameOver | `m1-exp` | ExpGem, ExpSystem, GameOver 화면 | 15-20 |
| M2 Level-up UI | `m2-levelup` | LevelUpUI, 카드 추첨 시스템 | 25-30 |
| M2 Weapons & Passives Pack | `m2-content` | 무기 3종/패시브 3종 .tres, level_curve 적용 | 20-25 |
| M3 Save & Meta | `m3-save` | SaveManager, MetaShop UI | 25-30 |
| M3 Char/Map Select | `m3-select` | CharacterSelect, MapSelect, 2번째 맵 | 25-30 |
| M3 Boss | `m3-boss` | 보스 AI, 보스 HP UI | 15-20 |
| M4 Evolutions | `m4-evolve` | 진화 무기 시스템, 무기 5종 추가 | 30-35 |
| M4 Achievements | `m4-achieve` | AchievementSystem, 토스트, 언락 트리 | 20-25 |
| M5 Polish & Audio | `m5-polish` | UI 폴리시, AudioManager, 설정 화면 | 25-30 |
| M5 Export & Build | `m5-build` | export_presets, 3 OS 빌드 검증 | 15-20 |

#### Recommended Session Plan

| Session | Phase | Scope | Turns |
|---------|-------|-------|:-----:|
| S1 | Plan + Design | 전체 | ~30 (현재) |
| S2 | Do | `--scope m1-bootstrap,m1-player` | 35-45 |
| S3 | Do | `--scope m1-enemy,m1-weapon` | 50-60 |
| S4 | Do | `--scope m1-exp` | 20-25 |
| S5 | Check | M1 분석 + iterate | 30-40 |
| S6+ | Do | M2 ~ M5 모듈별 1~2개씩 | 모듈당 1세션 |

---

## 12. Decision Record

| # | Decision | Options | Selected | Rationale |
|---|----------|---------|----------|-----------|
| D1 | Engine | Godot 4 / Unity / Phaser | **Godot 4** | 참고 레포 일치, 무료, 2D 강력 |
| D2 | Language | GDScript / C# | **GDScript** | 빠른 반복, 튜토리얼 호환 |
| D3 | Architecture | A/B/C | **C: Pragmatic** | 풀 클론+학습 균형 (사용자 선택) |
| D4 | Inter-system comm | direct ref / autoload / EventBus | **EventBus** | 시스템 경계 명확, 테스트 용이 |
| D5 | Data | hardcode / JSON / Resource | **Resource(.tres)** | 인스펙터 편집, 타입 안전 |
| D6 | Save | JSON / ConfigFile / SQLite | **ConfigFile + .bak** | 키-값 충분, 백업 단순 |
| D7 | Spawn pattern | instantiate / Object Pool | **Object Pool** | 500+ 적 성능 |
| D8 | Physics | RigidBody2D / Area2D | **Area2D 위주** | 대량 객체 성능 |
| D9 | Mobile (v1.0) | 포함 / 연기 | **v2.0 연기** | 스코프 축소 (Plan v0.2) |
| D10 | Renderer | Forward+ / Compatibility | **Compatibility** | 데스크톱 호환성·구형 GPU |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-05-18 | 초기 Design (Option C 채택, EventBus + Resource + Pool 아키텍처) | swshin |
