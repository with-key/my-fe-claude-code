---
name: ui
description: "디자인 시스템(Base UI + Panda CSS) 기반으로 UI 코드를 생성하고 검증합니다."
user-invocable: true
argument-hint: "[build|component|tokens|review] <요구사항>"
agent: ui-builder
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /ui — 디자인 시스템 기반 UI 구현

> 트리거 키워드: UI, 화면, 컴포넌트, 디자인, 레이아웃, Base UI, Panda CSS, 토큰

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 액션별 동작

**`/ui build <요구사항 또는 스크린샷>`** — 디자인 시스템 기반 UI 코드 생성
1. 요구사항을 분석하여 필요한 UI 요소를 파악한다.
2. 프로젝트의 디자인 시스템 컴포넌트를 확인한다.
3. Base UI 컴포넌트 + Panda CSS 토큰으로 UI 코드를 작성한다.
4. `ui-builder` 에이전트가 코드를 작성한다.
5. 작성 완료 후 `design-reviewer` 에이전트가 디자인 시스템 준수 여부를 검증한다.

**`/ui component <컴포넌트명>`** — 디자인 시스템 컴포넌트 사용법 안내
1. 지정된 Base UI 컴포넌트의 사용법을 안내한다.
2. 프로젝트에서 해당 컴포넌트를 사용한 예시를 검색한다.
3. Props, 이벤트, 스타일링 방법을 설명한다.

**`/ui tokens`** — 사용 가능한 디자인 토큰 목록 표시
1. 프로젝트의 Panda CSS 토큰 파일을 읽는다.
2. 카테고리별로 사용 가능한 토큰을 정리한다:
   - Colors (색상)
   - Spacing (간격)
   - Typography (폰트)
   - Shadows (그림자)
   - Border Radius (모서리)
3. 각 토큰의 실제 값을 함께 표시한다.

**`/ui review`** — 현재 코드가 디자인 시스템을 올바르게 사용하는지 검토
1. `design-reviewer` 에이전트를 호출한다.
2. 현재 변경된 파일 또는 지정된 파일을 검사한다.
3. 하드코딩된 스타일 값, 토큰 미사용, Base UI 미사용을 감지한다.
4. 문제별 등급(Critical/Warning/Info)과 수정 제안을 출력한다.

## 디자인 시스템 참조

### Base UI 컴포넌트 (주요)
- Button, IconButton
- Input, Select, Checkbox, Radio, Switch
- Dialog, Popover, Tooltip
- Tabs, Accordion
- Table

### Panda CSS 토큰 (주요 카테고리)
- `colors.*` — 색상 토큰
- `spacing.*` — 간격 토큰 (0, 1, 2, 3, 4, ...)
- `fontSizes.*` — 폰트 크기
- `fontWeights.*` — 폰트 굵기
- `radii.*` — 모서리 라운딩
- `shadows.*` — 그림자

## 주의사항
- 하드코딩된 색상(`#xxx`), 간격(`16px`), 폰트를 사용하지 않는다.
- 디자인 시스템에 없는 커스텀 컴포넌트를 만들기 전에, 기존 컴포넌트로 해결 가능한지 먼저 확인한다.
- 접근성(키보드 네비게이션, aria 속성, 색상 대비)을 고려한다.
