# 프론트엔드 개발 플러그인 셋 — 계획서 v3
---

## 1. 프로젝트 개요

### 목적
프론트엔드 개발자가 반복적으로 수행하는 작업들을 Claude Code의 skill, subagent, hooks로 자동화한다.

### 핵심 가치
- **기획 문서 → 개발 산출물** 변환 자동화
- **TDD 기반 개발 흐름** 자동화
- **디자인 시스템 기반 UI 구현** 자동화
- **시각적 피드백** — 진행 상태를 한눈에 파악

### 배포 형태
- 1단계: `~/.claude/`에 직접 설치 (개인용)
- 2단계: Claude Code 플러그인으로 패키징 (`.claude-plugin/plugin.json`, 팀 공유)

---

## 2. 기술 스택 (확정)

| 항목 | 선택 |
|------|------|
| 기획 문서 형태 | Markdown |
| 테스트 프레임워크 | Vitest + React Testing Library + Playwright |
| 테스트 범위 | 단위 + 통합 + E2E |
| 디자인 시스템 | Base UI 기반 (문서화 진행 중) |
| 스타일링 | Panda CSS + 디자인 토큰 |
| 디자인 시안 입력 | 텍스트 설명 + 스크린샷 (Claude 멀티모달) |
| 컨벤션 문서 | 없음 → `/convention` 스킬로 자동 생성 |

---

## 3. 플러그인 구성

### 3-1. `/convention` — 컨벤션 자동 추출 (0번 작업)

**문제:**
프로젝트 컨벤션 문서가 없다. 에이전트들이 참고할 기준이 없으면 일관성 없는 코드가 나온다.

**Skill: `/convention`**
```
/convention scan              — 기존 코드베이스를 분석하여 패턴 추출
/convention generate          — 추출된 패턴으로 CLAUDE.md 초안 생성
/convention update            — 기존 CLAUDE.md에 새로 발견된 패턴 추가
```

**Agent: `convention-scanner`**
- model: sonnet
- tools: Read, Grep, Glob (읽기 전용)
- permissionMode: plan
- 역할: 코드베이스에서 반복되는 패턴을 분석
  - 파일 구조, 네이밍 규칙, import 패턴
  - 컴포넌트 작성 방식, 상태 관리 패턴
  - Panda CSS 토큰 사용 패턴
  - 테스트 파일 위치/작성 패턴

**산출물:**
```
입력: 프로젝트 소스코드
  ↓
출력: CLAUDE.md (프로젝트 컨벤션 + 구조 + 명령어 정리)
```

---

### 3-2. `/spec` — 기획 문서 수집 & 변환

**문제:**
기획자가 작성한 PRD, 기능명세서, 정책 정의서가 개발에 바로 쓸 수 있는 형태가 아니다.

**Skill: `/spec`**
```
/spec analyze <파일경로>        — 기획 문서를 분석하여 개발 산출물 생성
/spec test-scenario <파일경로>  — 테스트 시나리오 문서 생성 (Given-When-Then)
/spec component <파일경로>      — 컴포넌트 명세 문서 생성
/spec api <파일경로>            — API 연동 스펙 문서 생성
```

**Agent: `spec-analyzer`**
- model: sonnet
- tools: Read, Write, Grep, Glob
- 역할: Markdown 기획 문서를 파싱하여 구조화된 개발 문서로 변환

**산출물 예시:**
```
입력: PRD "장바구니 기능" (cart-prd.md)
  ↓
출력 1: test-scenarios/cart.md       (Given-When-Then 테스트 시나리오)
출력 2: component-specs/cart.md      (컴포넌트 구조 + props 명세)
출력 3: api-specs/cart.md            (API 엔드포인트 + 요청/응답 스펙)
```

---

### 3-3. `/tdd` — TDD 스킬 & 서브에이전트

**문제:**
TDD를 하고 싶지만 테스트 코드 작성 비용이 높아 실무에서 적용하기 어렵다.

**Skill: `/tdd`**
```
/tdd start <요구사항 또는 파일경로>  — TDD 흐름 시작 (Red → Green → Refactor)
/tdd red <요구사항>                  — 실패하는 테스트만 작성
/tdd green                           — 현재 실패 테스트를 통과시키는 구현 작성
/tdd refactor                        — 테스트 통과 유지하면서 코드 개선
/tdd status                          — 현재 테스트 상태 + 진행 현황 표시
```

**Agent: `tdd-runner`**
- model: sonnet
- tools: Read, Write, Edit, Bash, Grep, Glob
- memory: project (프로젝트별 테스트 패턴 학습)
- 역할: 테스트 작성 → 실행 → 구현 → 재실행의 TDD 사이클 수행
- 테스트 타입 자동 판별:
  - `*.test.ts` → Vitest (단위)
  - `*.test.tsx` → Vitest + React Testing Library (통합)
  - `*.spec.ts` → Playwright (E2E)

**Agent: `test-reviewer`** (bkit gap-detector 패턴)
- model: sonnet
- tools: Read, Grep, Glob (읽기 전용)
- permissionMode: plan (코드 수정 불가)
- context: fork (원본 컨텍스트 오염 방지)
- 역할: 작성된 테스트의 품질 검증
  - "통과하기 쉬운 허술한 테스트" 감지
  - 경계값/엣지케이스 누락 지적
  - PRD 요구사항 대비 테스트 커버리지 분석

**TDD 흐름:**
```
/tdd start "수량은 1~99 사이로 제한된다"
  ↓
[tdd-runner] 테스트 코드 작성 (Red)
  ↓  vitest 실행 → ALL FAIL 확인
  ↓
  ↓  ┌─ TDD ──────────────────────────────┐
  ↓  │ Phase: ● Red   ○ Green  ○ Refactor │
  ↓  │ Tests: 0/5 pass                    │
  ↓  └────────────────────────────────────┘
  ↓
[tdd-runner] 구현 코드 작성 (Green)
  ↓  vitest 실행 → ALL PASS 확인
  ↓
  ↓  ┌─ TDD ──────────────────────────────┐
  ↓  │ Phase: ✓ Red   ● Green  ○ Refactor │
  ↓  │ Tests: 5/5 pass                    │
  ↓  └────────────────────────────────────┘
  ↓
[test-reviewer] 테스트 품질 검증 (fork된 컨텍스트에서)
  ↓  "경계값 0, 100에 대한 테스트 추가 권장"
  ↓
[tdd-runner] 피드백 반영 + 리팩토링 (Refactor)
  ↓
  ↓  ┌─ TDD ──────────────────────────────┐
  ↓  │ Phase: ✓ Red   ✓ Green  ✓ Refactor │
  ↓  │ Tests: 7/7 pass                    │
  ↓  │ Quality: ● Good (reviewer 통과)     │
  ↓  └────────────────────────────────────┘
```

---

### 3-4. `/ui` — 디자인 시스템 기반 UI 구현

**문제:**
디자인 시스템(Base UI + Panda CSS)의 컴포넌트를 조합하여 UI를 구현하는 과정이 반복적이다.

**Skill: `/ui`**
```
/ui build <요구사항 또는 스크린샷>   — 디자인 시스템 기반 UI 코드 생성
/ui component <컴포넌트명>          — 디자인 시스템 컴포넌트 사용법 안내
/ui tokens                          — 사용 가능한 디자인 토큰 목록 표시
/ui review                          — 현재 코드가 디자인 시스템을 올바르게 사용하는지 검토
```

**Agent: `ui-builder`**
- model: sonnet
- tools: Read, Write, Edit, Bash, Grep, Glob
- memory: project (프로젝트별 UI 패턴 학습)
- 역할: Base UI 컴포넌트 + Panda CSS 토큰으로 UI 코드 작성

**Agent: `design-reviewer`**
- model: sonnet
- tools: Read, Grep, Glob (읽기 전용)
- permissionMode: plan
- 역할: 디자인 시스템 규칙 준수 검증
  - 하드코딩된 색상/간격 대신 토큰을 사용하는지
  - Base UI 컴포넌트를 올바르게 사용하는지

---

### 3-5. `/impact` — PRD 변경 영향 분석

**문제:**
기획이 변경되면 어떤 테스트와 코드를 수정해야 하는지 파악하는 데 시간이 걸린다.

**Skill: `/impact`**
```
/impact <변경된 PRD 경로>    — 이 PRD 변경이 영향을 미치는 테스트/코드 파일 목록
/impact diff <이전> <이후>   — 두 버전의 PRD를 비교하여 변경점과 영향 범위 분석
```

**Agent: `impact-analyzer`**
- model: sonnet
- tools: Read, Grep, Glob (읽기 전용)
- permissionMode: plan
- 역할: PRD 변경사항과 기존 테스트/코드의 매핑 관계 분석

**산출물 예시:**
```
PRD 변경: "수량 제한 1~99 → 1~999로 변경"
  ↓
영향받는 파일:
  - src/cart/useCart.test.ts        (경계값 테스트 수정 필요)
  - src/cart/useCart.ts             (MAX_QUANTITY 상수 변경)
  - src/cart/CartInput.tsx          (input max 속성 변경)
  - e2e/cart.spec.ts               (E2E 시나리오 수정 필요)
```

---

### 3-6. `/review` — 코드 리뷰

**Skill: `/review`**
```
/review                — git diff 기반 변경사항 리뷰
/review --security     — 보안 취약점 집중 리뷰
/review --test         — 테스트 커버리지 관점 리뷰
```

**Agent: `code-reviewer`**
- model: sonnet
- tools: Read, Grep, Glob, Bash (읽기 + git 명령)
- permissionMode: plan
- 역할: 코드 품질, 보안, 컨벤션 준수 여부 리뷰

---

### 3-7. `/help-me` — 온보딩 가이드

**Skill: `/help-me`**
```
/help-me               — 사용 가능한 모든 스킬과 사용법 안내
/help-me tdd           — /tdd 스킬 상세 사용법
/help-me workflow      — 전체 워크플로우 (spec → tdd → ui) 설명
```

---

## 4. Hooks — 자동화 & 가드레일

hooks가 플러그인을 **"적극적으로 활용되는 도구"**로 만들어줍니다.

### 4-1. SessionStart — 세션 시작 시 컨텍스트 준비

```
Claude Code 시작
  ↓
[SessionStart hook]
  ① 현재 프로젝트의 미완료 TDD 사이클 확인
  ② 마지막 세션에서 작업하던 기능/파일 요약
  ③ 사용 가능한 스킬 안내
  ↓
출력:
  ┌─ Session Resume ──────────────────────────────┐
  │ Project: biskit_frontend                       │
  │ Last:    Cart 컴포넌트 TDD (3/5 tests pass)    │
  │ Skills:  /spec  /tdd  /ui  /impact  /review    │
  │                                                │
  │ /tdd green 으로 이어서 작업하시겠습니까?          │
  └────────────────────────────────────────────────┘
```

### 4-2. PostToolUse (Write|Edit) — 코드 변경 후 자동 검증

```
코드 파일 수정됨
  ↓
[PostToolUse hook]
  ① 수정된 파일에 대응하는 테스트 파일 존재 여부 확인
  ② 존재하면 해당 테스트만 실행 (vitest run <file>)
  ③ 결과를 시각적으로 표시
  ↓
출력:
  ┌─ Auto Test ─────────────────────┐
  │ Trigger: src/cart/useCart.ts     │
  │ Run:     src/cart/useCart.test.ts│
  │ Result:  2/3 PASS | 1 FAIL     │
  └─────────────────────────────────┘
```

### 4-3. UserPromptSubmit — 사용자 입력 분석 & TDD 유도

```
사용자: "장바구니에 수량 제한 기능 추가해줘"
  ↓
[UserPromptSubmit hook]
  ① 새 기능 구현 의도 감지 (키워드: 추가, 구현, 만들어, 기능)
  ② TDD 흐름 제안
  ↓
출력 (Claude에게 주입):
  "새 기능 구현 요청이 감지되었습니다.
   /tdd start 로 TDD 흐름을 시작하는 것을 권장합니다."
```

### 4-4. PreToolUse (Write|Edit) — 보호 파일 차단

```
Claude가 보호 대상 파일 수정 시도
  ↓
[PreToolUse hook]
  ① 보호 파일 목록과 대조 (.env, lock 파일, 디자인 시스템 원본 등)
  ② 매칭되면 exit 2로 차단
  ↓
stderr: "차단: 디자인 시스템 원본 파일은 수정할 수 없습니다."
```

### 4-5. Stop — 작업 완료 시 상태 요약

```
Claude 응답 완료
  ↓
[Stop hook]
  ① 이번 턴에서 코드 변경이 있었는지 확인
  ② 변경이 있었으면: 관련 테스트 결과 요약
  ③ TDD 진행 중이면: 현재 단계 표시
  ↓
출력:
  ┌─ Summary ──────────────────────────────┐
  │ Changed: 2 files                        │
  │ Tests:   5/5 PASS                       │
  │ TDD:     ✓ Red  ✓ Green  ● Refactor    │
  └─────────────────────────────────────────┘
```

### 4-6. PreCompact — 컨텍스트 압축 전 상태 보존

```
대화가 길어져서 컨텍스트 압축 발생
  ↓
[PreCompact hook]
  ① 현재 TDD 상태를 .claude/state/tdd-state.json에 저장
     - 현재 Phase (Red/Green/Refactor)
     - 테스트 파일 목록과 pass/fail 상태
     - 작업 중인 기능명
  ② 압축 후에도 상태를 복원할 수 있게 됨
  ↓
저장: .claude/state/tdd-state.json
```

---

## 5. Output Styles — 시각적 피드백

에이전트와 스킬의 출력에 일관된 시각적 포맷을 적용합니다.

### 5-1. TDD 상태 박스

모든 TDD 관련 출력에 포함:
```
┌─ TDD: useCart ──────────────────────────┐
│ Phase: ✓ Red   ● Green   ○ Refactor    │
│ Tests: 3/5 pass                         │
│ Type:  Unit (Vitest)                    │
│ File:  src/cart/useCart.test.ts          │
└─────────────────────────────────────────┘
```

### 5-2. Spec 분석 결과 박스

```
┌─ Spec Analysis ─────────────────────────┐
│ Source:  docs/cart-prd.md                │
│ Output:                                  │
│   ✓ test-scenarios/cart.md   (12 cases)  │
│   ✓ component-specs/cart.md  (3 comps)   │
│   ✓ api-specs/cart.md        (5 endpoints)│
└──────────────────────────────────────────┘
```

### 5-3. Stop 요약 박스

```
┌─ Done ──────────────────────────────────┐
│ Changed: 2 files (useCart.ts, Cart.tsx)  │
│ Tests:   7/7 PASS                       │
│ TDD:     ✓ Red  ✓ Green  ✓ Refactor    │
│ Review:  No issues found                │
└─────────────────────────────────────────┘
```

### 5-4. Impact 분석 결과 박스

```
┌─ Impact Analysis ───────────────────────┐
│ PRD Change: 수량 제한 1~99 → 1~999      │
│ Affected:                                │
│   ● useCart.test.ts    (경계값 수정)      │
│   ● useCart.ts         (상수 변경)        │
│   ● CartInput.tsx      (input max)       │
│   ○ cart.spec.ts       (E2E 확인 필요)   │
│                                          │
│ ● 수정 필요  ○ 확인 필요                  │
└──────────────────────────────────────────┘
```

---

## 6. 전체 워크플로우

```
┌──────────────────────────────────────────────────────────────────┐
│  Claude Code 시작                                                │
│  [SessionStart hook] → 이전 작업 상태 복원 + 스킬 안내             │
└──────────────────────┬───────────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────────┐
│  STEP 0. 컨벤션 정의 (최초 1회)                                   │
│  /convention scan → /convention generate                         │
│  → [convention-scanner] → CLAUDE.md 생성                         │
└──────────────────────┬───────────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────────┐
│  STEP 1. 기획 문서 분석                                          │
│  /spec analyze ./docs/cart-prd.md                                │
│  → [spec-analyzer] → 테스트 시나리오 + 컴포넌트 명세 산출          │
└──────────────────────┬───────────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────────┐
│  STEP 2. TDD 사이클                                              │
│  /tdd start ./specs/cart-test-scenarios.md                        │
│  → [tdd-runner]                                                  │
│    ① 테스트 작성 (Red) → vitest 실행 → ALL FAIL                  │
│    ② 구현 작성 (Green) → vitest 실행 → ALL PASS                  │
│  → [test-reviewer] 테스트 품질 검증 (fork)                        │
│    ③ 리팩토링 (Refactor)                                         │
└──────────────────────┬───────────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────────┐
│  STEP 3. UI 구현                                                 │
│  /ui build "장바구니 화면"                                        │
│  → [ui-builder] Base UI + Panda CSS 토큰으로 UI 코드 작성         │
│  → [design-reviewer] 디자인 시스템 준수 검증                      │
└──────────────────────┬───────────────────────────────────────────┘
                       ↓
┌──────────────────────────────────────────────────────────────────┐
│  자동화 (전 과정에 걸쳐 작동)                                      │
│  [PostToolUse] 코드 변경 → 자동 테스트                             │
│  [UserPromptSubmit] 새 기능 요청 → TDD 유도                       │
│  [PreToolUse] 보호 파일 수정 차단                                  │
│  [Stop] 작업 완료 → 상태 요약 박스 출력                             │
│  [PreCompact] 컨텍스트 압축 → TDD 상태 보존                       │
└──────────────────────────────────────────────────────────────────┘
```

---

## 7. 디렉토리 구조

```
fe-dev-plugins/
├── .claude-plugin/
│   └── plugin.json                ← 플러그인 매니페스트
│
├── skills/
│   ├── convention/SKILL.md        ← /convention (컨벤션 자동 추출)
│   ├── spec/SKILL.md              ← /spec (기획 문서 변환)
│   ├── tdd/SKILL.md               ← /tdd (TDD 사이클)
│   ├── ui/SKILL.md                ← /ui (디자인 시스템 UI 구현)
│   ├── impact/SKILL.md            ← /impact (PRD 변경 영향 분석)
│   ├── review/SKILL.md            ← /review (코드 리뷰)
│   └── help-me/SKILL.md           ← /help-me (온보딩 가이드)
│
├── agents/
│   ├── convention-scanner.md      ← 컨벤션 추출 에이전트
│   ├── spec-analyzer.md           ← 문서 분석 에이전트
│   ├── tdd-runner.md              ← TDD 실행 에이전트
│   ├── test-reviewer.md           ← 테스트 품질 검증 에이전트
│   ├── ui-builder.md              ← UI 구현 에이전트
│   ├── design-reviewer.md         ← 디자인 시스템 검증 에이전트
│   ├── impact-analyzer.md         ← 변경 영향 분석 에이전트
│   └── code-reviewer.md           ← 코드 리뷰 에이전트
│
├── hooks/
│   ├── hooks.json                 ← 훅 이벤트 통합 정의
│   ├── session-start.sh           ← 세션 시작: 상태 복원 + 안내
│   ├── post-write.sh              ← 코드 변경 후: 자동 테스트
│   ├── user-prompt.sh             ← 사용자 입력: TDD 유도
│   ├── pre-write.sh               ← 파일 쓰기 전: 보호 파일 차단
│   ├── stop-summary.sh            ← 작업 완료: 상태 요약
│   └── pre-compact.sh             ← 컨텍스트 압축 전: 상태 보존
│
├── output-styles/
│   └── fe-dev.md                  ← 시각적 출력 포맷 규칙
│
├── templates/
│   ├── test-scenario.md           ← 테스트 시나리오 산출물 템플릿
│   ├── component-spec.md          ← 컴포넌트 명세 산출물 템플릿
│   └── api-spec.md                ← API 스펙 산출물 템플릿
│
├── config.json                    ← 중앙 설정 파일
└── PLAN.md                        ← 이 문서
```

---

## 8. 중앙 설정 파일 (`config.json`)

```json
{
  "project": {
    "name": "fe-dev-plugins",
    "version": "0.1.0"
  },
  "test": {
    "framework": {
      "unit": "vitest",
      "integration": "vitest + react-testing-library",
      "e2e": "playwright"
    },
    "filePatterns": {
      "unit": "*.test.ts",
      "integration": "*.test.tsx",
      "e2e": "*.spec.ts"
    },
    "autoRunOnChange": true
  },
  "designSystem": {
    "name": "base-ui",
    "styling": "panda-css",
    "tokensAvailable": true,
    "documentationComplete": false
  },
  "protectedFiles": [
    ".env",
    ".env.*",
    "pnpm-lock.yaml",
    "package-lock.json"
  ],
  "tdd": {
    "qualityReview": true,
    "preserveStateOnCompact": true
  }
}
```

---

## 9. bkit 벤치마킹 패턴 정리

| 패턴 | bkit 출처 | 우리 적용 |
|------|-----------|-----------|
| 읽기 전용 분석 에이전트 | gap-detector | test-reviewer, design-reviewer, impact-analyzer |
| context: fork | gap-detector | 검증 에이전트가 원본 컨텍스트 오염 방지 |
| permissionMode: plan | code-analyzer | 분석 전용 에이전트의 코드 수정 차단 |
| Unified Stop Handler | unified-stop.js | stop-summary.sh에서 통합 상태 요약 |
| SessionStart 상태 복원 | session-start.js | TDD 상태 이어받기 + 스킬 안내 |
| UserPromptSubmit 의도 감지 | user-prompt-handler.js | 새 기능 요청 → TDD 흐름 제안 |
| PreCompact 상태 보존 | context-compaction.js | TDD 상태를 JSON으로 영속화 |
| project memory | agents | 프로젝트별 패턴 학습 |
| Output Styles | output-styles/ | 시각적 상태 박스 포맷 |
| 중앙 설정 파일 | bkit.config.json | config.json |

---

## 10. 구현 우선순위

| Phase | 항목 | 구성 요소 | 이유 |
|-------|------|-----------|------|
| **Phase 0** | 계획서 고도화 | 이 문서 | 방향 확정 |
| **Phase 1** | CLAUDE.md 정의 | `/convention` + `convention-scanner` | 에이전트의 기준점. 0번 작업 |
| **Phase 2** | TDD MVP | `/tdd` + `tdd-runner` | 가장 즉시 체감되는 가치 |
| **Phase 3** | 기본 Hooks | SessionStart, PostToolUse, Stop | 플러그인이 "적극적으로" 작동 |
| **Phase 4** | Output Styles | 시각적 상태 박스 | 진행 상태를 한눈에 파악 |
| **Phase 5** | 문서 변환 | `/spec` + `spec-analyzer` | TDD와 연결하면 시너지 |
| **Phase 6** | 품질 가드레일 | `test-reviewer` + PreToolUse + PreCompact | 안전장치 |
| **Phase 7** | UI 구현 | `/ui` + `ui-builder` + `design-reviewer` | 디자인 시스템 문서화 진행에 맞춰 |
| **Phase 8** | 유틸리티 | `/impact`, `/review`, `/help-me` | 편의 기능 |

---

## 11. 다음 단계

현재: **Phase 0 (계획서 고도화)** ← 여기

다음 할 일:
1. ✅ 계획서 고도화 (이 문서)
2. → **Phase 1: CLAUDE.md 정의** — `/convention` 스킬로 기존 프로젝트 분석 + CLAUDE.md 생성
3. → **Phase 2: TDD MVP** — `/tdd` 스킬 + `tdd-runner` 에이전트 구현
