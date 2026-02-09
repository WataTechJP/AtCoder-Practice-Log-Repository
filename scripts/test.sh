#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# test.sh - テストケースを実行
# Usage: ./scripts/test.sh <number> <problem>
# Example: ./scripts/test.sh 1 A
# =====================================================

if [[ $# -lt 2 ]]; then
  echo "Usage: $(basename "$0") <number> <problem>" >&2
  echo "Example: $(basename "$0") 1 A" >&2
  exit 1
fi

NUMBER="$1"
PROBLEM=$(echo "$2" | tr '[:lower:]' '[:upper:]')

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 番号を3桁にゼロ埋めしてコンテスト名を生成
CONTEST=$(printf "ABC%03d" "$NUMBER")

# ディレクトリ名は大文字のABC
PREFIX_UPPER="ABC"
TARGET_DIR="${ROOT_DIR}/${PREFIX_UPPER}/${CONTEST}/${PROBLEM}"
TARGET_FILE="${TARGET_DIR}/${PROBLEM}.py"
TESTCASE_DIR="${TARGET_DIR}/testcases"

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "❌ File not found: $TARGET_FILE" >&2
  exit 1
fi

if [[ ! -d "$TESTCASE_DIR" ]]; then
  echo "❌ Testcase directory not found: $TESTCASE_DIR" >&2
  exit 1
fi

echo "🧪 Testing: ${CONTEST} ${PROBLEM}"
echo ""

PASSED=0
FAILED=0

for INPUT_FILE in "${TESTCASE_DIR}"/*.in; do
  [[ -f "$INPUT_FILE" ]] || continue

  # 対応する出力ファイル名を取得
  BASENAME=$(basename "$INPUT_FILE" .in)
  EXPECTED_FILE="${TESTCASE_DIR}/${BASENAME}.out"

  if [[ ! -f "$EXPECTED_FILE" ]]; then
    echo "⚠️  No expected output for: $BASENAME"
    continue
  fi

  # 入力ファイルが空ならスキップ
  if [[ ! -s "$INPUT_FILE" ]]; then
    echo "⚠️  Empty input file: $BASENAME (skipped)"
    continue
  fi

  # 実行して結果を取得
  ACTUAL=$(python3 "$TARGET_FILE" < "$INPUT_FILE" 2>&1) || true
  EXPECTED=$(cat "$EXPECTED_FILE")

  # 比較（末尾の空白・改行を無視）
  ACTUAL_TRIMMED=$(echo "$ACTUAL" | sed 's/[[:space:]]*$//')
  EXPECTED_TRIMMED=$(echo "$EXPECTED" | sed 's/[[:space:]]*$//')

  if [[ "$ACTUAL_TRIMMED" == "$EXPECTED_TRIMMED" ]]; then
    echo "✅ $BASENAME: PASSED"
    ((PASSED++))
  else
    echo "❌ $BASENAME: FAILED"
    echo "   Input:"
    sed 's/^/     /' "$INPUT_FILE"
    echo "   Expected:"
    echo "$EXPECTED" | sed 's/^/     /'
    echo "   Actual:"
    echo "$ACTUAL" | sed 's/^/     /'
    echo ""
    ((FAILED++))
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: ✅ $PASSED passed, ❌ $FAILED failed"

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
