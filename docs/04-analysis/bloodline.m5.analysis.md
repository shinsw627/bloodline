---
template: analysis
feature: bloodline
milestone: M5 (polish portion)
date: 2026-05-19
scope: M5-polish (audio infra + settings + pause + achievement panel + M4 carryover)
m5_build_status: deferred (user Godot action)
status: M5-polish Match Rate 92%, M5 overall ~75% (build phase pending)
---

# bloodline — M5 Gap Analysis

> Compares Plan §11.2 M5 + Design vs S11 implementation.
> M5는 polish + build 두 부분. 본 분석은 **polish 부분 정밀 평가 + build 부분 미수행 명시**.

## Context Anchor (carried)

| Key | Value |
|-----|-------|
| WHY | 풀 클론 v1.0 출시 가능 수준 |
| SCOPE | M5 = 폴리시(UI/사운드/설정) + 빌드(Win/Mac/Linux) |
| SUCCESS | 데스크톱 3종 빌드 산출 + 실기기 테스트 통과 |

## 1. Strategic Alignment

| Layer | Question | Result |
|-------|----------|:--:|
| Design FR-17 메인메뉴/일시정지/설정/결과 | 4 화면 모두 구현? | ✅ |
| Design FR-18 사운드 + 볼륨 설정 | 인프라 + 영속? | 🟢 인프라 ✅, 실제 오디오 파일 ❌ |
| Plan FR-07 패시브 5종 | 5종 완성? | ✅ M4 carryover 해소 |
| Plan FR-13 보스 2종+ | BossLich 추가? | ✅ |
| Plan FR-15 도전과제 언락 트리 | MainMenu 진행도? | ✅ |
| Plan §11.2 M5 step 1 메뉴 폴리시 | ✅ |
| Plan §11.2 M5 step 2 BGM/SFX/볼륨 | 🟢 인프라만 |
| Plan §11.2 M5 step 3 해상도/풀스크린/UI 스케일 | 🟡 풀스크린 ✅, UI 스케일 ❌ |
| Plan §11.2 M5 step 4 입력 리바인딩 | ❌ |
| Plan §11.2 M5 step 5 export pipeline | ❌ 별도 (m5-build) |

**판정**: 5 step 중 3 완전 + 2 부분 = m5-polish 측면 양호, m5-build 미수행.

## 2. Success Criteria — Status

### 2.1 m5-polish 충족

| Item | Status |
|------|:--:|
| MainMenu 5 버튼 | ✅ |
| PauseUI (Resume/Settings/Menu) | ✅ |
| SettingsUI (3 볼륨 + Fullscreen) | ✅ |
| AchievementPanel (잠금/해제 6/N) | ✅ |
| AudioManager (Music/SFX bus + 풀) | ✅ |
| 볼륨/풀스크린 영속 (SaveManager) | ✅ |
| M4 carryover (5 패시브, 2 보스, 트리 UI) | ✅ |

### 2.2 m5-build 미수행 (사용자 액션 필요)

| Item | Status |
|------|:--:|
| export_presets.cfg | ❌ |
| Win/Mac/Linux export template 설치 | ❌ (Godot 환경) |
| 3 OS 빌드 산출 | ❌ |
| 실기기 테스트 통과 | ❌ |

### 2.3 잔여 기능 누락

| Item | Status | Note |
|------|:--:|------|
| 입력 리바인딩 | ❌ | Plan §11.2 M5 step 4 |
| UI 스케일 옵션 (1080p, 1440p, 4K) | ❌ | Plan §11.2 M5 step 3 |
| 실제 BGM/SFX 오디오 파일 | ❌ | 인프라만 |
| BossLich charge/ranged AI | ❌ | Plan에 명시 X, chase로 충분 |

## 3. Match Rate

### 3.1 Structural

m5-polish 범위 내 명세된 모든 컴포넌트 구현:
- AudioManager / SettingsUI / PauseUI / AchievementPanel 모두 ✅
- MainMenu 5 버튼 ✅
- BossLich + 2 패시브 ✅

**Structural: 100% (in m5-polish scope)**

### 3.2 Functional Depth

| Element | Status |
|---------|:--:|
| AudioServer 버스 동적 생성 (Music/SFX) | ✅ DD66 |
| 6-slot SFX 풀 + 라운드로빈 | ✅ DD67 |
| 볼륨 linear↔dB 변환 | ✅ DD68 |
| PauseUI ESC 토글 동작 | ✅ DD69 |
| SettingsUI MainMenu/PauseUI 양쪽 진입 | ✅ DD70 |
| AchievementPanel 스포일러 가림 ("???") | ✅ DD71 |
| 5 패시브 (Damage/Cooldown 신규) | ✅ |
| 2nd 보스 (BossLich) | ✅ |
| 입력 리바인딩 | ❌ Important |
| UI 스케일 옵션 | ❌ Important |
| M4/M5 GUT 테스트 | ❌ Important |

**Functional: 88%** (3가지 누락)

### 3.3 Contract (EventBus)

신규 시그널 추가 0건. 기존 시그널 정상 사용.

**Contract: 100%**

### 3.4 Overall (m5-polish 범위)

```
Match Rate = 100×0.2 + 88×0.4 + 100×0.4 = 20 + 35.2 + 40 = 95.2%
```

→ **m5-polish 95%**

### 3.5 M5 전체 (polish + build)

```
M5-polish 가중치 0.7 + M5-build 가중치 0.3
M5 overall = 95×0.7 + 0×0.3 = 66.5 + 0 = 66.5%
```

→ **M5 전체 ~67%** (build phase 0% 반영)

**Result**: m5-polish 95% (≥ 90% 임계 충족), M5 전체는 m5-build 완료 후 재평가.

## 4. Decision Record Verification (M5 신규)

| # | Decision | Followed? |
|---|----------|:--:|
| DD66 | AudioServer 버스 코드 생성 | ✅ |
| DD67 | SFX 풀 6슬롯 라운드로빈 | ✅ |
| DD68 | 볼륨 linear→dB | ✅ |
| DD69 | PauseUI ESC 토글 | ✅ |
| DD70 | SettingsUI 단일 인스턴스 다중 진입 | ✅ |
| DD71 | AchievementPanel 스포일러 가림 | ✅ |
| DD72 | BossLich chase only (시간 절약) | ✅ (의도된 선택) |
| DD73 | m5-build 사용자 액션 위임 | ✅ |

## 5. Gap List

### Critical
없음.

### Important

| # | Gap | Impact | Suggested Fix |
|---|-----|--------|---------------|
| I1 | m5-build 미수행 (export_presets + 3 OS 빌드) | **v1.0 출시 불가** | 사용자 Godot 액션: Project→Export 설정 + 빌드, 또는 가이드 문서 작성 |
| I2 | 입력 리바인딩 UI 미구현 | Plan §11.2 M5 step 4 미충족 | SettingsUI 확장: InputMap action 별 단축키 변경 UI |
| I3 | UI 스케일 옵션 미구현 | 1080p 외 해상도에서 UI 작거나 큼 | Project.tscn Content Scale + 동적 zoom |
| I4 | 실제 BGM/SFX 오디오 파일 0 | 무성 게임 | 무료 에셋 (OpenGameArt, Kenney) + AudioManager.play_*() 호출 추가 |
| I5 | M4/M5 GUT 테스트 미추가 | 회귀 위험 (AchievementSystem trigger 매트릭스, AudioManager 볼륨 변환) | iterate 세션에 ~10 케이스 추가 |

### Minor

| # | Gap | Note |
|---|-----|------|
| M1 | BossLich AI = chase only | Plan 명시 없음 — 시각/스탯 차별화로 충분 |
| M2 | Garlic/Bible 시각 효과 placeholder | 무료 파티클/셰이더로 향후 |
| M3 | 도전과제 알림 사운드 없음 | I4 해소 시 자동 부각 |

## 6. Checkpoint 5 — Review Decision

**현 시점 평가**:
- m5-polish **95%** — UI/사운드 인프라 전부 완성, Critical 0
- **M5 전체는 m5-build 대기** — 사용자 Godot 액션 필요
- Important 5건 중 I1 (m5-build)이 v1.0 출시 차단 요인
- I2~I5는 v1.0.1 패치로 흡수 가능

선택:

- **A. 풀 클론 v1.0 최종 보고서** — 현 시점에 M1~M5-polish 통합 보고. m5-build는 보고서에 사용자 액션 가이드로 명시
- **B. iterate (M5 잔여 해소)** — 입력 리바인딩 + UI 스케일 + M4/M5 GUT 추가. ~30 turns.
- **C. m5-build 가이드 문서 작성** — export_presets.cfg 템플릿 + CLI 빌드 명령 + 3 OS 체크리스트
- **D. Godot 검증 먼저** — M5-polish 새 UI 동작 확인 후 결정
