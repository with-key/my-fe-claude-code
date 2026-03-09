#!/usr/bin/env bash
set -euo pipefail

# PostToolUse (Write|Edit) hook: 변경 파일의 대응 테스트 자동 실행
# stdin: JSON { tool_name, tool_input: { file_path, ... } }
# stdout: JSON { result: "continue", message: "..." }

INPUT=$(cat)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${PLUGIN_ROOT}/config.json"

# 변경된 파일 경로 추출
FILE_PATH=""
if command -v jq &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // ""' 2>/dev/null || echo "")
elif command -v python3 &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); ti=d.get('tool_input',{}); print(ti.get('file_path','') or ti.get('filePath',''))" 2>/dev/null || echo "")
fi

# 파일 경로가 없으면 종료
if [ -z "$FILE_PATH" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 테스트 파일 자체가 변경된 경우 스킵
if echo "$FILE_PATH" | grep -qE '\.(test|spec)\.(ts|tsx)$'; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 소스 파일이 아닌 경우 스킵 (.ts, .tsx 파일만 대상)
if ! echo "$FILE_PATH" | grep -qE '\.(ts|tsx)$'; then
  echo '{ "result": "continue" }'
  exit 0
fi

# autoRunOnChange 설정 확인
AUTO_RUN="true"
if command -v jq &>/dev/null; then
  AUTO_RUN=$(jq -r '.test.autoRunOnChange // true' "$CONFIG_FILE" 2>/dev/null || echo "true")
elif command -v python3 &>/dev/null; then
  AUTO_RUN=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(str(d.get('test',{}).get('autoRunOnChange',True)).lower())" 2>/dev/null || echo "true")
fi

if [ "$AUTO_RUN" != "true" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 대응 테스트 파일 찾기
DIR=$(dirname "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH" | sed -E 's/\.(ts|tsx)$//')
TEST_FILE=""

# 같은 디렉토리에서 .test.ts, .test.tsx 찾기
for EXT in "test.ts" "test.tsx"; do
  CANDIDATE="${DIR}/${BASENAME}.${EXT}"
  if [ -f "$CANDIDATE" ]; then
    TEST_FILE="$CANDIDATE"
    break
  fi
done

# __tests__ 디렉토리에서 찾기
if [ -z "$TEST_FILE" ]; then
  for EXT in "test.ts" "test.tsx"; do
    CANDIDATE="${DIR}/__tests__/${BASENAME}.${EXT}"
    if [ -f "$CANDIDATE" ]; then
      TEST_FILE="$CANDIDATE"
      break
    fi
  done
fi

# 테스트 파일이 없으면 종료
if [ -z "$TEST_FILE" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

if ! command -v npx &>/dev/null; then
  echo '{ "result": "continue", "message": "Auto Test skipped: npx is not available." }'
  exit 0
fi

if ! npx --no-install vitest --version &>/dev/null; then
  echo '{ "result": "continue", "message": "Auto Test skipped: vitest is not installed in this project." }'
  exit 0
fi

# 테스트 실행
TEST_OUTPUT=""
TEST_EXIT=0
TEST_OUTPUT=$(npx --no-install vitest run "$TEST_FILE" --reporter=verbose 2>&1) || TEST_EXIT=$?

# 결과 파싱 (간단한 pass/fail 카운트)
PASS_COUNT=$(echo "$TEST_OUTPUT" | grep -cE '✓|✔|PASS' || echo "0")
FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -cE '✗|✘|FAIL|×' || echo "0")
TOTAL_COUNT=$((PASS_COUNT + FAIL_COUNT))

if [ "$TOTAL_COUNT" -eq 0 ]; then
  TOTAL_COUNT=1
  if [ "$TEST_EXIT" -eq 0 ]; then
    PASS_COUNT=1
    FAIL_COUNT=0
  else
    PASS_COUNT=0
    FAIL_COUNT=1
  fi
fi

# 결과 포맷
if [ "$TEST_EXIT" -eq 0 ]; then
  RESULT_TEXT="${PASS_COUNT}/${TOTAL_COUNT} PASS"
else
  RESULT_TEXT="${PASS_COUNT}/${TOTAL_COUNT} PASS | ${FAIL_COUNT} FAIL"
fi

MESSAGE="┌─ Auto Test ─────────────────────────┐\n│ Trigger: ${FILE_PATH}\n│ Run:     ${TEST_FILE}\n│ Result:  ${RESULT_TEXT}\n└──────────────────────────────────────┘"

# JSON 출력
if command -v jq &>/dev/null; then
  printf '%s' "$MESSAGE" | jq -Rs '{ result: "continue", message: . }'
else
  ESCAPED_MSG=$(printf '%s' "$MESSAGE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || printf '"%s"' "$MESSAGE")
  printf '{ "result": "continue", "message": %s }' "$ESCAPED_MSG"
fi

exit 0
