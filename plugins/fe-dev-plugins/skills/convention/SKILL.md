---
name: convention
description: "프로젝트 코드베이스를 분석하여 코딩 컨벤션을 자동 추출하고 CLAUDE.md를 생성합니다. 프로젝트에 컨벤션 문서가 없을 때, 또는 CLAUDE.md를 업데이트하고 싶을 때 사용하세요."
user-invocable: true
argument-hint: "[scan|generate|update]"
agent: convention-scanner
allowed-tools: Read, Grep, Glob, Bash
---

# /convention — 프로젝트 컨벤션 자동 추출

> 트리거 키워드: 컨벤션, convention, CLAUDE.md, 코딩 규칙, 패턴 분석, 코드 스타일

## 사용법

사용자가 전달한 액션: `$ARGUMENTS`

### 액션별 동작

**`/convention scan`** — 코드베이스 분석
1. 프로젝트 루트에서 시작하여 다음을 분석한다:
   - `package.json` → 기술 스택, 스크립트, 의존성
   - `tsconfig.json` → TypeScript 설정
   - 디렉토리 구조 → 파일 조직 패턴
   - `src/` 하위 → 컴포넌트 작성 방식, import 패턴, 네이밍 규칙
   - 테스트 파일 → 테스트 구조, 위치 규칙, 사용 패턴
   - 스타일 파일 → 스타일링 방식 (Panda CSS 토큰 사용 패턴 등)
   - 설정 파일 → ESLint, Prettier 등 린터/포매터 규칙

2. 분석 결과를 다음 형태로 정리하여 출력한다:
   ```
   ┌─ Convention Scan ────────────────────────┐
   │ Project: <프로젝트명>                     │
   │ Stack:   <기술 스택 요약>                  │
   │ Files:   <파일 수> files scanned          │
   │ Patterns: <발견된 패턴 수> found           │
   └──────────────────────────────────────────┘
   ```

3. 발견한 패턴들을 카테고리별로 정리:
   - 프로젝트 구조
   - 네이밍 규칙
   - 컴포넌트 패턴
   - 상태 관리
   - API 레이어
   - 테스트 패턴
   - 스타일링 패턴
   - 빌드/개발 명령어

**`/convention generate`** — CLAUDE.md 초안 생성
1. `/convention scan` 결과가 없으면 먼저 scan을 실행한다.
2. 분석 결과를 기반으로 프로젝트 루트에 `CLAUDE.md` 파일을 생성한다.
3. CLAUDE.md 구조:
   - 프로젝트 개요
   - 기술 스택
   - 디렉토리 구조
   - 코딩 규칙 (네이밍, 컴포넌트, 스타일링 등)
   - 자주 사용하는 명령어
   - 테스트 규칙
   - 주의사항

**`/convention update`** — 기존 CLAUDE.md에 패턴 추가
1. 기존 CLAUDE.md를 읽는다.
2. 새로 scan하여 기존에 없는 패턴을 발견한다.
3. 기존 내용을 유지하면서 새 패턴만 추가한다.

## 분석 시 주의사항
- 최소 5개 이상의 파일에서 반복되는 패턴만 "컨벤션"으로 인정한다.
- 추측이나 일반적인 베스트 프랙티스가 아닌, 실제 코드에서 관찰된 패턴만 기록한다.
- "이 프로젝트에서는 ~한 패턴을 사용합니다"로 기술한다.
