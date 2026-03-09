---
name: tdd
description: "TDD 사이클을 실행합니다. 전체 사이클(start) 또는 개별 단계(scenario/red/green/refactor)를 선택할 수 있습니다."
user-invocable: true
argument-hint: "[scenario|red|green|refactor|start|status] <요구사항 또는 파일경로>"
agent: tdd-runner
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /tdd — TDD 사이클

> 트리거 키워드: TDD, 테스트, test, 테스트 주도, 테스트 먼저

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 액션 라우팅

| 입력 | 동작 |
|------|------|
| `/tdd start <요구사항>` | 전체 TDD 사이클 순차 실행 |
| `/tdd scenario <요구사항 또는 파일경로>` | 테스트 시나리오만 작성 |
| `/tdd red [시나리오경로]` | 실패하는 테스트만 작성 |
| `/tdd green` | 최소 구현 코드만 작성 |
| `/tdd refactor` | 코드 품질 개선만 실행 |
| `/tdd status` | 현재 TDD 상태 표시 |

> `$ARGUMENTS`의 첫 번째 단어가 위 액션과 일치하지 않으면 `start`로 처리한다.

---

## `start` — 전체 사이클 실행

`/tdd start <요구사항 또는 파일경로>`

전체 TDD 사이클을 순차 실행한다:

1. **scenario** — 요구사항을 분석하여 테스트 시나리오를 도출한다.
2. **red** — 시나리오 기반으로 실패하는 테스트를 작성한다.
3. **green** — 테스트를 통과시키는 최소 구현을 작성한다.
4. **refactor** — 테스트를 유지하면서 코드 품질을 개선한다.

각 단계마다 TDD 상태 박스를 출력하고, `.claude/state/tdd-state.json`에 상태를 저장한다.

---

## `status` — 상태 확인

`/tdd status`

1. `.claude/state/tdd-state.json`을 읽는다.
2. 현재 Phase, 테스트 결과, 작업 중인 기능을 박스 형태로 출력한다.

파일이 없으면 "진행 중인 TDD 사이클이 없습니다."를 출력한다.

---

## `scenario` — 테스트 시나리오 작성

`/tdd scenario <요구사항 또는 파일경로>`

### 동작

1. 요구사항 또는 기능명세서를 분석한다.
2. 테스트 대상을 책임별로 분류한다. ([scenario-guide.md](references/scenario-guide.md) 참조)
3. 각 대상에 대해 BDD 스타일 테스트 시나리오를 작성한다.
4. 시나리오를 파일로 저장하고 TDD 상태를 `scenario`로 갱신한다.

### 규칙

- `describe`와 `it` 이름을 유저 스토리로 서술한다. 구현 세부사항(함수명, 상태명)을 넣지 않는다.
- 컴포넌트 테스트에서는 에러 메시지의 구체적 텍스트가 아닌, 에러 영역의 표시 여부만 시나리오에 포함한다.
- 정상 플로우, 경계값, 에러 케이스, 엣지 케이스를 포함한다.
- [test-conventions.md](references/test-conventions.md)의 BDD 구조, `it` 작성 원칙, 책임 분리를 따른다.

### 주의사항

- 시나리오 단계에서는 **테스트 코드를 작성하지 않는다.** 시나리오 문서만 산출한다.
- 기존 프로젝트 코드를 탐색하여 테스트 파일 위치와 네이밍 패턴을 따른다.

---

## `red` — 실패하는 테스트 작성

`/tdd red [시나리오 파일경로]`

### 동작

1. 테스트 시나리오를 확인한다. 인수가 없으면 `.claude/state/tdd-state.json`의 `scenarioFile`을 참조한다.
2. 시나리오에 정의된 테스트를 코드로 작성한다.
3. 테스트를 실행하여 **모두 FAIL**인지 확인한다.
4. TDD 상태를 `red`로 저장한다.

### 규칙

- [test-conventions.md](references/test-conventions.md)를 따른다: BDD 스타일, 책임 분리, 클래시스트 우선.
- `config.json`의 `test.filePatterns`를 참조하여 파일 패턴을 결정한다.
- PASS하는 테스트가 있으면 구현 없이 통과하는 의미 없는 테스트이므로 수정한다.

### 주의사항

- 이 단계에서는 **테스트 코드만 작성한다.** 구현 코드를 작성하지 않는다.
- 경계값, 에러 케이스, 엣지 케이스를 포함하는 테스트를 작성한다.

---

## `green` — 최소 구현 작성

`/tdd green`

### 동작

1. `.claude/state/tdd-state.json`에서 현재 실패 중인 테스트 파일을 확인한다.
2. 테스트를 실행하여 실패하는 테스트 목록을 파악한다.
3. 테스트를 통과시키는 **최소한의** 구현 코드를 작성한다.
4. 테스트를 실행하여 **모두 PASS**인지 확인한다.
5. TDD 상태를 `green`으로 저장한다.

### 규칙

- **최소한의 코드**: 테스트를 통과시키는 데 필요한 코드만 작성한다. 미래 요구사항을 예측하여 코드를 추가하지 않는다.
- **테스트가 요구하는 것만 구현한다**: 테스트에 없는 기능을 구현하지 않는다.
- **리팩토링은 다음 단계에서**: 코드 품질 개선, 중복 제거, 구조 정리는 Refactor 단계에서 수행한다.

### 주의사항

- 이 단계에서는 **구현 코드만 작성한다.** 테스트 코드를 수정하지 않는다.
- 기존에 통과하던 다른 테스트가 깨지지 않는지 확인한다.

---

## `refactor` — 코드 품질 개선

`/tdd refactor`

### 동작

1. 현재 테스트가 모두 PASS인지 확인한다. FAIL하는 테스트가 있으면 중단한다.
2. 구현 코드와 테스트 코드를 검토하여 개선 포인트를 식별한다. ([refactor-checklist.md](references/refactor-checklist.md) 참조)
3. 코드 품질을 개선한다.
4. 리팩토링 후 테스트를 다시 실행하여 **모두 PASS**인지 확인한다.
5. TDD 상태를 `done`으로 저장한다.

### 주의사항

- **기능을 추가하지 않는다.** 외부 동작을 변경하지 않는 내부 구조 개선만 수행한다.
- 테스트가 하나라도 FAIL하면 리팩토링을 되돌리고 더 작은 단위로 나누어 재시도한다.

---

## 공통: 테스트 타입 자동 판별

`config.json`의 `test.filePatterns`를 참조:

| 패턴 | 테스트 타입 | 실행 명령 |
|------|-----------|----------|
| `*.test.ts` | Vitest 단위 테스트 | `npx vitest run <file>` |
| `*.test.tsx` | Vitest + React Testing Library 통합 테스트 | `npx vitest run <file>` |
| `*.spec.ts` | Playwright E2E 테스트 | `npx playwright test <file>` |

## 공통: TDD 상태 파일

경로: `config.json`의 `tdd.stateFile` (기본값 `.claude/state/tdd-state.json`)

### 상태 파일 구조

```json
{
  "feature": "기능 설명",
  "phase": "scenario|red|green|refactor|done",
  "scenarioFile": "경로",
  "testFile": "경로",
  "implFile": "경로",
  "tests": { "total": 5, "pass": 0, "fail": 5 },
  "updatedAt": "ISO 8601"
}
```

### 상태 저장 규칙

1. **디렉토리 생성**: 상태를 처음 저장할 때 `mkdir -p .claude/state`를 실행한다.
2. **단계별 필드 갱신**:

| 단계 | 설정하는 필드 |
|------|-------------|
| `scenario` | `feature`, `phase: "scenario"`, `scenarioFile`, `updatedAt` |
| `red` | `phase: "red"`, `testFile`, `tests` (total/pass/fail), `updatedAt` |
| `green` | `phase: "green"`, `implFile`, `tests` (갱신), `updatedAt` |
| `refactor` | `phase: "done"`, `tests` (갱신), `updatedAt` |

3. **파일이 없는 경우**: `red`, `green`, `refactor`에서 상태 파일이 없으면 사용자에게 이전 단계 실행을 안내한다.

## 공통: 출력 형식

각 단계마다 다음 박스를 출력한다:

```
┌─ TDD: <기능명> ─────────────────────────┐
│ Phase: ● Red   ○ Green   ○ Refactor    │
│ Tests: 0/5 pass                         │
│ Type:  Unit (Vitest)                    │
│ File:  <테스트 파일 경로>                 │
└─────────────────────────────────────────┘
```

## 공통: 품질 리뷰

`config.json`의 `tdd.qualityReview: true`이면, `red`와 `green` 단계 완료 후 `test-reviewer` 에이전트로 테스트 품질을 검증한다.

## 참조 문서

- [test-conventions.md](references/test-conventions.md) — BDD 구조, it 작성 원칙, 책임 분리, mock 전략
- [scenario-guide.md](references/scenario-guide.md) — 시나리오 분류 기준, 산출물 형식
- [refactor-checklist.md](references/refactor-checklist.md) — 리팩토링 대상 체크리스트
