#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# run.sh - 解答ファイルを実行（手動入力）
# Usage: ./scripts/run.sh <number> <problem>
# Example: ./scripts/run.sh 1 a
# Example: ./scripts/run.sh 137 a
# =====================================================

if [[ $# -lt 2 ]]; then
  echo "Usage: $(basename "$0") <number> <problem>" >&2
  echo "Example: $(basename "$0") 1 a" >&2
  echo "Example: $(basename "$0") 137 a" >&2
  exit 1
fi

NUMBER="$1"
PROBLEM="$2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 番号を3桁にゼロ埋めしてコンテスト名を生成
CONTEST=$(printf "abc%03d" "$NUMBER")

# ディレクトリ名は大文字のABC
PREFIX_UPPER="ABC"
TARGET_FILE="${ROOT_DIR}/${PREFIX_UPPER}/${CONTEST}/${PROBLEM}.py"

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "❌ File not found: $TARGET_FILE" >&2
  exit 1
fi

echo "🚀 Running: ${CONTEST} ${PROBLEM}"
echo "Input your data (Ctrl+D to end):"
echo "---"
python3 "$TARGET_FILE"
