---
name: help-me
description: "fe-dev-plugins의 모든 스킬과 워크플로우를 안내합니다."
user-invocable: true
argument-hint: "[tdd|spec|ui|impact|review|fix|deploy|convention|workflow]"
---

# /help-me — 스킬 사용 가이드

> 트리거 키워드: 도움말, help, 사용법, 가이드, 안내

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 인수가 없는 경우 (`/help-me`)

다음과 같이 전체 스킬 목록과 간단한 설명을 출력한다:

```
┌─ fe-dev-plugins ─────────────────────────────┐
│ 프론트엔드 개발 자동화 플러그인 셋              │
│                                               │
│ 📋 /convention [scan|generate|update]         │
│    프로젝트 컨벤션 자동 추출 → CLAUDE.md 생성   │
│                                               │
│ 📄 /spec <파일경로>                            │
│    기획 문서 분석 → 테스트/컴포넌트/API 명세 생성 │
│                                               │
│ 🧪 /tdd [start|scenario|red|green|refactor|status]│
│    TDD 사이클 전체 실행 또는 개별 단계 선택      │
│                                               │
│ 🎨 /ui [build|component|tokens|review]        │
│    Base UI + Panda CSS 디자인 시스템 기반       │
│    UI 코드 생성 및 검증                         │
│                                               │
│ 🔍 /impact <PRD경로 또는 변경 설명>             │
│    변경 영향 범위 빠른 분석 (What/Where)        │
│                                               │
│ 📝 /review [--security|--test]                │
│    git diff 기반 코드 리뷰                     │
│                                               │
│ 🔧 /fix <버그 증상 또는 변경 설명>              │
│    버그 진단 또는 기획 변경 수정 방안 제시 (How) │
│                                               │
│ 🚀 /deploy [checklist|verify|handoff]         │
│    배포 전 검증 및 릴리스 핸드오프              │
│                                               │
│ ❓ /help-me [스킬명|workflow]                  │
│    이 안내 표시                                │
└───────────────────────────────────────────────┘
```

### 특정 스킬 안내 (`/help-me <스킬명>`)

해당 스킬의 상세 사용법을 출력한다:

**`/help-me tdd`** 예시:
```
🧪 TDD — 테스트 주도 개발

  /tdd start <요구사항>        전체 사이클 (Scenario → Red → Green → Refactor)
  /tdd scenario <요구사항>     테스트 시나리오 작성
  /tdd red [시나리오경로]       실패하는 테스트 코드 작성
  /tdd green                  테스트를 통과시키는 구현 작성
  /tdd refactor               테스트 유지하면서 코드 개선
  /tdd status                 현재 TDD 상태 표시

  예시:
    /tdd start "수량은 1~99 사이로 제한된다"
    /tdd scenario ./test-scenarios/cart.md
    /tdd red
    /tdd green
    /tdd refactor
    /tdd status
```

**`/help-me fix`** 예시:
```
🔧 fix — 버그 진단 및 기획 변경 수정 방안

  /fix <버그 증상>             버그 원인 진단 + 해결 방안
  /fix <변경 설명>             기획 변경에 따른 수정 방안

  버그 수정 모드 예시:
    /fix 장바구니에서 수량 변경 시 총 금액이 업데이트되지 않음
    /fix TypeError: Cannot read properties of undefined

  기획 변경 모드 예시:
    /fix 최소 주문 금액이 10,000원에서 15,000원으로 변경
    /fix 회원 등급별 할인율 정책 변경 — 골드 10%→15%
```

### 워크플로우 안내 (`/help-me workflow`)

전체 추천 워크플로우를 설명한다:

```
📋 추천 워크플로우

Step 0. 컨벤션 정의 (최초 1회)
  /convention scan → /convention generate
  → CLAUDE.md 생성

Step 1. 기획 문서 분석
  /spec ./docs/prd/cart.md
  → 테스트 시나리오 + 컴포넌트 명세 + API 스펙 + 기획 피드백

Step 2. TDD 사이클
  /tdd start ./test-scenarios/cart.md
  → Scenario → Red → Green → Refactor

  또는 단계별로:
  /tdd scenario ./test-scenarios/cart.md
  /tdd red
  /tdd green
  /tdd refactor

Step 3. UI 구현
  /ui build "장바구니 화면"
  → Base UI + Panda CSS 토큰 기반 코드

Step 4. 코드 리뷰
  /review
  → 구현 코드 + 테스트 코드 품질 검사

Step 5. 배포 검증 및 핸드오프
  /deploy verify
  → 배포 적합성 점검 + 릴리스 노트/운영 핸드오프

---

📋 기획 변경 대응

Step 1. 영향 범위 파악
  /impact "최소 주문 금액 10,000원 → 15,000원 변경"
  → 영향받는 파일 목록 + 한 줄 수정 힌트

Step 2. 상세 수정 방안 확인
  /fix "최소 주문 금액이 10,000원에서 15,000원으로 변경"
  → 파일별 구체적 수정 방안 + 검증 체크리스트
```

## 주의사항
- 이 스킬은 안내만 제공하며 에이전트를 호출하지 않는다.
- 각 스킬의 실제 실행은 해당 스킬을 직접 호출해야 한다.
