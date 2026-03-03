#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: TDD 상태 복원 + 스킬 안내 출력
# stdin: JSON (세션 시작 컨텍스트)
# stdout: JSON { result: "continue", message: "..." }

INPUT=$(cat)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${PLUGIN_ROOT}/config.json"

# TDD 상태 파일 경로 (config.json에서 읽기)
TDD_STATE_FILE=""
if command -v jq &>/dev/null; then
  TDD_STATE_FILE=$(jq -r '.tdd.stateFile // ".claude/state/tdd-state.json"' "$CONFIG_FILE" 2>/dev/null || echo ".claude/state/tdd-state.json")
elif command -v python3 &>/dev/null; then
  TDD_STATE_FILE=$(python3 -c "import json,sys; d=json.load(open('$CONFIG_FILE')); print(d.get('tdd',{}).get('stateFile','.claude/state/tdd-state.json'))" 2>/dev/null || echo ".claude/state/tdd-state.json")
else
  TDD_STATE_FILE=".claude/state/tdd-state.json"
fi

# TDD 상태 복원
TDD_STATUS=""
if [ -f "$TDD_STATE_FILE" ]; then
  if command -v jq &>/dev/null; then
    FEATURE=$(jq -r '.feature // "unknown"' "$TDD_STATE_FILE" 2>/dev/null || echo "unknown")
    PHASE=$(jq -r '.phase // "unknown"' "$TDD_STATE_FILE" 2>/dev/null || echo "unknown")
    PASS=$(jq -r '.tests.pass // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
    TOTAL=$(jq -r '.tests.total // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
  elif command -v python3 &>/dev/null; then
    FEATURE=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('feature','unknown'))" 2>/dev/null || echo "unknown")
    PHASE=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('phase','unknown'))" 2>/dev/null || echo "unknown")
    PASS=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('tests',{}).get('pass',0))" 2>/dev/null || echo "0")
    TOTAL=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('tests',{}).get('total',0))" 2>/dev/null || echo "0")
  else
    FEATURE="unknown"
    PHASE="unknown"
    PASS="0"
    TOTAL="0"
  fi

  if [ "$PHASE" != "done" ] && [ "$PHASE" != "unknown" ]; then
    TDD_STATUS="│ TDD:     ${FEATURE} (${PHASE}) — ${PASS}/${TOTAL} tests pass\n│\n│ /tdd ${PHASE} 으로 이어서 작업하시겠습니까?\n"
  fi
fi

# 안내 메시지 구성
MESSAGE="┌─ Session Start ──────────────────────────────┐\n│ Skills:  /convention  /spec  /tdd  /ui        │\n│          /impact  /review  /help-me           │\n"

if [ -n "$TDD_STATUS" ]; then
  MESSAGE="${MESSAGE}│                                               │\n${TDD_STATUS}"
fi

MESSAGE="${MESSAGE}└───────────────────────────────────────────────┘"

# JSON 출력
if command -v jq &>/dev/null; then
  printf '%s' "$MESSAGE" | jq -Rs '{ result: "continue", message: . }'
else
  # jq 없는 환경을 위한 간단한 JSON 구성
  ESCAPED_MSG=$(printf '%s' "$MESSAGE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || printf '"%s"' "$MESSAGE")
  printf '{ "result": "continue", "message": %s }' "$ESCAPED_MSG"
fi

exit 0
