---
template: plan
version: 1.3
feature: bloodline
date: 2026-05-18
author: swshin@addeep.co.kr
project: bloodline
version_proj: 0.1.0
---

# bloodline Planning Document

> **Summary**: Godot 4 기반 Vampire Survivors 스타일 로그라이크 서바이벌 게임 풀 클론. **데스크톱(Win/Mac/Linux) 우선**, 모바일은 v2.0 이후로 연기. 무료 에셋 활용, 단계별 마일스톤 진행.
>
> **Project**: bloodline
> **Version**: 0.1.0
> **Author**: swshin
> **Date**: 2026-05-18
> **Status**: Draft

---

## Executive Summary

| Perspective | Content |
|-------------|---------|
| **Problem** | Vampire Survivors 스타일의 캐주얼 로그라이크를 Godot 4로 직접 구현하며 게임 개발 전 영역(2D 액션·풀링·스폰·메타 진행)을 학습/체험. |
| **Solution** | 참고 레포(`SamuelAsherRivello/godot-vampire-survivors-clone`)의 GDScript 패턴을 기반으로, 5단계 마일스톤(M1 코어→M5 폴리시)으로 풀 클론 구현. |
| **Function/UX Effect** | 자동 공격 + 이동 조작만으로 즐기는 30분 단위 런, 레벨업 시 무기/패시브 선택, 진화 무기, 메타 언락, 다맵/다캐릭터. |
| **Core Value** | "쉬운 조작 × 깊은 빌드업"의 핵심 루프를 직접 만들고 데스크톱에서 즐길 수 있는 완성된 인디 게임. (모바일 이식은 v2.0 후속 과제) |

---

## Context Anchor

| Key | Value |
|-----|-------|
| **WHY** | Vampire Survivors의 중독적 코어 루프를 학습 목적+창작 욕구로 풀 클론하며 Godot 4 숙련. |
| **WHO** | 1인 개발자(본인) / 캐주얼 로그라이크 팬 플레이어. |
| **RISK** | 풀 클론 스코프 과대 → 미완성 위험. 에셋 일관성 결여. (모바일 분기 비용은 v2.0으로 연기) |
| **SUCCESS** | M1 플레이어블 빌드(2주), M3 풀 게임플레이(7주), M5 데스크톱(Win/Mac/Linux) 출시 가능 수준(~10주). |
| **SCOPE** | M1 코어 루프 → M2 무기/레벨업 → M3 메타·다맵·다캐릭터 → M4 진화 무기/도전과제 → M5 데스크톱 폴리시. (모바일은 v2.0) |

---

## 1. Overview

### 1.1 Purpose

Vampire Survivors 장르의 핵심 재미(수많은 적 처치 × 빌드 선택 × 런 단위 진행)를 직접 구현해, Godot 4로 완성된 2D 게임을 만든다.

### 1.2 Background

- 참고 레포: https://github.com/SamuelAsherRivello/godot-vampire-survivors-clone (Godot 4 튜토리얼 클론)
- 본 프로젝트는 위 패턴을 학습 기반으로 삼되, 다맵/다캐릭터/진화 무기까지 포함하는 **풀 클론**을 목표로 함.
- **v1.0 타겟: 데스크톱 (Windows / macOS / Linux)**. 모바일(Android/iOS) 이식은 v2.0 후속 과제로 분리.

### 1.3 Related Documents

- 참고 레포: https://github.com/SamuelAsherRivello/godot-vampire-survivors-clone
- 원작 참고: https://store.steampowered.com/app/1794680/Vampire_Survivors/
- 무료 에셋: https://kenney.nl/assets, https://itch.io/game-assets/free

---

## 2. Scope

### 2.1 In Scope

- [ ] **M1 코어 루프**: 플레이어 이동, 카메라, 자동 공격 1종, 적 1종 스폰, 체력/사망, 경험치 수집
- [ ] **M2 무기/레벨업**: 무기 3종, 패시브 3종, 레벨업 카드 선택 UI, 적 3종(근접/원거리/탱커)
- [ ] **M3 메타·다맵·다캐릭터**: 골드 시스템, 영구 업그레이드, 맵 2종, 캐릭터 3종, 보스 1종
- [ ] **M4 진화 무기/도전과제**: 무기 8종, 진화 조합, 도전과제 시스템, 언락 트리, 보스 추가
- [ ] **M5 데스크톱 폴리시**: 해상도/UI 스케일(데스크톱), 사운드/이펙트, 메인 메뉴, 옵션, 빌드 파이프라인(Win/Mac/Linux)

### 2.2 Out of Scope (v1.0)

- **모바일 빌드 (Android/iOS) — v2.0 후속 과제로 분리**
- **가상 조이스틱·터치 UI — v2.0**
- 멀티플레이/온라인 기능
- 인앱결제·실시간 서버 연동
- 3D 그래픽
- 스토리·시네마틱 컷신
- 다국어(영/한 외)는 v1.0 이후

### 2.3 Deferred to v2.0 (모바일 이식 시 별도 PDCA)

- FR-16 모바일 가상 조이스틱·UI 스케일
- Android/iOS export 파이프라인
- 모바일 성능 프로파일링·배터리 최적화
- 터치 UX(롱탭/스와이프) 보강
- `InputBridge` autoload 도입

---

## 3. Requirements

### 3.1 Functional Requirements

| ID | Requirement | Priority | Milestone |
|----|-------------|----------|-----------|
| FR-01 | 8방향 키보드/게임패드 이동 (속도 일정) | High | M1 |
| FR-02 | 자동 공격: 가장 가까운 적 타깃 또는 방향 기반 발사 | High | M1 |
| FR-03 | 적 스폰: 타이머 기반 + 시간 경과 난이도 곡선 | High | M1 |
| FR-04 | 경험치 젬 드롭/수집, 자석 효과, 레벨업 트리거 | High | M1 |
| FR-05 | 레벨업 시 3개 카드 선택 UI (무기/패시브 강화) | High | M2 |
| FR-06 | 무기 시스템: 데이터 기반(JSON/Resource) 8종 정의 | High | M2-M4 |
| FR-07 | 패시브 아이템 5종 (체력/속도/회복/픽업 반경 등) | High | M2 |
| FR-08 | 적 풀링(Object Pool): 화면 내 500+ 동시 처리 | High | M1 |
| FR-09 | 골드/보석 메타 통화, 세션 간 영구 저장 | High | M3 |
| FR-10 | 상점/영구 업그레이드 트리 | High | M3 |
| FR-11 | 캐릭터 3종 (고유 스탯/시작 무기) | Medium | M3 |
| FR-12 | 맵 2종 (타일맵·고유 적 풀·BGM) | Medium | M3 |
| FR-13 | 보스 스폰 (5분/15분 등 마일스톤) | Medium | M3-M4 |
| FR-14 | 진화 무기: 특정 무기 Max + 패시브 조건 충족 | Medium | M4 |
| FR-15 | 도전과제 시스템 + 언락 트리 | Medium | M4 |
| FR-16 | ~~모바일 가상 조이스틱 + UI 스케일링~~ → **v2.0 연기** | — | v2.0 |
| FR-17 | 메인메뉴/설정/일시정지/결과 화면 (데스크톱) | High | M5 |
| FR-18 | 사운드(BGM/SFX) + 볼륨 설정 | Medium | M5 |
| FR-19 | 데스크톱 빌드 파이프라인 (Win/Mac/Linux) | High | M5 |

### 3.2 Non-Functional Requirements

| Category | Criteria | Measurement Method |
|----------|----------|-------------------|
| Performance (Desktop) | 60 FPS @ 1080p, 적 500+ 동시 | Godot Profiler, monitor.fps |
| Memory | < 500MB RAM (Desktop) | Godot Monitor |
| Storage | 빌드 < 200MB (압축) | export 후 측정 |
| Input Latency | < 50ms (입력→화면 반영) | 수동 측정 |
| Save | 진행/메타 데이터 손상 0%, 자동 백업 1세대 | 수동/유닛 테스트 |
| _Performance (Mobile)_ | _v2.0 NFR에서 정의_ | _v2.0_ |

---

## 4. Success Criteria

### 4.1 Definition of Done (Milestone별)

- [ ] **M1**: 30초 이상 끊김 없이 플레이 가능, 적 처치/사망/재시작 동작
- [ ] **M2**: 무기 3종/패시브 3종으로 5분 런 완주 가능, 레벨업 선택 동작
- [ ] **M3**: 메타 진행 저장/로드, 캐릭터/맵 선택 화면 동작
- [ ] **M4**: 진화 무기 1종 이상 트리거 확인, 도전과제 5개 이상 동작
- [ ] **M5**: Win/Mac/Linux 빌드 산출 + 데스크톱 실기기 테스트 통과

### 4.2 Quality Criteria

- [ ] 60 FPS 유지 (적 500체 시점)
- [ ] 크래시 없이 30분 런 완주 가능
- [ ] 무기/패시브 데이터 신규 추가 시 코드 수정 없이 JSON/Resource만으로 등록 가능
- [ ] 코드 컨벤션(GDScript): snake_case, 시그널/그룹 명명 규약 일관성

---

## 5. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 풀 클론 스코프 과대로 미완성 | High | High | 마일스톤별 "플레이어블 빌드" 강제, M1만으로도 즐길 수 있게 설계 |
| 동시 적 500+ 시 성능 저하 | High | Medium | Object Pool, MultiMeshInstance2D, 화면 밖 컬링, 물리 단순화(Area2D) |
| 모바일 이식(v2.0) 시 재작업 발생 | Medium | Medium | 입력은 InputMap Actions로 추상화하고 UI는 Control + anchor 기반으로 작성해 v2.0 이식 비용 최소화 |
| 에셋 일관성 결여(여러 출처 혼용) | Medium | Medium | 톤/팔레트 가이드 1장 만들고 무료 에셋 큐레이션 |
| GDScript 학습 곡선 | Medium | Medium | 참고 레포 코드 정독, 작은 기능부터 따라 구현 |
| 저장 데이터 손상 | High | Low | ConfigFile/JSON 이중 저장, 버전 필드, 자동 백업 |

---

## 6. Impact Analysis

> 신규 프로젝트이므로 기존 소비자 없음. M2 이후 데이터 스키마(무기/패시브 JSON) 변경 시 본 섹션 갱신.

### 6.1 Changed Resources

| Resource | Type | Change Description |
|----------|------|--------------------|
| (신규) Player.tscn | Scene | M1 신규 생성 |
| (신규) Enemy.tscn / EnemySpawner | Scene/Script | M1 신규 생성 |
| (신규) WeaponData.tres (Resource) | Resource Schema | M2 신규, 이후 무기 추가 시 호환성 유지 |
| (신규) SaveData (ConfigFile) | Save Schema | M3 신규, 마이그레이션 필요 시 버전 필드 사용 |

---

## 7. Architecture Considerations

### 7.1 Project Level Selection

| Level | Characteristics | Recommended For | Selected |
|-------|-----------------|-----------------|:--------:|
| **Starter** | 단순 구조 | 정적 사이트 | ☐ |
| **Dynamic** | 기능 모듈, BaaS | 풀스택 웹 | ☐ |
| **Enterprise** | 엄격 레이어 분리 | 대형 시스템 | ☐ |
| **Game (Godot)** | scenes/, scripts/, resources/, assets/ + autoload 싱글톤 | 인디 2D/3D 게임 | ☑ |

> bkit 기본 레벨에는 없는 **Game 레벨**로 운영. 폴더 구조는 Godot 표준을 따른다.

### 7.2 Key Architectural Decisions

| Decision | Options | Selected | Rationale |
|----------|---------|----------|-----------|
| Engine | Godot 4 / Unity / Phaser | **Godot 4** | 참고 레포 일치, 무료/오픈소스, 2D 강력, 모바일 export 지원 |
| Language | GDScript / C# | **GDScript** | 참고 레포 일치, Godot 친화적, 빠른 반복 |
| Rendering | Forward+ / Compatibility | **Compatibility** | 모바일/구형 GPU 호환, 2D 충분 |
| Physics | RigidBody2D / Area2D + 수동 이동 | **Area2D 위주** | 대량 적 처리 시 성능 유리 |
| Spawn 패턴 | 매번 instantiate / Object Pool | **Object Pool** | 500+ 적 시 GC/할당 최소화 |
| 데이터 | 하드코딩 / Resource(.tres) / JSON | **Resource(.tres)** | Godot 친화, 인스펙터 편집, 타입 안전 |
| 저장 | JSON / ConfigFile / SQLite | **ConfigFile + JSON 백업** | 단순 키-값에 충분, 백업 용이 |
| 입력 | InputMap + Input Actions | **InputMap** | 데스크톱/패드/터치 통일 매핑 |
| UI | Control Node + Theme | **Control + Theme** | 해상도 스케일 용이 |
| 버전관리 | Git | **Git + .gitattributes(LFS)** | 큰 에셋용 LFS 준비 |
| Build | Godot Export Templates | **Win/Mac/Linux** (v1.0) / Android·iOS는 v2.0 | M5에서 데스크톱 3종 일괄 설정 |

### 7.3 Folder Structure

```
bloodline/
├── project.godot
├── scenes/
│   ├── main/          # Main.tscn, GameWorld.tscn
│   ├── player/        # Player.tscn
│   ├── enemies/       # Enemy_*.tscn, Boss_*.tscn
│   ├── weapons/       # Weapon_*.tscn (projectile/aura/orbit)
│   ├── pickups/       # ExpGem.tscn, Gold.tscn, HealthPickup.tscn
│   ├── ui/            # MainMenu, HUD, LevelUpUI, PauseMenu, GameOver
│   └── maps/          # Map_Forest.tscn, Map_Cemetery.tscn
├── scripts/
│   ├── autoload/      # GameState.gd, SaveManager.gd, AudioManager.gd, EventBus.gd
│   ├── player/        # player.gd, player_stats.gd
│   ├── enemies/       # enemy_base.gd, spawner.gd
│   ├── weapons/       # weapon_base.gd, projectile.gd, weapon_evolution.gd
│   ├── systems/       # exp_system.gd, level_up_system.gd, achievement_system.gd
│   └── ui/            # hud.gd, level_up_card.gd
├── resources/
│   ├── weapons/       # WeaponData_*.tres
│   ├── passives/      # PassiveData_*.tres
│   ├── enemies/       # EnemyData_*.tres
│   └── characters/    # CharacterData_*.tres
├── assets/
│   ├── sprites/       # (Kenney/itch.io 무료 에셋)
│   ├── audio/
│   └── fonts/
├── export_presets.cfg
└── docs/              # 본 PDCA 문서
```

### 7.4 Autoload Singletons

| Name | Role |
|------|------|
| `EventBus` | 전역 시그널 허브 (loose coupling) |
| `GameState` | 현재 런 상태/통계 |
| `SaveManager` | 메타 데이터 저장/로드 |
| `AudioManager` | BGM/SFX 재생 |
| ~~`InputBridge`~~ | _v2.0 모바일 이식 시 도입_ |

---

## 8. Convention Prerequisites

### 8.1 Existing Project Conventions

신규 프로젝트로 모두 미존재. 첫 커밋 시 함께 작성한다.

- [ ] `CLAUDE.md` (프로젝트 컨텍스트)
- [ ] `docs/01-plan/conventions.md` (GDScript 컨벤션)
- [ ] `.editorconfig`
- [ ] `.gitignore` (Godot용)
- [ ] `.gitattributes` (LFS 후보 확장자)

### 8.2 Conventions to Define

| Category | To Define | Priority |
|----------|-----------|:--------:|
| **Naming** | 파일 snake_case, 노드 PascalCase, 시그널 snake_case 과거형(`enemy_died`) | High |
| **Folder** | 위 7.3 구조 고정 | High |
| **Signal vs Direct call** | 크로스 시스템은 EventBus 시그널, 같은 씬 내는 직접 호출 | High |
| **Resource 우선** | 데이터는 .tres, 로직만 .gd | High |
| **Magic number 금지** | 상수는 const 또는 Resource로 | Medium |

### 8.3 Environment / Tooling

| Item | Purpose |
|------|---------|
| Godot 4.3+ | 엔진 |
| Git LFS | sprite/audio (M3 이후 필요 시) |
| Export Templates | 플랫폼별 빌드 |
| (옵션) GUT | GDScript 유닛 테스트 |

---

## 9. Milestone Plan

| Milestone | 목표 | 예상 기간 | 산출물 |
|-----------|------|-----------|--------|
| **M1 Core Loop** | 이동·자동공격·적·죽음·경험치 | 2주 | 플레이어블 빌드 v0.1 |
| **M2 Weapons & Level-up** | 무기 3·패시브 3·레벨업 UI | 2주 | v0.2 |
| **M3 Meta & Maps & Chars** | 저장·상점·맵2·캐릭3·보스 | 3주 | v0.3 |
| **M4 Evolutions & Achievements** | 무기 8·진화·도전과제 | 3주 | v0.4 |
| **M5 Desktop Polish** | UI 스케일·사운드·메인 메뉴·옵션·Win/Mac/Linux 빌드 | 2주 | v1.0 |
| _v2.0 Mobile Port_ | _가상 조이스틱·UI 적응·Android/iOS 빌드_ | _추후_ | _별도 PDCA_ |

총 v1.0 ~12주 (취미 페이스 가정 시 가변). 모바일은 v1.0 출시 후 별도 사이클로 진행.

---

## 10. Next Steps

1. [ ] `/pdca design bloodline` 으로 Design 문서 작성 (아키텍처 3안 비교 + 선택)
2. [ ] Godot 4 프로젝트 초기화 (`project.godot`, 폴더 구조, autoload 등록)
3. [ ] M1 구현 착수 (`/pdca do bloodline --scope m1`)
4. [ ] 무료 에셋 큐레이션 1차 (플레이어/적/투사체 스프라이트)

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-05-18 | 초기 Plan 작성 (Godot 4, 풀 클론, 5 마일스톤) | swshin |
| 0.2 | 2026-05-18 | v1.0 데스크톱 전용으로 축소, 모바일은 v2.0 후속 과제로 분리 (FR-16/19, M5, 위험, 빌드 타깃, autoload 수정) | swshin |
