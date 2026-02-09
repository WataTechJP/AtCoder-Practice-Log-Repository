# AtCoder Solutions

AtCoderの解答を管理するリポジトリです。
python version 3.13.7

## ワークフロー

```
1. new.sh     → 問題ファイル作成
2. (テストケース追加)
3. test.sh    → テスト実行
4. submit.sh  → commit & push
```

## 使い方

### 1. 問題ファイルを作成

```bash
./scripts/new.sh 1 A    # ABC001 A → ABC/ABC001/A/A.py
./scripts/new.sh 1 B    # ABC001 B → ABC/ABC001/B/B.py
./scripts/new.sh 137 C  # ABC137 C → ABC/ABC137/C/C.py
```

ファイル構造:
```
ABC/ABC001/A/
├── A.py
└── testcases/
    ├── 1.in
    └── 1.out
```

※ 小文字でも自動的に大文字に変換されます（`a` → `A`）

### 2. テストケースを追加

AtCoderの問題ページからサンプル入出力をコピーしてファイルに保存:

```bash
# 入力例1 → testcases/1.in
# 出力例1 → testcases/1.out
# 入力例2 → testcases/2.in
# 出力例2 → testcases/2.out
```

例: ABC001 A のサンプル
```
ABC/ABC001/A/testcases/
├── 1.in   ← 入力例1
├── 1.out  ← 出力例1
├── 2.in   ← 入力例2
└── 2.out  ← 出力例2
```

### 3. テストを実行

```bash
./scripts/test.sh 1 A
```

全テストケースを実行して結果を表示:
```
🧪 Testing: ABC001 A

✅ 1: PASSED
✅ 2: PASSED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Results: ✅ 2 passed, ❌ 0 failed
```

### 4. 手動で実行（任意）

```bash
./scripts/run.sh 1 A
```

サンプル入力を手動で入力 → Ctrl+D で終了

### 5. 解答をcommit & push

```bash
./scripts/submit.sh 1 A --ac --push      # ✅ AC (正解)
./scripts/submit.sh 1 B --wa             # ❌ WA (不正解/未解決)
./scripts/submit.sh 1 C --partial --push # △ 部分点
```

| ステータス | フラグ | 意味 |
|-----------|--------|------|
| ✅ | `--ac` | AC (Accepted) |
| ❌ | `--wa` | WA (Wrong Answer / 未解決) |
| △ | `--partial` | 部分点 |

※ コミット時に解答一覧が自動更新されます

## エイリアス（任意）

```bash
alias acn="$HOME/Private/AtCoder/scripts/new.sh"
alias act="$HOME/Private/AtCoder/scripts/test.sh"
alias acr="$HOME/Private/AtCoder/scripts/run.sh"
alias acs="$HOME/Private/AtCoder/scripts/submit.sh"
```

```bash
acn 137 A              # ファイル作成
act 137 A              # テスト実行
acr 137 A              # 手動実行
acs 137 A --ac --push  # AC でコミット&プッシュ
acs 137 B --wa         # WA でコミット
acs 137 C --partial    # 部分点でコミット
```

## 解答一覧

| Contest | Problem | Status | Link |
|---------|---------|--------|------|

**Total: 0 problems** (✅ 0 AC / ❌ 0 WA / △ 0 Partial)
