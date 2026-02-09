#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# submit.sh - 解答をcommit & pushしてGitHubへ
# Usage: ./scripts/submit.sh <number> <problem> [--push]
# Example: ./scripts/submit.sh 137 a --push
# =====================================================

if [[ $# -lt 2 ]]; then
  echo "Usage: $(basename "$0") <number> <problem> [--push]" >&2
  echo "Example: $(basename "$0") 137 a --push" >&2
  exit 1
fi

NUMBER="$1"
PROBLEM=$(echo "$2" | tr '[:lower:]' '[:upper:]')
PUSH="${3:-}"

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

# Gitリポジトリの確認
if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not a git repository: $ROOT_DIR" >&2
  exit 1
fi

echo "📦 Staging files..."

# 解答ファイルをステージ
git -C "$ROOT_DIR" add "$TARGET_FILE"

# テストケースがあればそれもステージ
if [[ -d "$TESTCASE_DIR" ]]; then
  git -C "$ROOT_DIR" add "${TESTCASE_DIR}/"*.in 2>/dev/null || true
  git -C "$ROOT_DIR" add "${TESTCASE_DIR}/"*.out 2>/dev/null || true
fi

# コミット
PROBLEM_UPPER=$(echo "$PROBLEM" | tr '[:lower:]' '[:upper:]')
git -C "$ROOT_DIR" commit -m "Solve ${CONTEST} ${PROBLEM_UPPER}" || {
  echo "⚠️  Nothing to commit (no changes)." >&2
  exit 0
}

echo "✅ Committed: ${CONTEST} ${PROBLEM_UPPER}"

# プッシュ
if [[ "$PUSH" == "--push" ]]; then
  echo "🚀 Pushing to remote..."
  git -C "$ROOT_DIR" push
  echo "✅ Pushed to GitHub!"
else
  echo ""
  echo "📌 To push: git push"
  echo "   Or run: ./scripts/submit.sh ${NUMBER} ${PROBLEM} --push"
fi
