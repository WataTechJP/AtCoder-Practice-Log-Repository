#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# submit.sh - 解答をcommit & pushしてGitHubへ
# Usage: ./scripts/submit.sh <number> <problem> <status> [--push]
# Status: --ac (AC), --wa (WA), --partial (部分点)
# Example: ./scripts/submit.sh 137 a --ac --push
# =====================================================

show_usage() {
  echo "Usage: $(basename "$0") <number> <problem> <status> [--push]" >&2
  echo "" >&2
  echo "Status (required):" >&2
  echo "  --ac      ✅ AC (Accepted)" >&2
  echo "  --wa      ❌ WA (Wrong Answer / 未解決)" >&2
  echo "  --partial △ 部分点" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  $(basename "$0") 137 a --ac --push" >&2
  echo "  $(basename "$0") 137 b --wa" >&2
  echo "  $(basename "$0") 137 c --partial --push" >&2
}

if [[ $# -lt 3 ]]; then
  show_usage
  exit 1
fi

NUMBER="$1"
PROBLEM=$(echo "$2" | tr '[:lower:]' '[:upper:]')
STATUS_FLAG="$3"
PUSH="${4:-}"

# ステータスを解析
case "$STATUS_FLAG" in
  --ac)
    STATUS="ac"
    STATUS_LABEL="✅ AC"
    ;;
  --wa)
    STATUS="wa"
    STATUS_LABEL="❌ WA"
    ;;
  --partial)
    STATUS="partial"
    STATUS_LABEL="△ Partial"
    ;;
  *)
    echo "❌ Invalid status: $STATUS_FLAG" >&2
    show_usage
    exit 1
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 番号を3桁にゼロ埋めしてコンテスト名を生成
CONTEST=$(printf "ABC%03d" "$NUMBER")

# ディレクトリ名は大文字のABC
PREFIX_UPPER="ABC"
TARGET_DIR="${ROOT_DIR}/${PREFIX_UPPER}/${CONTEST}/${PROBLEM}"
TARGET_FILE="${TARGET_DIR}/${PROBLEM}.py"
TESTCASE_DIR="${TARGET_DIR}/testcases"
STATUS_FILE="${TARGET_DIR}/status.txt"

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "❌ File not found: $TARGET_FILE" >&2
  exit 1
fi

# Gitリポジトリの確認
if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not a git repository: $ROOT_DIR" >&2
  exit 1
fi

# ステータスファイルを作成/更新
echo "$STATUS" > "$STATUS_FILE"
echo "📊 Status: $STATUS_LABEL"

echo "📦 Staging files..."

# 解答ファイルをステージ
git -C "$ROOT_DIR" add "$TARGET_FILE"
git -C "$ROOT_DIR" add "$STATUS_FILE"

# テストケースがあればそれもステージ
if [[ -d "$TESTCASE_DIR" ]]; then
  git -C "$ROOT_DIR" add "${TESTCASE_DIR}/"*.in 2>/dev/null || true
  git -C "$ROOT_DIR" add "${TESTCASE_DIR}/"*.out 2>/dev/null || true
fi

# コミット
PROBLEM_UPPER=$(echo "$PROBLEM" | tr '[:lower:]' '[:upper:]')
COMMIT_MSG="${CONTEST} ${PROBLEM_UPPER} [${STATUS^^}]"
git -C "$ROOT_DIR" commit -m "$COMMIT_MSG" || {
  echo "⚠️  Nothing to commit (no changes)." >&2
  exit 0
}

echo "✅ Committed: $COMMIT_MSG"

# README更新
echo "📝 Updating README..."
"${SCRIPT_DIR}/update-readme.sh"
git -C "$ROOT_DIR" add "${ROOT_DIR}/README.md"
git -C "$ROOT_DIR" commit -m "Update solved problems list" || true

# プッシュ
if [[ "$PUSH" == "--push" ]]; then
  echo "🚀 Pushing to remote..."
  git -C "$ROOT_DIR" push
  echo "✅ Pushed to GitHub!"
else
  echo ""
  echo "📌 To push: git push"
  echo "   Or run: ./scripts/submit.sh ${NUMBER} ${PROBLEM} ${STATUS_FLAG} --push"
fi
