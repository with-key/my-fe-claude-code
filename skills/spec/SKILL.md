---
name: spec
description: "기획 문서(PRD, 기능명세서)를 분석하여 테스트 시나리오, 컴포넌트 명세, API 스펙을 자동 생성합니다."
user-invocable: true
argument-hint: "[analyze|test-scenario|component|api] <파일경로>"
agent: spec-analyzer
allowed-tools: Read, Write, Edit, Grep, Glob
---

# /spec — 기획 문서 변환

> 트리거 키워드: 기획, PRD, 명세, spec, 기능명세서, 정책, 요구사항, 문서 분석

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 액션별 동작

**`/spec analyze <파일경로>`** — 기획 문서를 분석하여 3종 산출물 모두 생성
1. 지정된 기획 문서를 읽고 분석한다.
2. 다음 산출물을 한꺼번에 생성한다:
   - `test-scenarios/<기능명>.md` — Given-When-Then 테스트 시나리오
   - `component-specs/<기능명>.md` — 컴포넌트 Props/State/Events 명세
   - `api-specs/<기능명>.md` — API 엔드포인트/Request/Response 스펙
3. 기획 문서에서 개발에 필요하지만 빠진 정보를 누락 사항으로 표시한다.
4. 결과 요약 박스를 출력한다.

**`/spec test-scenario <파일경로>`** — 테스트 시나리오만 생성
1. 기획 문서에서 비즈니스 규칙과 요구사항을 추출한다.
2. Given-When-Then 형식으로 테스트 시나리오를 작성한다.
3. 정상 동작, 경계값, 에러, 엣지 케이스를 포함한다.
4. `test-scenarios/<기능명>.md`에 저장한다.

**`/spec component <파일경로>`** — 컴포넌트 명세만 생성
1. 기획 문서에서 UI 관련 요소를 추출한다.
2. 컴포넌트 트리, Props, State, Events를 정의한다.
3. Base UI 컴포넌트와 Panda CSS 토큰을 매핑한다.
4. `component-specs/<기능명>.md`에 저장한다.

**`/spec api <파일경로>`** — API 스펙만 생성
1. 기획 문서에서 데이터 CRUD 관련 내용을 추출한다.
2. 엔드포인트, Request/Response 타입, 에러 처리를 정의한다.
3. React Query 호출 패턴을 포함한다.
4. `api-specs/<기능명>.md`에 저장한다.

## 산출물 저장 위치

프로젝트 루트 기준:
```
test-scenarios/   ← 테스트 시나리오
component-specs/  ← 컴포넌트 명세
api-specs/        ← API 스펙
```

## 주의사항
- 기획 문서에 명시된 내용만 반영한다. 추측으로 요구사항을 추가하지 않는다.
- 누락된 정보는 `⚠️ 누락 사항` 섹션에 명시하고, 기본 가정을 함께 기록한다.
- 파일명은 kebab-case를 사용한다.
