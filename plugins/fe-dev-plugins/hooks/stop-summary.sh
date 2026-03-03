#!/usr/bin/env bash
set -euo pipefail

# Stop hook: 변경 파일 수, 테스트 결과, TDD 단계 요약
# stdin: JSON (stop 컨텍스트)
# stdout: JSON { result: "continue", message: "..." }

INPUT=$(cat)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${PLUGIN_ROOT}/config.json"

# TDD 상태 파일 경로
TDD_STATE_FILE=""
if command -v jq &>/dev/null; then
  TDD_STATE_FILE=$(jq -r '.tdd.stateFile // ".claude/state/tdd-state.json"' "$CONFIG_FILE" 2>/dev/null || echo ".claude/state/tdd-state.json")
elif command -v python3 &>/dev/null; then
  TDD_STATE_FILE=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('tdd',{}).get('stateFile','.claude/state/tdd-state.json'))" 2>/dev/null || echo ".claude/state/tdd-state.json")
else
  TDD_STATE_FILE=".claude/state/tdd-state.json"
fi

# stop_hook_active로부터 변경된 파일 정보 추출 시도
CHANGED_FILES=""
if command -v jq &>/dev/null; then
  CHANGED_FILES=$(echo "$INPUT" | jq -r '.changed_files // [] | join(", ")' 2>/dev/null || echo "")
elif command -v python3 &>/dev/null; then
  CHANGED_FILES=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(', '.join(d.get('changed_files',[])))" 2>/dev/null || echo "")
fi

# git diff로 변경 파일 수 확인 (git이 있는 경우)
CHANGED_COUNT=0
if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  CHANGED_COUNT=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  STAGED_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  CHANGED_COUNT=$((CHANGED_COUNT + STAGED_COUNT))
fi

# TDD 상태 읽기
TDD_LINE=""
if [ -f "$TDD_STATE_FILE" ]; then
  if command -v jq &>/dev/null; then
    PHASE=$(jq -r '.phase // ""' "$TDD_STATE_FILE" 2>/dev/null || echo "")
    PASS=$(jq -r '.tests.pass // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
    TOTAL=$(jq -r '.tests.total // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
  elif command -v python3 &>/dev/null; then
    PHASE=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('phase',''))" 2>/dev/null || echo "")
    PASS=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('tests',{}).get('pass',0))" 2>/dev/null || echo "0")
    TOTAL=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('tests',{}).get('total',0))" 2>/dev/null || echo "0")
  else
    PHASE=""
    PASS="0"
    TOTAL="0"
  fi

  if [ -n "$PHASE" ] && [ "$PHASE" != "null" ]; then
    # Phase 시각화
    case "$PHASE" in
      "red")      TDD_PHASE="● Red   ○ Green  ○ Refactor" ;;
      "green")    TDD_PHASE="✓ Red   ● Green  ○ Refactor" ;;
      "refactor") TDD_PHASE="✓ Red   ✓ Green  ● Refactor" ;;
      "done")     TDD_PHASE="✓ Red   ✓ Green  ✓ Refactor" ;;
      *)          TDD_PHASE="$PHASE" ;;
    esac
    TDD_LINE="│ TDD:     ${TDD_PHASE}\n│ Tests:   ${PASS}/${TOTAL} pass\n"
  fi
fi

# 변경사항이 없으면 간단 메시지
if [ "$CHANGED_COUNT" -eq 0 ] && [ -z "$TDD_LINE" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 요약 박스 구성
MESSAGE="┌─ Summary ──────────────────────────────┐\n"

if [ "$CHANGED_COUNT" -gt 0 ]; then
  MESSAGE="${MESSAGE}│ Changed: ${CHANGED_COUNT} files\n"
fi

if [ -n "$TDD_LINE" ]; then
  MESSAGE="${MESSAGE}${TDD_LINE}"
fi

MESSAGE="${MESSAGE}└────────────────────────────────────────┘"

# JSON 출력
if command -v jq &>/dev/null; then
  printf '%s' "$MESSAGE" | jq -Rs '{ result: "continue", message: . }'
else
  ESCAPED_MSG=$(printf '%s' "$MESSAGE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || printf '"%s"' "$MESSAGE")
  printf '{ "result": "continue", "message": %s }' "$ESCAPED_MSG"
fi

exit 0
