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

## React Testing Library 테스트 작성 원칙

### BDD 스타일 구조

`*.test.tsx` (React Testing Library) 테스트는 BDD(Behavior-Driven Development) 스타일로 작성한다.
사용자 행동과 기대 결과를 중심으로 `describe` → `it` 구조를 구성한다.

```tsx
describe('장바구니', () => {
  describe('상품 수량 변경', () => {
    it('증가 버튼을 클릭하면 수량이 1 증가한다', () => { ... });
    it('수량이 99일 때 증가 버튼이 비활성화된다', () => { ... });
    it('수량이 1일 때 감소 버튼을 클릭하면 삭제 확인 다이얼로그가 표시된다', () => { ... });
  });
});
```

- `describe`는 기능/컨텍스트 단위로 중첩하여 시나리오를 그룹화한다.
- `it`은 **사용자 행동 → 기대 결과** 형태로 작성한다. 내부 구현이 아닌 동작을 서술한다.
- 테스트 이름만 읽어도 기능 명세서처럼 이해할 수 있어야 한다.

### 모키스트 vs 클래시스트 전략

테스트 대상의 성격에 따라 적절한 방식을 선택한다.

**클래시스트 (Classicist)** — 기본 전략. 실제 구현에 가깝게 테스트한다.
- 컴포넌트 렌더링 + 사용자 인터랙션 테스트
- 상태 변경에 따른 UI 반영 테스트
- 자식 컴포넌트를 mock하지 않고 함께 렌더링한다.

**모키스트 (Mockist)** — 외부 의존성이 있을 때 사용한다.
- API 호출: `msw` 또는 `vi.mock`으로 네트워크 요청을 mock한다.
- 라우터/네비게이션: 라우터 동작을 mock한다.
- 타이머/날짜: `vi.useFakeTimers()`로 시간 의존 로직을 제어한다.
- 복잡한 전역 상태: 외부 store를 mock하여 특정 상태를 주입한다.

**판단 기준:**
- 컴포넌트 자체의 렌더링과 인터랙션 → 클래시스트
- 외부 시스템(API, 라우터, 브라우저 API)과의 경계 → 모키스트
- 판단이 어려우면 클래시스트를 우선하고, 테스트가 느리거나 불안정하면 모키스트로 전환한다.

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
