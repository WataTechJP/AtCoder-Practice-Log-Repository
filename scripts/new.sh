#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# new.sh - 問題解答用ファイルを作成
# Usage: ./scripts/new.sh <number> <problem>
# Example: ./scripts/new.sh 1 a  → ABC/abc001/a.py
# =====================================================

if [[ $# -lt 2 ]]; then
  echo "Usage: $(basename "$0") <number> <problem>" >&2
  echo "Example: $(basename "$0") 1 a" >&2
  echo "Example: $(basename "$0") 123 b" >&2
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
TARGET_DIR="${ROOT_DIR}/${PREFIX_UPPER}/${CONTEST}"
TEMPLATE="${ROOT_DIR}/template.py"
TARGET_FILE="${TARGET_DIR}/${PROBLEM}.py"
TESTCASE_DIR="${TARGET_DIR}/testcases"

mkdir -p "$TARGET_DIR"
mkdir -p "$TESTCASE_DIR"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "❌ Template not found: $TEMPLATE" >&2
  exit 1
fi

if [[ ! -f "$TARGET_FILE" ]]; then
  cp "$TEMPLATE" "$TARGET_FILE"
  echo "✅ Created: $TARGET_FILE"
else
  echo "📁 Already exists: $TARGET_FILE"
fi

# サンプルテストケースファイルを作成（なければ）
SAMPLE_IN="${TESTCASE_DIR}/${PROBLEM}_1.in"
SAMPLE_OUT="${TESTCASE_DIR}/${PROBLEM}_1.out"

if [[ ! -f "$SAMPLE_IN" ]]; then
  touch "$SAMPLE_IN"
  touch "$SAMPLE_OUT"
  echo "📝 Created testcase templates:"
  echo "   Input:  $SAMPLE_IN"
  echo "   Output: $SAMPLE_OUT"
fi

echo ""
echo "📌 Next steps:"
echo "   1. Edit solution: $TARGET_FILE"
echo "   2. Add testcases: $TESTCASE_DIR/${PROBLEM}_*.in/out"
echo "   3. Run tests: ./scripts/test.sh ${NUMBER} ${PROBLEM}"
echo "   4. Submit: ./scripts/submit.sh ${NUMBER} ${PROBLEM}"

# エディターで開く
if command -v antigravity >/dev/null 2>&1; then
  antigravity "$TARGET_FILE"
fi
