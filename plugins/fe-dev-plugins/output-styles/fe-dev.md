# fe-dev-plugins Output Style Guide

이 문서는 fe-dev-plugins의 모든 에이전트와 스킬이 사용하는 출력 포맷 규칙을 정의합니다.
모든 상태 출력은 유니코드 박스 문자를 사용한 일관된 형태로 표시합니다.

## 1. TDD 상태 박스

TDD 관련 모든 출력에 포함합니다. Phase 진행 상태를 시각적으로 표시합니다.

```
┌─ TDD: <기능명> ─────────────────────────┐
│ Phase: ● Red   ○ Green   ○ Refactor    │
│ Tests: 0/5 pass                         │
│ Type:  Unit (Vitest)                    │
│ File:  <테스트 파일 경로>                 │
└─────────────────────────────────────────┘
```

Phase 아이콘 규칙:
- `○` 미완료
- `●` 진행 중
- `✓` 완료

Phase 진행 표시:
- Red 진행 중: `● Red   ○ Green  ○ Refactor`
- Green 진행 중: `✓ Red   ● Green  ○ Refactor`
- Refactor 진행 중: `✓ Red   ✓ Green  ● Refactor`
- 완료: `✓ Red   ✓ Green  ✓ Refactor`

Quality 등급 (test-reviewer 결과):
- `● Good` — 테스트 품질 양호
- `▲ Needs Work` — 개선 필요
- `✗ Poor` — 심각한 문제

## 2. Spec 분석 결과 박스

기획 문서 분석 후 산출물 생성 결과를 표시합니다.

```
┌─ Spec Analysis ─────────────────────────┐
│ Source:  <원본 기획 문서 경로>             │
│ Output:                                  │
│   ✓ test-scenarios/<name>.md  (<N> cases)│
│   ✓ component-specs/<name>.md (<N> comps)│
│   ✓ api-specs/<name>.md      (<N> endpoints)│
└──────────────────────────────────────────┘
```

## 3. Impact 분석 결과 박스

PRD 변경 영향 분석 결과를 표시합니다.

```
┌─ Impact Analysis ───────────────────────┐
│ PRD Change: <변경 요약>                   │
│ Affected:                                │
│   ● <파일경로>    (<수정 이유>)            │
│   ○ <파일경로>    (<확인 이유>)            │
│                                          │
│ ● 수정 필요  ○ 확인 필요                  │
└──────────────────────────────────────────┘
```

## 4. Auto Test 결과 박스

코드 변경 후 자동 테스트 실행 결과를 표시합니다.

```
┌─ Auto Test ─────────────────────────┐
│ Trigger: <변경된 소스 파일>           │
│ Run:     <실행된 테스트 파일>         │
│ Result:  <pass>/<total> PASS        │
└──────────────────────────────────────┘
```

실패가 있는 경우:
```
│ Result:  <pass>/<total> PASS | <fail> FAIL │
```

## 5. Stop 요약 박스

작업 완료 시 전체 상태를 요약합니다.

```
┌─ Summary ──────────────────────────────┐
│ Changed: <N> files                      │
│ Tests:   <pass>/<total> PASS            │
│ TDD:     ✓ Red  ✓ Green  ● Refactor   │
└─────────────────────────────────────────┘
```

## 6. Session Start 박스

세션 시작 시 안내 메시지를 표시합니다.

```
┌─ Session Start ──────────────────────────────┐
│ Skills:  /convention  /spec  /tdd  /ui        │
│          /impact  /review  /help-me           │
│                                               │
│ TDD:     <기능명> (<phase>) — <pass>/<total>   │
│                                               │
│ /tdd <phase> 으로 이어서 작업하시겠습니까?       │
└───────────────────────────────────────────────┘
```

## 공통 규칙

1. **박스 너비**: 내용에 맞게 자동 조절하되, 최소 40자 너비를 유지합니다.
2. **제목**: `┌─ <제목> ─...─┐` 형태로 박스 상단에 표시합니다.
3. **내용 정렬**: 좌측 정렬, 키-값 쌍은 콜론(:) 위치를 맞춥니다.
4. **아이콘 일관성**: 위에 정의된 아이콘(`●`, `○`, `✓`, `▲`, `✗`)만 사용합니다.
5. **언어**: 기술 용어(Phase, Tests, PASS 등)는 영어, 설명은 한국어로 표기합니다.
