#!/usr/bin/env bash
set -euo pipefail

# PreCompact hook: TDD 상태를 JSON 스냅샷으로 보존
# stdin: JSON (compact 컨텍스트)
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

# preserveStateOnCompact 설정 확인
PRESERVE="true"
if command -v jq &>/dev/null; then
  PRESERVE=$(jq -r '.tdd.preserveStateOnCompact // true' "$CONFIG_FILE" 2>/dev/null || echo "true")
elif command -v python3 &>/dev/null; then
  PRESERVE=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(str(d.get('tdd',{}).get('preserveStateOnCompact',True)).lower())" 2>/dev/null || echo "true")
fi

if [ "$PRESERVE" != "true" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

# TDD 상태 파일이 없으면 종료
if [ ! -f "$TDD_STATE_FILE" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 백업 디렉토리 생성
BACKUP_DIR=".claude/state/backups"
mkdir -p "$BACKUP_DIR"

# 타임스탬프 기반 백업
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/tdd-state_${TIMESTAMP}.json"
cp "$TDD_STATE_FILE" "$BACKUP_FILE"

# 오래된 백업 정리 (최근 5개만 유지)
ls -t "${BACKUP_DIR}"/tdd-state_*.json 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true

# TDD 상태 읽기
FEATURE=""
PHASE=""
PASS="0"
TOTAL="0"
if command -v jq &>/dev/null; then
  FEATURE=$(jq -r '.feature // ""' "$TDD_STATE_FILE" 2>/dev/null || echo "")
  PHASE=$(jq -r '.phase // ""' "$TDD_STATE_FILE" 2>/dev/null || echo "")
  PASS=$(jq -r '.tests.pass // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
  TOTAL=$(jq -r '.tests.total // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
elif command -v python3 &>/dev/null; then
  FEATURE=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('feature',''))" 2>/dev/null || echo "")
  PHASE=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('phase',''))" 2>/dev/null || echo "")
  PASS=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('tests',{}).get('pass',0))" 2>/dev/null || echo "0")
  TOTAL=$(python3 -c "import json; d=json.load(open('$TDD_STATE_FILE')); print(d.get('tests',{}).get('total',0))" 2>/dev/null || echo "0")
fi

MESSAGE="[PreCompact] TDD 상태 보존 완료: ${FEATURE} (${PHASE}) — ${PASS}/${TOTAL} tests\n백업: ${BACKUP_FILE}"

if command -v jq &>/dev/null; then
  printf '%s' "$MESSAGE" | jq -Rs '{ result: "continue", message: . }'
else
  ESCAPED_MSG=$(printf '%s' "$MESSAGE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || printf '"%s"' "$MESSAGE")
  printf '{ "result": "continue", "message": %s }' "$ESCAPED_MSG"
fi

exit 0
