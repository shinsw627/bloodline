---
name: commit
description: 변경사항을 Git에 커밋하고 푸시합니다
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# Git Commit & Push 스킬

현재 변경사항을 분석하여 커밋 메시지를 자동 생성하고 커밋합니다.

## 실행 절차

### 1. 변경사항 분석

```bash
git status
git diff --staged
git diff
git log --oneline -5
```

### 2. 커밋 메시지 자동 생성

변경사항을 분석하여 아래 형식으로 메시지 생성:

```
[타입] 간단한 설명

- 변경사항 1
- 변경사항 2

특이사항: (있는 경우만)
```

**타입 자동 판단:**
| 변경 내용 | 타입 |
|----------|------|
| 새 파일 추가 | feat |
| 버그 수정 | fix |
| 코드 개선 | refactor |
| 문서 변경 | docs |
| 테스트 추가 | test |
| 설정 변경 | chore |

### 3. 코드 설명 규칙

- **5줄 이하**: 간단히 설명
- **5줄 초과**: 무엇을 왜 변경했는지 상세 설명
- **특이사항**: breaking change, 주의사항 명시

### 4. 사용자 확인

생성된 커밋 메시지를 사용자에게 보여주고 확인:
- "확인" → 커밋 진행
- 수정 요청 → 메시지 수정 후 재확인

### 5. 커밋 & 푸시

```bash
git add [변경된 파일들]
git commit -m "메시지"
git push origin [현재 브랜치]
```

## 예시

변경사항:
```
M  src/main/java/.../controller/MessageController.java
A  src/main/java/.../service/MessageService.java
A  src/test/java/.../MessageServiceTest.java
```

자동 생성 메시지:
```
[feat] 메시지 발송 기능 추가

- MessageController: send() 엔드포인트 추가
- MessageService: 발송 로직 구현 (잔액 확인 포함)
- MessageServiceTest: 단위 테스트 8개 추가

특이사항: 잔액 부족 시 InsufficientBalanceException 발생
```

## 금지 사항
- Co-Authored-By: Claude Opus 4.5 클로드 관련 내용 금지
- 민감 정보 (.env, credentials) 커밋 금지
- force push 금지
- main/dev 브랜치 직접 push 전 확인
