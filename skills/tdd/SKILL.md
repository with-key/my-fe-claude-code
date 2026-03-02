---
name: tdd
description: "TDD(Test-Driven Development) 사이클을 자동화합니다. 요구사항을 입력하면 Red → Green → Refactor 흐름을 수행하고, 테스트 품질까지 검증합니다."
user-invocable: true
argument-hint: "[start|red|green|refactor|status] <요구사항>"
agent: tdd-runner
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /tdd — TDD 사이클 자동화

> 트리거 키워드: TDD, 테스트, test, red, green, refactor, 테스트 주도, 테스트 먼저

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 액션별 동작

**`/tdd start <요구사항 또는 파일경로>`** — TDD 흐름 전체 실행
1. 요구사항을 분석하여 테스트 케이스를 도출한다.
2. Red → Green → Refactor 사이클을 순차적으로 수행한다.
3. 각 단계마다 TDD 상태 박스를 출력한다.
4. `config.json`의 `tdd.qualityReview: true`이면 Green 단계 후 `test-reviewer` 에이전트로 품질 검증한다.
5. TDD 상태를 `.claude/state/tdd-state.json`에 저장한다.

**`/tdd red <요구사항>`** — 실패하는 테스트만 작성
1. 요구사항을 분석하여 테스트 케이스를 도출한다.
2. 실패하는 테스트 코드를 작성한다.
3. 테스트를 실행하여 모두 FAIL인지 확인한다.
4. TDD 상태를 Red로 저장한다.

**`/tdd green`** — 현재 실패 테스트를 통과시키는 구현 작성
1. 현재 실패 중인 테스트를 확인한다.
2. 테스트를 통과시키는 최소한의 구현 코드를 작성한다.
3. 테스트를 실행하여 모두 PASS인지 확인한다.
4. TDD 상태를 Green으로 저장한다.

**`/tdd refactor`** — 테스트 통과 유지하면서 코드 개선
1. 현재 테스트가 모두 PASS인지 확인한다.
2. 코드 품질을 개선한다 (중복 제거, 네이밍 개선, 구조 정리).
3. 리팩토링 후 테스트를 다시 실행하여 모두 PASS인지 확인한다.
4. TDD 상태를 Refactor 완료로 저장한다.

**`/tdd status`** — 현재 TDD 상태 표시
1. `.claude/state/tdd-state.json`을 읽는다.
2. 현재 Phase, 테스트 결과, 작업 중인 기능을 박스 형태로 출력한다.

## 테스트 타입 자동 판별

`config.json`의 `test.filePatterns`를 참조:
- `*.test.ts` → Vitest 단위 테스트 (`npx vitest run <file>`)
- `*.test.tsx` → Vitest + React Testing Library 통합 테스트 (`npx vitest run <file>`)
- `*.spec.ts` → Playwright E2E 테스트 (`npx playwright test <file>`)

## TDD 상태 파일 (`tdd-state.json`) 구조

```json
{
  "feature": "기능 설명",
  "phase": "red|green|refactor|done",
  "testFile": "경로",
  "implFile": "경로",
  "tests": {
    "total": 5,
    "pass": 0,
    "fail": 5
  },
  "updatedAt": "ISO 8601"
}
```

## 출력 형식

각 단계마다 다음 박스를 출력한다:

```
┌─ TDD: <기능명> ─────────────────────────┐
│ Phase: ● Red   ○ Green   ○ Refactor    │
│ Tests: 0/5 pass                         │
│ Type:  Unit (Vitest)                    │
│ File:  <테스트 파일 경로>                 │
└─────────────────────────────────────────┘
```

## 주의사항
- Green 단계에서는 **테스트를 통과시키는 최소한의 코드**만 작성한다.
- Refactor 단계에서는 반드시 테스트를 다시 실행하여 깨지지 않았는지 확인한다.
- 경계값, 에러 케이스, 엣지 케이스를 포함하는 테스트를 작성한다.
