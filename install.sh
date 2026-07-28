#!/usr/bin/env bash
# Claude Code TUI 테마를 설치한다. 터미널 색은 terminals/ 참고 (선택).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/themes"

mkdir -p "$DEST"
cp "$DIR/claude/yawn.json" "$DEST/yawn.json"
echo "installed -> $DEST/yawn.json"
echo
echo "적용: Claude Code 에서  /theme  ->  yawn"
