#!/usr/bin/env bash
set -euo pipefail

# SessionStart hook: TDD 상태 복원 + 스킬 안내
# stdin: JSON (세션 시작 컨텍스트)
# stdout: JSON { hookSpecificOutput: { hookEventName, additionalContext } }

INPUT=$(cat)
PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${PLUGIN_ROOT}/config.json"

# TDD 상태 파일 경로
TDD_STATE_FILE=".claude/state/tdd-state.json"
if command -v jq &>/dev/null && [ -f "$CONFIG_FILE" ]; then
  TDD_STATE_FILE=$(jq -r '.tdd.stateFile // ".claude/state/tdd-state.json"' "$CONFIG_FILE" 2>/dev/null || echo ".claude/state/tdd-state.json")
fi

# TDD 상태 복원
TDD_FEATURE=""
TDD_PHASE=""
TDD_PASS="0"
TDD_TOTAL="0"
HAS_TDD="false"

if [ -f "$TDD_STATE_FILE" ] && command -v jq &>/dev/null; then
  TDD_FEATURE=$(jq -r '.feature // ""' "$TDD_STATE_FILE" 2>/dev/null || echo "")
  TDD_PHASE=$(jq -r '.phase // ""' "$TDD_STATE_FILE" 2>/dev/null || echo "")
  TDD_PASS=$(jq -r '.tests.pass // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
  TDD_TOTAL=$(jq -r '.tests.total // 0' "$TDD_STATE_FILE" 2>/dev/null || echo "0")
  if [ -n "$TDD_PHASE" ] && [ "$TDD_PHASE" != "done" ]; then
    HAS_TDD="true"
  fi
fi

# Python으로 JSON 출력 (UTF-8 안전)
python3 << PYEOF
import json

context_lines = [
    "# fe-dev-plugins Session Start",
    "",
    "## 사용 가능한 스킬",
    "- /convention — 프로젝트 컨벤션 자동 추출",
    "- /spec — 기획 문서 분석 및 변환",
    "- /tdd — TDD 사이클 (Red → Green → Refactor)",
    "- /ui — 디자인 시스템 기반 UI 구현",
    "- /impact — PRD 변경 영향 분석",
    "- /review — 코드 리뷰",
    "- /help-me — 사용법 안내",
]

has_tdd = "$HAS_TDD" == "true"
if has_tdd:
    context_lines.extend([
        "",
        "## TDD 상태 (이전 세션에서 이어짐)",
        "- Feature: $TDD_FEATURE",
        "- Phase: $TDD_PHASE",
        "- Tests: $TDD_PASS/$TDD_TOTAL pass",
        "- /tdd $TDD_PHASE 으로 이어서 작업 가능",
    ])

output = {
    "systemMessage": "fe-dev-plugins v0.1.0 activated",
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "\n".join(context_lines),
    },
}

print(json.dumps(output, ensure_ascii=False))
PYEOF
