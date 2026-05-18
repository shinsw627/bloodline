---
name: pr
description: Pull Request를 생성합니다
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# Pull Request 생성 스킬

현재 브랜치의 변경사항을 분석하여 PR을 자동 생성합니다.

## 실행 절차

### 1. 변경사항 분석

```bash
git branch --show-current
git log dev..HEAD --oneline
git diff dev...HEAD --stat
git diff dev...HEAD
```

### 2. PR 제목/본문 자동 생성

변경사항을 분석하여 아래 형식으로 생성:

```markdown
## 개요
[변경사항 요약 1-2문장]

## 변경사항
- 변경사항 1
- 변경사항 2

## 프로젝트 구조 변경
```
[새로 추가/변경된 파일 구조]
src/main/java/.../
├── controller/
│   └── MessageController.java (신규)
└── service/
    └── MessageService.java (신규)
```

## 변경된 파일
| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| 파일명 | 신규/수정/삭제 | 간단 설명 |

## 로직 설명

### [기능명]
[5줄 이하: 간단 설명]

### [복잡한 기능명] (상세)

**목적**: [왜 필요한지]

**흐름**:
1. [단계 1]
2. [단계 2]
3. [단계 3]

**주의사항**: [있는 경우]

## 테스트
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과

## 특이사항
[breaking change, 환경변수 추가 등]
```

### 3. 사용자 확인

생성된 PR 내용을 사용자에게 보여주고 확인:
- "확인" → PR 생성 진행
- 수정 요청 → 내용 수정 후 재확인

### 4. PR 생성

```bash
git push origin [현재 브랜치]
gh pr create --title "[제목]" --body "[본문]" --base dev
```

## 로직 설명 규칙

| 코드 길이 | 설명 방식 |
|----------|----------|
| 5줄 이하 | 1-2줄 간단 설명 |
| 5줄 초과 | 목적 → 흐름 → 주의사항 |

## 예시

변경사항:
```
A  controller/MessageController.java
A  service/MessageService.java
A  repository/message/MessageRepository.java
M  build.gradle
```

자동 생성 PR:

**제목**: `[feat] 메시지 발송 API 구현`

**본문**:
```markdown
## 개요
SMS 메시지 발송을 위한 REST API를 구현했습니다.

## 변경사항
- 메시지 CRUD API 추가
- 메시지 발송 기능 구현
- 잔액 확인 로직 추가

## 프로젝트 구조 변경
```
src/main/java/com/addeep/smsapi/
├── controller/
│   └── MessageController.java (신규)
├── service/
│   └── MessageService.java (신규)
└── repository/message/
    └── MessageRepository.java (신규)
```

## 변경된 파일
| 파일 | 변경 유형 | 설명 |
|------|----------|------|
| MessageController.java | 신규 | 6개 엔드포인트 |
| MessageService.java | 신규 | CRUD + 발송 로직 |
| MessageRepository.java | 신규 | 커스텀 쿼리 |
| build.gradle | 수정 | 의존성 추가 |

## 로직 설명

### 메시지 발송 (상세)

**목적**: SMS 발송 전 잔액 확인 및 차감

**흐름**:
1. 메시지 ID로 메시지 조회
2. 사용자 잔액 확인
3. 잔액 부족 시 예외 발생
4. 잔액 충분 시 발송 및 차감

**주의사항**: 트랜잭션으로 묶여 실패 시 롤백

## 테스트
- [x] 단위 테스트 통과
- [x] 통합 테스트 통과

## 특이사항
- 환경변수 추가: SMS_API_URL, SMS_API_KEY
```

## 옵션

- base 브랜치: dev (기본)
- draft PR이 필요하면 사용자에게 확인
