---
name: review
description: "git diff 기반으로 변경사항을 리뷰합니다. 코드 품질, 보안, 테스트 커버리지를 검사합니다."
user-invocable: true
argument-hint: "[--security|--test]"
agent: code-reviewer
allowed-tools: Read, Grep, Glob, Bash
---

# /review — 코드 리뷰

> 트리거 키워드: 리뷰, review, 코드 검사, 품질 검사, 보안 검사

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 액션별 동작

**`/review`** — 기본 코드 리뷰
1. git diff로 현재 변경사항을 파악한다.
2. 코드 품질, 타입 안전성, 에러 처리, 컨벤션 준수를 검사한다.
3. Critical / Warning / Info 등급으로 결과를 출력한다.

**`/review --security`** — 보안 집중 리뷰
1. git diff로 현재 변경사항을 파악한다.
2. XSS, 인젝션, 인증 누락, 민감 데이터 노출을 중점 검사한다.
3. 보안 관련 문제를 등급별로 출력한다.

**`/review --test`** — 테스트 커버리지 관점 리뷰
1. git diff로 변경된 소스 파일을 파악한다.
2. 각 변경 파일에 대응하는 테스트 파일이 있는지 확인한다.
3. 테스트가 없거나 부족한 경우를 지적한다.
4. 테스트 품질 (경계값, assertion 등)을 검사한다.

## 출력 형식

```
┌─ Code Review ───────────────────────────┐
│ Scope:   <리뷰 범위>                     │
│ Files:   <변경 파일 수>                   │
│ Issues:  <발견된 문제 수>                 │
│ Quality: ● Good / ▲ Needs Work / ✗ Poor │
└──────────────────────────────────────────┘
```

## 주의사항
- 코드를 수정하지 않습니다. 리뷰 결과만 출력합니다.
- git 저장소가 아닌 환경에서는 사용할 수 없습니다.
