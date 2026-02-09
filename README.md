# AtCoder Solutions

AtCoderの解答を管理するリポジトリです。
python version 3.13.7

## ワークフロー

```
1. new.sh     → 問題ファイル作成
2. run.sh     → 実行してサンプル入力
3. submit.sh  → commit & push
```

## 使い方

### 1. 問題ファイルを作成

```bash
./scripts/new.sh abc001 a
```

### 2. コードを書いて実行

```bash
./scripts/run.sh abc001 a
```

サンプル入力を手動で入力 → Ctrl+D で終了

### 3. 解答をcommit & push

```bash
./scripts/submit.sh abc001 a --push
```

## エイリアス（任意）

```bash
alias acn="$HOME/Private/AtCoder/scripts/new.sh"
alias acr="$HOME/Private/AtCoder/scripts/run.sh"
alias acs="$HOME/Private/AtCoder/scripts/submit.sh"
```

```bash
acn 137 a         # ファイル作成
acr 137 a         # 実行
acs 137 a --push  # コミット&プッシュ
