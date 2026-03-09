#!/usr/bin/env bash
set -euo pipefail

# PreToolUse (Write|Edit) hook: config.json의 protectedFiles 기반 파일 수정 차단
# stdin: JSON { tool_name, tool_input: { file_path, ... } }
# stdout: JSON { result: "continue" } 또는 exit 2로 차단
# exit 2 = 도구 실행 차단

INPUT=$(cat)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${PLUGIN_ROOT}/config.json"

# 변경 대상 파일 경로 추출
FILE_PATH=""
if command -v jq &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // ""' 2>/dev/null || echo "")
elif command -v python3 &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); ti=d.get('tool_input',{}); print(ti.get('file_path','') or ti.get('filePath',''))" 2>/dev/null || echo "")
fi

# 파일 경로가 없으면 통과
if [ -z "$FILE_PATH" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 파일명만 추출
FILENAME=$(basename "$FILE_PATH")

# protectedFiles 목록 가져오기
PROTECTED_FILES=""
if command -v jq &>/dev/null; then
  PROTECTED_FILES=$(jq -r '.protectedFiles[]' "$CONFIG_FILE" 2>/dev/null || echo "")
elif command -v python3 &>/dev/null; then
  PROTECTED_FILES=$(python3 -c "import json; [print(f) for f in json.load(open('$CONFIG_FILE')).get('protectedFiles',[])]" 2>/dev/null || echo "")
fi

# 보호 파일 확인
BLOCKED=false
MATCHED_PATTERN=""

while IFS= read -r pattern; do
  [ -z "$pattern" ] && continue

  # 정확히 매치 (예: .env)
  if [ "$FILENAME" = "$pattern" ]; then
    BLOCKED=true
    MATCHED_PATTERN="$pattern"
    break
  fi

  # 와일드카드 매치 (예: .env.*)
  # bash의 패턴 매칭 사용
  case "$FILENAME" in
    $pattern)
      BLOCKED=true
      MATCHED_PATTERN="$pattern"
      break
      ;;
  esac

  case "$FILE_PATH" in
    $pattern)
      BLOCKED=true
      MATCHED_PATTERN="$pattern"
      break
      ;;
  esac
done <<< "$PROTECTED_FILES"

if [ "$BLOCKED" = true ]; then
  echo "차단: 보호 대상 파일입니다 (패턴: ${MATCHED_PATTERN}). 이 파일은 수동으로만 수정할 수 있습니다." >&2
  exit 2
fi

# 통과
echo '{ "result": "continue" }'
exit 0
