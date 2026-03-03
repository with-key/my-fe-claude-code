#!/usr/bin/env bash
set -euo pipefail

# UserPromptSubmit hook: 새 기능 키워드 감지 → TDD 유도 메시지 주입
# stdin: JSON { prompt: "사용자 입력 텍스트" }
# stdout: JSON { result: "continue", message: "..." }

INPUT=$(cat)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 사용자 프롬프트 추출
PROMPT=""
if command -v jq &>/dev/null; then
  PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || echo "")
elif command -v python3 &>/dev/null; then
  PROMPT=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null || echo "")
fi

# 프롬프트가 비어있으면 통과
if [ -z "$PROMPT" ]; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 이미 /tdd 또는 /spec 스킬을 사용 중이면 스킵
if echo "$PROMPT" | grep -qE '^/(tdd|spec|review|impact|ui|convention|help-me)'; then
  echo '{ "result": "continue" }'
  exit 0
fi

# 새 기능 구현 의도 감지 키워드
NEW_FEATURE_KEYWORDS="추가해|구현해|만들어|개발해|작성해|생성해|넣어|붙여|기능을|feature|implement|create|add|build"

if echo "$PROMPT" | grep -qE "$NEW_FEATURE_KEYWORDS"; then
  MESSAGE="💡 새 기능 구현 요청이 감지되었습니다. TDD 흐름으로 시작하면 안정적인 코드를 만들 수 있습니다.\n\n추천: \`/tdd start \"${PROMPT}\"\` 으로 TDD 사이클을 시작해보세요.\n\n(TDD 없이 바로 진행하려면 현재 요청을 그대로 이어가세요.)"

  if command -v jq &>/dev/null; then
    printf '%s' "$MESSAGE" | jq -Rs '{ result: "continue", message: . }'
  else
    ESCAPED_MSG=$(printf '%s' "$MESSAGE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || printf '"%s"' "$MESSAGE")
    printf '{ "result": "continue", "message": %s }' "$ESCAPED_MSG"
  fi
else
  echo '{ "result": "continue" }'
fi

exit 0
