# 🤖 Claude Code マルチエージェント通信システム

**複数のAIエージェントが協力して開発する、革新的なチーム開発システム**

<div align="center">

[![Claude Code](https://img.shields.io/badge/Claude-Code-blue)](https://claude.ai/code)
[![tmux](https://img.shields.io/badge/tmux-required-green)](https://github.com/tmux/tmux)
[![License](https://img.shields.io/badge/license-MIT-purple)](LICENSE)

</div>

## 📌 概要

複数のClaude AIエージェントが、まるで本物の開発チームのように協力してプロジェクトを遂行するシステムです。社長、マネージャー、エンジニアたちが自律的にコミュニケーションを取りながら開発を進めます。

### ✨ 特徴

- 🏢 **階層的チーム構造** - PRESIDENT → boss1 → workers の組織構造
- 💬 **自律的コミュニケーション** - エージェント間の自動メッセージング
- 🖥️ **マルチペイン管理** - tmuxによる複数画面の同時管理
- 🖱️ **マウス操作対応** - クリックでペイン選択、スクロール可能
- 📊 **リアルタイム監視** - プロジェクト進捗の可視化
- 🎨 **柔軟なレイアウト** - 画面構成を自由に変更可能

### 🎯 実績

- 3時間で完成したアンケートシステム（EmotiFlow）
- 12個の革新的アイデアを生成
- 100%のテストカバレッジ達成

## 🎯 システム構成図

```
┌─────────────────────────────────────────────────────────────┐
│                    👑 PRESIDENT                             │
│              （プロジェクト統括責任者）                      │
│                         ↓                                   │
│                    指示・承認                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                    🎯 boss1                                 │
│                （チームリーダー）                           │
│                         ↓                                   │
│               タスク分解・割り当て                          │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌──────────┬──────────┬──────────┬──────────┬──────────────┐
│ worker1  │ worker2  │ worker3  │ worker4  │  worker5...  │
│  UI/UX   │   API    │  テスト  │  ドキュメ │   その他     │
└──────────┴──────────┴──────────┴──────────┴──────────────┘

【通信フロー】
PRESIDENT → boss1 → workers → boss1 → PRESIDENT
```

## 🚀 クイックスタート（5分で開始）

### 前提条件

- **OS**: macOS または Linux
- **必須ツール**: 
  - `tmux` - ターミナル分割ツール
  - `claude` - Claude Code CLI
- **推奨ツール**: 
  - `gum` または `fzf` - ダッシュボード用

### インストール確認

```bash
# tmuxのインストール確認
tmux -V  # 出力例: tmux 3.3a

# Claude CLIのインストール確認
claude --version  # 出力例: claude-cli 0.x.x

# インストールされていない場合
brew install tmux  # macOS
# Claude CLIは https://claude.ai/code からインストール
```

## 📖 セットアップ手順

### STEP 1: リポジトリのクローン

```bash
git clone https://github.com/yourusername/Claude-Code-Communication.git
cd Claude-Code-Communication
```

### STEP 2: 環境構築と起動（推奨方法）

#### 🌟 方法A: ワンコマンド起動（最も簡単）

```bash
# 4人構成（基本チーム）で自動起動
./start-profile.sh --profile core --yes --assign

# または8人構成（フルチーム）で自動起動
./start-profile.sh --profile full --yes --assign
```

これだけで：
✅ tmuxセッション作成
✅ Claude起動
✅ 役割自動割り当て
✅ ブラウザ認証画面表示

#### 🔧 方法B: カスタム人数で起動

```bash
# 6人のチームで起動
./start-profile.sh --profile core --workers 6 --yes --assign

# 10人の大規模チームで起動
./start-profile.sh --profile full --workers 10 --yes --assign
```

### STEP 3: ブラウザ認証

各エージェントの画面でブラウザ認証を完了します：

```bash
# 画面を確認
tmux attach-session -t multiagent

# ペイン間の移動
- マウスクリック（推奨）
- Ctrl+b → 矢印キー

# 各ペインで認証を完了
```

### STEP 4: プロジェクト開始

```bash
# PRESIDENTに最初の指示を送信
./agent-send.sh president "あなたはpresidentです。
タスク管理アプリを作ってください。
要件：
- タスクの追加・削除・完了機能
- 優先度管理
- シンプルで美しいUI"
```

## 🖥️ 画面操作ガイド

### マウス操作（有効化済み）

| 操作 | 説明 |
|------|------|
| **クリック** | ペインを選択 |
| **スクロール** | ログを上下にスクロール |
| **ドラッグ** | テキスト選択（コピー可能） |
| **境界線ドラッグ** | ペインサイズ変更 |

### キーボードショートカット

| ショートカット | 機能 |
|----------------|------|
| `Ctrl+b → z` | 現在のペインを最大化/元に戻す |
| `Ctrl+b → g` | グリッドレイアウト |
| `Ctrl+b → f` | フォーカスレイアウト（boss1強調） |
| `Ctrl+b → v` | 縦分割レイアウト |
| `Ctrl+b → d` | tmuxから離脱（セッション継続） |
| `Ctrl+b → 矢印` | ペイン間移動 |

## 🎨 画面レイアウト管理

### 個別エージェント表示

```bash
# 特定のエージェントを全画面表示
./view-agent.sh boss1       # boss1のみ表示
./view-agent.sh worker1     # worker1のみ表示

# 利用可能なエージェント確認
./view-agent.sh --list

# 全員を均等表示に戻す
./view-agent.sh --all

# 自動巡回（5秒ごと）
./view-agent.sh --cycle
```

### レイアウト切り替え

```bash
# boss1を大きく表示（推奨）
./tmux-layout.sh focus

# グリッド表示
./tmux-layout.sh grid

# 縦並び（狭い画面向け）
./tmux-layout.sh vertical
```

## 💬 エージェント間通信

### メッセージ送信

```bash
# 基本構文
./agent-send.sh [宛先] "[メッセージ]"

# 例：boss1への指示
./agent-send.sh boss1 "進捗を報告してください"

# 例：worker1への質問
./agent-send.sh worker1 "UIの実装状況は？"

# 利用可能なエージェント一覧
./agent-send.sh --list
```

### 通信フローの例

```
1. PRESIDENT → boss1
   "ECサイトの検索機能を改善してください"
   ↓
2. boss1 → workers
   "worker1: UI改善"
   "worker2: API最適化"
   "worker3: テスト作成"
   ↓
3. workers → boss1
   "タスク完了しました"
   ↓
4. boss1 → PRESIDENT
   "プロジェクト完了報告"
```

## 📊 プロジェクト管理

### ステータス確認

```bash
# プロジェクト状態確認
./project-status.sh

# ダッシュボード起動（gum/fzf必要）
./dashboard.sh

# ログ監視
tail -f logs/send_log.txt
```

### Claude起動管理

```bash
# 起動状態確認
./start-claude.sh --check

# 全エージェント起動
./start-claude.sh

# 再起動
./start-claude.sh --restart

# 特定エージェントのみ
./start-claude.sh --workers  # workersのみ
./start-claude.sh --boss     # boss1のみ
```

## 🛠️ 役割別ガイド

### 各エージェントの役割

| エージェント | 役割 | 責任範囲 |
|-------------|------|----------|
| **PRESIDENT** | 統括責任者 | ビジョン策定、最終承認、品質保証 |
| **boss1** | チームリーダー | タスク分解、進捗管理、技術判断 |
| **worker1** | UI/UX担当 | デザイン、フロントエンド実装 |
| **worker2** | API担当 | バックエンド、データベース設計 |
| **worker3** | テスト担当 | 単体テスト、品質保証 |
| **worker4** | ドキュメント担当 | README、技術文書作成 |
| **worker5+** | 拡張メンバー | 性能改善、セキュリティ等 |

### スラッシュコマンド（Claude Code内）

```bash
# 役割別ガイドを表示
/sc:president:guide  # PRESIDENT向けガイド
/sc:boss1:guide     # boss1向けガイド
/sc:worker:guide    # worker向けガイド
```

## 🔧 トラブルシューティング

### よくある問題と解決方法

#### Q: エージェントが反応しない

```bash
# Claude起動状態を確認
./start-claude.sh --check

# 再起動
./start-claude.sh --restart
```

#### Q: マウスが効かない

```bash
# マウス設定を有効化
./enable-mouse.sh

# tmuxから離脱して再接続
Ctrl+b → d
tmux attach-session -t multiagent
```

#### Q: 画面が見づらい

```bash
# レイアウト変更
./tmux-layout.sh focus  # boss1を大きく
./view-agent.sh boss1    # boss1のみ表示
```

#### Q: 最初からやり直したい

```bash
# 全リセット
tmux kill-server
rm -rf ./tmp/*
./setup.sh
```

## 📁 ファイル構成

```
Claude-Code-Communication/
├── 📜 スクリプト
│   ├── setup.sh              # 環境構築
│   ├── start-profile.sh      # プロファイル起動
│   ├── agent-send.sh         # メッセージ送信
│   ├── start-claude.sh       # Claude起動管理
│   ├── view-agent.sh         # 個別表示
│   ├── tmux-layout.sh        # レイアウト切替
│   └── enable-mouse.sh       # マウス有効化
│
├── 📋 指示書
│   ├── instructions/
│   │   ├── president.md      # PRESIDENT指示書
│   │   ├── boss.md          # boss1指示書
│   │   └── worker.md        # worker指示書
│   │
│   └── .claude/commands/     # スラッシュコマンド定義
│
├── 📊 管理
│   ├── logs/send_log.txt    # 通信ログ
│   ├── tmp/                 # 一時ファイル
│   └── CLAUDE.md            # システム設定
│
└── 📚 ドキュメント
    ├── README.md            # 本ファイル
    └── quality-analysis-report.md  # 品質分析
```

## 🎯 実践例：TODOアプリ開発

```bash
# 1. 環境構築と起動
./start-profile.sh --profile core --yes --assign

# 2. 認証完了後、プロジェクト開始
./agent-send.sh president "あなたはpresidentです。
TODOアプリを開発してください。
要件：
- タスクのCRUD機能
- 優先度とカテゴリ管理
- レスポンシブデザイン
技術：React + Node.js
納期：2時間"

# 3. 進捗確認（30分後）
./agent-send.sh boss1 "進捗状況を報告してください"

# 4. 個別確認
./view-agent.sh worker1  # UI実装を確認
./view-agent.sh worker2  # API実装を確認

# 5. 完了確認
./project-status.sh
```

## 🤝 貢献

プルリクエストや改善提案を歓迎します！

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/AmazingFeature`)
3. 変更をコミット (`git commit -m 'Add AmazingFeature'`)
4. ブランチにプッシュ (`git push origin feature/AmazingFeature`)
5. プルリクエストを作成

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🙏 謝辞

- Claude AI by Anthropic
- tmux コミュニティ
- すべての貢献者の皆様

---

<div align="center">
<strong>🚀 Happy Multi-Agent Coding! 🚀</strong>
</div>