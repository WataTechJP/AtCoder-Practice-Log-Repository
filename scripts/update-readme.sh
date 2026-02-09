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

# 解答済み問題を収集
declare -a ALL_ENTRIES=()
declare -a AC_ENTRIES=()
declare -a WA_ENTRIES=()
declare -a PARTIAL_ENTRIES=()

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
        STATUS="ac"  # デフォルトはAC
      fi

      # ステータスアイコン
      case "$STATUS" in
        ac)
          STATUS_ICON="✅"
          ;;
        wa)
          STATUS_ICON="❌"
          ;;
        partial)
          STATUS_ICON="△"
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
      ENTRY="${SORT_KEY}|${CONTEST}|${PROBLEM}|${URL}|${STATUS_ICON}"

      ALL_ENTRIES+=("$ENTRY")
      case "$STATUS" in
        ac) AC_ENTRIES+=("$ENTRY") ;;
        wa) WA_ENTRIES+=("$ENTRY") ;;
        partial) PARTIAL_ENTRIES+=("$ENTRY") ;;
      esac
    fi
  done
done

# ソート関数
sort_entries() {
  local -n arr=$1
  if [[ ${#arr[@]} -gt 0 ]]; then
    IFS=$'\n' arr=($(sort <<<"${arr[*]}")); unset IFS
  fi
}

sort_entries ALL_ENTRIES
sort_entries AC_ENTRIES
sort_entries WA_ENTRIES
sort_entries PARTIAL_ENTRIES

# テーブル行を生成する関数
generate_rows() {
  local -n entries=$1
  local rows=""
  for ENTRY in "${entries[@]}"; do
    CONTEST=$(echo "$ENTRY" | cut -d'|' -f2)
    PROBLEM=$(echo "$ENTRY" | cut -d'|' -f3)
    URL=$(echo "$ENTRY" | cut -d'|' -f4)
    STATUS_ICON=$(echo "$ENTRY" | cut -d'|' -f5)
    rows="${rows}
| ${CONTEST} | ${PROBLEM} | ${STATUS_ICON} | [問題](${URL}) |"
  done
  echo "$rows"
}

# カウント
TOTAL=${#ALL_ENTRIES[@]}
AC_COUNT=${#AC_ENTRIES[@]}
WA_COUNT=${#WA_ENTRIES[@]}
PARTIAL_COUNT=${#PARTIAL_ENTRIES[@]}

# メインテーブル生成
TABLE="## 解答一覧

**Total: ${TOTAL} problems** (✅ ${AC_COUNT} AC / ❌ ${WA_COUNT} WA / △ ${PARTIAL_COUNT} Partial)

### 全問題

| Contest | Problem | Status | Link |
|---------|---------|--------|------|"

if [[ ${#ALL_ENTRIES[@]} -gt 0 ]]; then
  TABLE="${TABLE}$(generate_rows ALL_ENTRIES)"
fi

# ACテーブル
TABLE="${TABLE}

### ✅ AC (${AC_COUNT})

| Contest | Problem | Status | Link |
|---------|---------|--------|------|"

if [[ ${#AC_ENTRIES[@]} -gt 0 ]]; then
  TABLE="${TABLE}$(generate_rows AC_ENTRIES)"
fi

# WAテーブル
TABLE="${TABLE}

### ❌ WA (${WA_COUNT})

| Contest | Problem | Status | Link |
|---------|---------|--------|------|"

if [[ ${#WA_ENTRIES[@]} -gt 0 ]]; then
  TABLE="${TABLE}$(generate_rows WA_ENTRIES)"
fi

# Partialテーブル
TABLE="${TABLE}

### △ Partial (${PARTIAL_COUNT})

| Contest | Problem | Status | Link |
|---------|---------|--------|------|"

if [[ ${#PARTIAL_ENTRIES[@]} -gt 0 ]]; then
  TABLE="${TABLE}$(generate_rows PARTIAL_ENTRIES)"
fi

# READMEを更新
if grep -q "^## 解答一覧" "$README"; then
  # 既存のセクションを置換
  awk -v table="$TABLE" '
    /^## 解答一覧/ { skip=1; print table; next }
    /^## / && skip { skip=0 }
    !skip { print }
  ' "$README" > "${README}.tmp"
  mv "${README}.tmp" "$README"
else
  # 新規追加（ファイル末尾に）
  echo "" >> "$README"
  echo "$TABLE" >> "$README"
fi

echo "✅ README updated: ${TOTAL} problems (✅${AC_COUNT} / ❌${WA_COUNT} / △${PARTIAL_COUNT})"
