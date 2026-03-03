---
name: help-me
description: "fe-dev-plugins의 모든 스킬과 워크플로우를 안내합니다."
user-invocable: true
argument-hint: "[tdd|spec|ui|impact|review|convention|workflow]"
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
│    기획 문서 분석 → 프론트엔드 기능명세서 생성    │
│                                               │
│ 🧪 /tdd [start|scenario|red|green|refactor|status]│
│    TDD 사이클 전체 실행 또는 개별 단계 선택      │
│                                               │
│ 🎨 /ui [build|component|tokens|review]        │
│    Base UI + Panda CSS 디자인 시스템 기반       │
│    UI 코드 생성 및 검증                         │
│                                               │
│ 🔍 /impact <PRD경로> 또는 diff <이전> <이후>    │
│    PRD 변경 → 영향받는 코드/테스트 분석          │
│                                               │
│ 📝 /review [--security]                       │
│    git diff 기반 코드 리뷰                     │
│                                               │
│ ❓ /help-me [스킬명|workflow]                  │
│    이 안내 표시                                 │
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
    /tdd scenario ./docs/specs/cart.md
    /tdd red
    /tdd green
    /tdd refactor
    /tdd status
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
  → 프론트엔드 기능명세서 + 기획 피드백

Step 2. TDD 사이클
  /tdd start ./docs/specs/cart.md
  → Scenario → Red → Green → Refactor

  또는 단계별로:
  /tdd scenario ./docs/specs/cart.md
  /tdd red
  /tdd green
  /tdd refactor

Step 3. UI 구현
  /ui build "장바구니 화면"
  → Base UI + Panda CSS 토큰 기반 코드

Step 4. 코드 리뷰
  /review
  → 구현 코드 + 테스트 코드 품질 검사
```

## 주의사항
- 이 스킬은 안내만 제공하며 에이전트를 호출하지 않는다.
- 각 스킬의 실제 실행은 해당 스킬을 직접 호출해야 한다.
