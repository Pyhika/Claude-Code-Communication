# エージェント定数管理システム

## 概要

このディレクトリは、マルチエージェントシステム全体で使用されるエージェント名、アイコン、説明、内部識別子などの定数を一元管理します。

## ファイル構成

- **agents.sh**: エージェント定数定義と関連関数

## 目的

名前の不一致問題を根本的に解決するため、全てのエージェント関連の定数を一箇所に集約しました。

### 解決した問題

1. **命名の不一致**: FRONTEND vs worker1、ARCHITECT vs boss1 など
2. **アイコンの重複定義**: 各スクリプトで同じアイコンを個別に定義
3. **説明文の不統一**: 同じエージェントでも説明が微妙に異なる
4. **保守性の低下**: 変更時に複数ファイルを修正する必要がある

## 使用方法

### 基本的な読み込み

```bash
#!/bin/bash

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 定数読み込み
source "$SCRIPT_DIR/../const/agents.sh"
```

### エージェント名の使用

```bash
# 公式エージェント名（大文字）
echo "$AGENT_PRESIDENT"   # PRESIDENT
echo "$AGENT_FRONTEND"    # FRONTEND
echo "$AGENT_REVIEWER_A"  # REVIEWER_A
```

### アイコンと説明の取得

```bash
# アイコン取得
icon=$(get_agent_icon "$AGENT_FRONTEND")  # 🎨

# 説明取得
desc=$(get_agent_desc "$AGENT_FRONTEND")  # UI/UX実装

# 表示
echo "$icon $AGENT_FRONTEND ($desc)"  # 🎨 FRONTEND (UI/UX実装)
```

### 内部識別子とtmuxターゲット

```bash
# 内部名取得（agent-identity.sh用）
internal=$(get_internal_name "$AGENT_FRONTEND")  # worker1

# tmuxターゲット取得（通信用）
target=$(get_tmux_target "$AGENT_FRONTEND")  # multiagent:0.1
```

### 名前の正規化

```bash
# 大文字小文字やレガシー名を正規化
normalized=$(normalize_agent_name "frontend")  # FRONTEND
normalized=$(normalize_agent_name "worker1")   # FRONTEND
normalized=$(normalize_agent_name "boss1")     # ARCHITECT
```

### エージェント配列の使用

```bash
# 統括グループ（2エージェント）
for agent in "${MANAGEMENT_AGENTS[@]}"; do
    echo "$agent"  # PRESIDENT, ARCHITECT
done

# 実装グループ（8エージェント）
for agent in "${WORKER_AGENTS[@]}"; do
    echo "$agent"  # FRONTEND, BACKEND, DATABASE, SECURITY, TESTING, DEPLOY, DOCS, QA
done

# レビューグループ（2エージェント）
for agent in "${REVIEWER_AGENTS[@]}"; do
    echo "$agent"  # REVIEWER_A, REVIEWER_B
done

# 全エージェント（12エージェント）
for agent in "${ALL_AGENTS[@]}"; do
    echo "$agent"
done
```

## 定数一覧

### エージェント名（公式名）

| 定数 | 値 | グループ |
|------|-----|----------|
| `AGENT_PRESIDENT` | PRESIDENT | 統括 |
| `AGENT_ARCHITECT` | ARCHITECT | 統括 |
| `AGENT_FRONTEND` | FRONTEND | 実装 |
| `AGENT_BACKEND` | BACKEND | 実装 |
| `AGENT_DATABASE` | DATABASE | 実装 |
| `AGENT_SECURITY` | SECURITY | 実装 |
| `AGENT_TESTING` | TESTING | 実装 |
| `AGENT_DEPLOY` | DEPLOY | 実装 |
| `AGENT_DOCS` | DOCS | 実装 |
| `AGENT_QA` | QA | 実装 |
| `AGENT_REVIEWER_A` | REVIEWER_A | レビュー |
| `AGENT_REVIEWER_B` | REVIEWER_B | レビュー |

### アイコン定義

| 定数 | 値 | エージェント |
|------|-----|-------------|
| `ICON_PRESIDENT` | 👑 | PRESIDENT |
| `ICON_ARCHITECT` | 🏗️ | ARCHITECT |
| `ICON_FRONTEND` | 🎨 | FRONTEND |
| `ICON_BACKEND` | ⚙️ | BACKEND |
| `ICON_DATABASE` | 🗄️ | DATABASE |
| `ICON_SECURITY` | 🔒 | SECURITY |
| `ICON_TESTING` | 🧪 | TESTING |
| `ICON_DEPLOY` | 🚀 | DEPLOY |
| `ICON_DOCS` | 📚 | DOCS |
| `ICON_QA` | 🔍 | QA |
| `ICON_REVIEWER_A` | 🔍 | REVIEWER_A |
| `ICON_REVIEWER_B` | 🛡️ | REVIEWER_B |

### 内部識別子（tmuxターゲット）

| エージェント | tmuxターゲット |
|-------------|----------------|
| PRESIDENT | president |
| ARCHITECT | multiagent:0.0 |
| FRONTEND | multiagent:0.1 |
| BACKEND | multiagent:0.2 |
| DATABASE | multiagent:0.3 |
| SECURITY | multiagent:0.4 |
| TESTING | multiagent:0.5 |
| DEPLOY | multiagent:0.6 |
| DOCS | multiagent:0.7 |
| QA | multiagent:0.8 |
| REVIEWER_A | reviewer_a |
| REVIEWER_B | reviewer_b |

### 内部名（agent-identity用）

| エージェント | 内部名 |
|-------------|--------|
| PRESIDENT | president |
| ARCHITECT | architect |
| FRONTEND | worker1 |
| BACKEND | worker2 |
| DATABASE | worker3 |
| SECURITY | worker4 |
| TESTING | worker5 |
| DEPLOY | worker6 |
| DOCS | worker7 |
| QA | worker8 |
| REVIEWER_A | reviewer_a |
| REVIEWER_B | reviewer_b |

## ヘルパー関数

### get_tmux_target(agent_name)
エージェント名からtmuxターゲット文字列を取得します。

**引数**: エージェント名（例: "FRONTEND"）
**戻り値**: tmuxターゲット（例: "multiagent:0.1"）

### get_internal_name(agent_name)
エージェント名から内部識別子を取得します。

**引数**: エージェント名（例: "FRONTEND"）
**戻り値**: 内部名（例: "worker1"）

### get_agent_icon(agent_name)
エージェント名からアイコンを取得します。

**引数**: エージェント名（例: "FRONTEND"）
**戻り値**: アイコン（例: "🎨"）

### get_agent_desc(agent_name)
エージェント名から役割説明を取得します。

**引数**: エージェント名（例: "FRONTEND"）
**戻り値**: 説明（例: "UI/UX実装"）

### normalize_agent_name(input)
大文字小文字やレガシー名を正規化します。

**引数**: 任意の形式のエージェント名（例: "frontend", "worker1", "boss1"）
**戻り値**: 正規化されたエージェント名（例: "FRONTEND", "ARCHITECT"）

**サポートするレガシー名**:
- boss1 → ARCHITECT
- worker1-8 → FRONTEND-QA

### is_valid_agent(agent_name)
エージェント名が有効かチェックします。

**引数**: エージェント名
**戻り値**: 有効なら0、無効なら1（シェルの戻り値）

## 統合されたスクリプト

以下のスクリプトが定数ファイルを使用するように更新されました:

1. **agent-send.sh**: エージェント間通信
2. **agent-identity.sh**: エージェント識別バナー表示
3. **launch-by-group.sh**: グループ別起動
4. **dashboard.sh**: TUIダッシュボード

## メリット

### 1. 一貫性
全てのスクリプトで同じ名前、アイコン、説明を使用

### 2. 保守性
定数変更時は1ファイルのみ修正すればよい

### 3. 拡張性
新しいエージェントを追加する際も定数ファイルのみ編集

### 4. 可読性
スクリプト内でハードコードされた文字列が減少

### 5. バグ防止
タイポや不一致によるバグを根本的に防止

## 変更履歴

- **2025-10-06**: 初版作成、全スクリプトを定数ベースに移行
  - エージェント名の統一（PRESIDENT, ARCHITECT, FRONTEND-QA, REVIEWER_A/B）
  - レガシー名のサポート（boss1, worker1-8）
  - ヘルパー関数の実装
