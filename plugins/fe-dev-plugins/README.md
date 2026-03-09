# fe-dev-plugins

프론트엔드 개발자를 위한 Claude Code 플러그인 셋.
기획 문서 분석부터 TDD, UI 구현, 코드 리뷰, 배포 검증까지 프론트엔드 개발 전 과정을 자동화합니다.

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| `/convention` | 프로젝트 코드베이스를 분석하여 컨벤션을 추출하고 CLAUDE.md를 생성 |
| `/spec` | 기획 문서를 분석하여 프론트엔드 개발 산출물(테스트/컴포넌트/API)을 생성 |
| `/tdd` | TDD Red → Green → Refactor 사이클 자동화 |
| `/ui` | Base UI + Panda CSS 디자인 시스템 기반 UI 코드 생성 및 검증 |
| `/impact` | PRD 변경이 영향을 미치는 코드와 테스트 파일을 분석 |
| `/review` | git diff 기반 코드 리뷰 (품질, 보안, 테스트 커버리지) |
| `/deploy` | 배포 전 검증 체크리스트와 릴리스 핸드오프를 생성 |
| `/help-me` | 스킬 사용법 및 워크플로우 안내 |

## 개발 워크플로우

이 플러그인은 프론트엔드 개발의 전체 흐름을 단계별로 지원합니다.
아래 워크플로우를 따라 기획서 수령부터 코드 리뷰까지 일관된 프로세스로 개발할 수 있습니다.

---

### Step 0. 프로젝트 컨벤션 정의 (최초 1회)

```
/convention scan
/convention generate
```

새 프로젝트를 시작하거나 CLAUDE.md가 없을 때 실행합니다.
코드베이스를 자동 분석하여 네이밍 규칙, 컴포넌트 패턴, 디렉토리 구조 등 프로젝트 컨벤션을 추출하고 `CLAUDE.md`를 생성합니다.

이후 모든 스킬은 이 컨벤션을 참조하여 프로젝트에 일관된 코드를 생성합니다.

> 프로젝트가 성장하면서 컨벤션이 변경될 경우 `/convention update`로 갱신할 수 있습니다.

---

### Step 1. 기획 문서 분석 → 프론트엔드 개발 산출물

```
/spec ./docs/prd/cart.md
```

기획자로부터 PRD(기획 문서)를 받으면 이 단계를 실행합니다.

**수행 내용:**

1. **기획 문서 다각도 분석** — 시니어 프론트엔드 개발자 관점에서 기획서를 분석합니다.
   - 기능 요구사항, 비즈니스 규칙, 사용자 플로우를 추출
   - 기획서에 명시되지 않은 엣지 케이스를 식별
   - 기존 프로젝트 코드와 상충되는 부분이 없는지 검토
   - 프론트엔드 구현 시 기술적 제약사항 파악

2. **프론트엔드 개발 산출물 생성** — 분석 결과를 AI 개발 컨텍스트로 바로 사용할 수 있는 문서 세트로 정리합니다.
   - `test-scenarios/<기능명>.md` (Given-When-Then 테스트 시나리오)
   - `component-specs/<기능명>.md` (컴포넌트 구조/Props/State/Event 명세)
   - `api-specs/<기능명>.md` (API 연동 스펙)
   - 기획자에게 피드백할 질문 사항과 모호한 정책 정리

**산출물:**
```
test-scenarios/<기능명>.md   ← 테스트 시나리오
component-specs/<기능명>.md  ← 컴포넌트 명세
api-specs/<기능명>.md        ← API 연동 스펙
```

> 기능명세서의 **기획 피드백** 섹션을 기획자에게 공유하여 모호한 요구사항을 사전에 확정하세요. 이 과정을 거치면 구현 중 발생하는 재작업을 크게 줄일 수 있습니다.

---

### Step 2. TDD 사이클 — 테스트 작성 → 구현 → 리팩토링

```
/tdd start "수량은 1~99 사이로 제한된다"
```

기능명세서를 바탕으로 TDD 사이클을 실행합니다.
요구사항을 텍스트로 전달하거나 명세서 파일 경로를 전달할 수 있습니다.

**Red → Green → Refactor 흐름:**

| 단계 | 명령어 | 설명 |
|------|--------|------|
| Red | `/tdd red <요구사항>` | 실패하는 테스트를 먼저 작성 |
| Green | `/tdd green` | 테스트를 통과시키는 최소한의 구현 코드 작성 |
| Refactor | `/tdd refactor` | 테스트를 유지하면서 코드 품질 개선 |
| 전체 | `/tdd start <요구사항>` | Red → Green → Refactor를 한 번에 실행 |
| 상태 확인 | `/tdd status` | 현재 TDD 진행 상황 표시 |

**테스트 타입 자동 판별:**

| 패턴 | 테스트 타입 | 실행 도구 |
|------|-----------|----------|
| `*.test.ts` | 단위 테스트 | Vitest |
| `*.test.tsx` | 통합 테스트 | Vitest + React Testing Library |
| `*.spec.ts` | E2E 테스트 | Playwright |

> `config.json`에서 `tdd.qualityReview: true` 설정 시, Green 단계 후 `test-reviewer` 에이전트가 테스트 품질(허술한 테스트, 경계값 누락, 커버리지 부족)을 자동 검증합니다.

---

### Step 3. UI 구현 — 디자인 시스템 기반

```
/ui build "장바구니 상품 목록 화면"
```

TDD로 비즈니스 로직이 검증된 후, UI를 구현합니다.
Base UI 컴포넌트와 Panda CSS 디자인 토큰을 기반으로 코드를 생성합니다.

| 명령어 | 설명 |
|--------|------|
| `/ui build <요구사항>` | 디자인 시스템 기반 UI 코드 생성 |
| `/ui component <이름>` | 특정 Base UI 컴포넌트의 사용법 안내 |
| `/ui tokens` | 사용 가능한 디자인 토큰(색상, 간격 등) 목록 표시 |
| `/ui review` | 디자인 시스템 준수 여부 검증 |

**자동 검증:** `/ui build` 실행 시 `ui-builder`가 코드를 작성한 뒤, `design-reviewer`가 자동으로 하드코딩된 스타일, 토큰 미사용 등을 감지합니다.

---

### Step 4. 코드 리뷰

```
/review
```

구현이 완료되면 커밋 전에 코드 리뷰를 실행합니다.
git diff를 기반으로 변경된 코드를 분석합니다.

| 명령어 | 검사 항목 |
|--------|----------|
| `/review` | 코드 품질, 타입 안전성, 에러 처리, 컨벤션 준수 |
| `/review --security` | XSS, 인젝션, 인증 누락, 민감 데이터 노출 |
| `/review --test` | 테스트 커버리지, 테스트 파일 존재 여부, 테스트 품질 |

---

### Step 5. 배포 검증 및 핸드오프

```
/deploy verify
```

배포 직전에 최종 검증을 실행합니다.

| 명령어 | 설명 |
|--------|------|
| `/deploy checklist` | 배포 전 체크리스트 생성 (테스트/리뷰/환경 변수/롤백 계획) |
| `/deploy verify` | 테스트/빌드/리스크를 확인하고 배포 적합성 요약 |
| `/deploy handoff` | 릴리스 노트 + 운영 핸드오프 문서 생성 |

---

## 기획 변경 대응

개발 중 기획이 변경되면 `/impact`로 영향 범위를 먼저 파악한 뒤 수정합니다.

```
# 단일 PRD 기반 영향 분석
/impact ./docs/prd/cart-v2.md

# 두 버전 비교 분석
/impact diff ./docs/prd/cart-v1.md ./docs/prd/cart-v2.md
```

영향받는 파일을 **수정 필요(●)** / **확인 필요(○)** 로 분류하여 보여줍니다.
이후 `/spec`으로 기능명세서를 갱신하고, `/tdd`로 변경된 요구사항에 대한 테스트를 추가합니다.

---

## 전체 워크플로우 요약

```
┌─────────────────────────────────────────────────────────┐
│                   fe-dev-plugins Workflow                │
│                                                         │
│  [Step 0]  /convention  ─────── CLAUDE.md 생성 (1회)     │
│                │                                        │
│                ▼                                        │
│  [Step 1]  /spec  ───────────── 기획 분석 → 개발 산출물     │
│                │                    │                    │
│                │              기획 피드백 → 기획자 전달    │
│                ▼                                        │
│  [Step 2]  /tdd  ────────────── Red → Green → Refactor  │
│                │                                        │
│                ▼                                        │
│  [Step 3]  /ui build  ────────── 디자인 시스템 기반 UI    │
│                │                                        │
│                ▼                                        │
│  [Step 4]  /review  ──────────── 코드 리뷰                │
│                │                                        │
│                ▼                                        │
│  [Step 5]  /deploy  ──────────── 배포 검증 → 핸드오프      │
│                                                         │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│                                                         │
│  [기획 변경 시]                                           │
│  /impact → /spec → /tdd → /ui build → /review → /deploy │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 에이전트 구성

스킬은 내부적으로 전문화된 에이전트를 호출하여 작업을 수행합니다.

**실행 에이전트** — 코드를 직접 작성하거나 분석합니다.

| 에이전트 | 역할 | 사용하는 스킬 |
|---------|------|-------------|
| `spec-analyzer` | 기획 문서 분석 및 개발 산출물 생성 | `/spec` |
| `tdd-runner` | TDD 사이클 수행 (테스트 작성, 구현, 리팩토링) | `/tdd` |
| `ui-builder` | 디자인 시스템 기반 UI 코드 생성 | `/ui build` |
| `convention-scanner` | 프로젝트 컨벤션 분석 및 추출 | `/convention` |
| `deploy-assistant` | 배포 검증 체크리스트/핸드오프 생성 | `/deploy` |

**검증 에이전트** — 작성된 코드의 품질을 검증합니다. 코드를 수정하지 않습니다.

| 에이전트 | 역할 | 호출 시점 |
|---------|------|----------|
| `test-reviewer` | 테스트 품질 검증 (허술한 테스트, 커버리지 부족 감지) | `/tdd green` 후 자동 |
| `design-reviewer` | 디자인 시스템 준수 검증 (하드코딩 스타일, 토큰 미사용) | `/ui build` 후 자동, `/ui review` |
| `code-reviewer` | 코드 품질, 보안, 컨벤션 리뷰 | `/review` |
| `impact-analyzer` | PRD 변경 영향 범위 분석 | `/impact` |

## 설정

`config.json`에서 플러그인 동작을 설정할 수 있습니다.

```jsonc
{
  "test": {
    "framework": {
      "unit": "vitest",
      "integration": "vitest + react-testing-library",
      "e2e": "playwright"
    },
    "autoRunOnChange": true        // 코드 변경 시 자동 테스트 실행
  },
  "designSystem": {
    "name": "base-ui",             // UI 컴포넌트 라이브러리
    "styling": "panda-css"         // 스타일링 프레임워크
  },
  "tdd": {
    "qualityReview": true,         // Green 단계 후 테스트 품질 자동 검증
    "preserveStateOnCompact": true // 컨텍스트 압축 시 TDD 상태 보존
  },
  "protectedFiles": [              // 수정 차단 파일
    ".env", ".env.*",
    "pnpm-lock.yaml"
  ]
}
```
