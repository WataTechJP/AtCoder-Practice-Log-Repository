#!/usr/bin/env bash
set -euo pipefail

# =====================================================
# update-readme.sh - READMEの解答一覧を更新
# Usage: ./scripts/update-readme.sh
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
README="${ROOT_DIR}/README.md"
ABC_DIR="${ROOT_DIR}/ABC"

if [[ ! -d "$ABC_DIR" ]]; then
  echo "❌ ABC directory not found" >&2
  exit 1
fi

# 一時ファイル
TMP_ALL=$(mktemp)
TMP_AC=$(mktemp)
TMP_WA=$(mktemp)
TMP_PARTIAL=$(mktemp)
TMP_TABLE=$(mktemp)
TMP_README=$(mktemp)
trap "rm -f $TMP_ALL $TMP_AC $TMP_WA $TMP_PARTIAL $TMP_TABLE $TMP_README" EXIT

AC_COUNT=0
WA_COUNT=0
PARTIAL_COUNT=0

for CONTEST_DIR in "$ABC_DIR"/ABC*/; do
  [[ -d "$CONTEST_DIR" ]] || continue
  CONTEST=$(basename "$CONTEST_DIR")

  for PROBLEM_DIR in "$CONTEST_DIR"*/; do
    [[ -d "$PROBLEM_DIR" ]] || continue
    PROBLEM=$(basename "$PROBLEM_DIR")
    PY_FILE="${PROBLEM_DIR}${PROBLEM}.py"
    STATUS_FILE="${PROBLEM_DIR}status.txt"

    # .pyファイルが存在し、gitにコミット済みか確認
    if [[ -f "$PY_FILE" ]] && git -C "$ROOT_DIR" ls-files --error-unmatch "$PY_FILE" >/dev/null 2>&1; then
      # ステータスを読み込み
      if [[ -f "$STATUS_FILE" ]]; then
        STATUS=$(cat "$STATUS_FILE")
      else
        STATUS="ac"
      fi

      # ステータスアイコン
      case "$STATUS" in
        ac)
          STATUS_ICON="✅"
          AC_COUNT=$((AC_COUNT + 1))
          ;;
        wa)
          STATUS_ICON="❌"
          WA_COUNT=$((WA_COUNT + 1))
          ;;
        partial)
          STATUS_ICON="△"
          PARTIAL_COUNT=$((PARTIAL_COUNT + 1))
          ;;
        *)
          STATUS_ICON="?"
          STATUS="other"
          ;;
      esac

      # コンテスト番号を抽出 (ABC001 -> 1)
      NUM=$(echo "$CONTEST" | sed 's/ABC0*//')
      CONTEST_LOWER=$(echo "$CONTEST" | tr '[:upper:]' '[:lower:]')
      PROBLEM_LOWER=$(echo "$PROBLEM" | tr '[:upper:]' '[:lower:]')
      URL="https://atcoder.jp/contests/${CONTEST_LOWER}/tasks/${CONTEST_LOWER}_${PROBLEM_LOWER}"

      # ソート用にゼロ埋め番号を付加
      SORT_KEY=$(printf "%04d_%s" "$NUM" "$PROBLEM")
      LINE="| ${CONTEST} | ${PROBLEM} | ${STATUS_ICON} | [問題](${URL}) |"

      echo "${SORT_KEY}|${LINE}" >> "$TMP_ALL"
      case "$STATUS" in
        ac) echo "${SORT_KEY}|${LINE}" >> "$TMP_AC" ;;
        wa) echo "${SORT_KEY}|${LINE}" >> "$TMP_WA" ;;
        partial) echo "${SORT_KEY}|${LINE}" >> "$TMP_PARTIAL" ;;
      esac
    fi
  done
done

TOTAL=$((AC_COUNT + WA_COUNT + PARTIAL_COUNT))

# テーブルを一時ファイルに書き出し
{
  echo "## 解答一覧"
  echo ""
  echo "**Total: ${TOTAL} problems** (✅ ${AC_COUNT} AC / ❌ ${WA_COUNT} WA / △ ${PARTIAL_COUNT} Partial)"
  echo ""
  echo "### 全問題"
  echo ""
  echo "| Contest | Problem | Status | Link |"
  echo "|---------|---------|--------|------|"
  if [[ -s "$TMP_ALL" ]]; then
    sort "$TMP_ALL" | cut -d'|' -f2-
  fi
  echo ""
  echo "### ✅ AC (${AC_COUNT})"
  echo ""
  echo "| Contest | Problem | Status | Link |"
  echo "|---------|---------|--------|------|"
  if [[ -s "$TMP_AC" ]]; then
    sort "$TMP_AC" | cut -d'|' -f2-
  fi
  echo ""
  echo "### ❌ WA (${WA_COUNT})"
  echo ""
  echo "| Contest | Problem | Status | Link |"
  echo "|---------|---------|--------|------|"
  if [[ -s "$TMP_WA" ]]; then
    sort "$TMP_WA" | cut -d'|' -f2-
  fi
  echo ""
  echo "### △ Partial (${PARTIAL_COUNT})"
  echo ""
  echo "| Contest | Problem | Status | Link |"
  echo "|---------|---------|--------|------|"
  if [[ -s "$TMP_PARTIAL" ]]; then
    sort "$TMP_PARTIAL" | cut -d'|' -f2-
  fi
} > "$TMP_TABLE"

# READMEを更新（解答一覧セクションを置き換え）
if grep -q "^## 解答一覧" "$README"; then
  # 解答一覧の開始行と次のセクションの行番号を取得
  START_LINE=$(grep -n "^## 解答一覧" "$README" | head -1 | cut -d: -f1)
  # 解答一覧の次の ## セクションを探す
  END_LINE=$(tail -n +$((START_LINE + 1)) "$README" | grep -n "^## " | head -1 | cut -d: -f1)

  if [[ -n "$END_LINE" ]]; then
    # 次のセクションがある場合
    END_LINE=$((START_LINE + END_LINE - 1))
    # 解答一覧の前 + 新しいテーブル + 解答一覧の後
    head -n $((START_LINE - 1)) "$README" > "$TMP_README"
    cat "$TMP_TABLE" >> "$TMP_README"
    echo "" >> "$TMP_README"
    tail -n +$((END_LINE)) "$README" >> "$TMP_README"
  else
    # 解答一覧が最後のセクションの場合
    head -n $((START_LINE - 1)) "$README" > "$TMP_README"
    cat "$TMP_TABLE" >> "$TMP_README"
  fi
  mv "$TMP_README" "$README"
else
  # 新規追加（ヘッダーの後に挿入）
  head -n 4 "$README" > "$TMP_README"
  echo "" >> "$TMP_README"
  cat "$TMP_TABLE" >> "$TMP_README"
  echo "" >> "$TMP_README"
  tail -n +5 "$README" >> "$TMP_README"
  mv "$TMP_README" "$README"
fi

echo "✅ README updated: ${TOTAL} problems (✅${AC_COUNT} / ❌${WA_COUNT} / △${PARTIAL_COUNT})"
