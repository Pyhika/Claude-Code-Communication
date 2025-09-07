# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要
複数のAIエージェントが協調して開発を行うマルチエージェント通信システム。tmuxセッションを使用して各エージェントを独立したペインで動作させ、相互にメッセージを送信しながらプロジェクトを遂行する。

## システムアーキテクチャ

### エージェント構成
- **PRESIDENT** (tmux session: president): プロジェクト統括責任者
  - 要件定義、優先順位決定、品質承認
- **boss1** (tmux: multiagent:0.0): テックリード
  - タスク分解、技術判断、進捗管理
- **worker1-N** (tmux: multiagent:0.1-N): 実行担当
  - 実装、テスト、ドキュメント作成

### 通信フロー
```
PRESIDENT → boss1 → workers → boss1 → PRESIDENT
```

### 作業ディレクトリ
- 共通作業場所: `/workspace/[プロジェクト名]`
- 成果物管理: 全エージェントが同じディレクトリで作業

## 開発コマンド

### 環境構築・起動
```bash
# 環境セットアップ（tmuxセッション作成）
./setup.sh                              # デフォルト3ワーカー
NUM_WORKERS=5 ./setup.sh               # 5ワーカーで構築

# クイック起動（プロファイル使用）
./start-profile.sh --profile core --yes --assign      # 4人構成
./start-profile.sh --profile full --yes --assign      # 8人構成
./start-profile.sh --profile core --workers 6 --yes   # カスタム人数

# 個別起動
./launch-agents.sh -y                  # 全エージェント起動
```

### エージェント間通信
```bash
# メッセージ送信
./agent-send.sh [エージェント名] "[メッセージ]"
./agent-send.sh president "プロジェクト開始"
./agent-send.sh boss1 "タスク割り当て"
./agent-send.sh worker1 "実装完了"

# 利用可能エージェント確認
./agent-send.sh --list
```

### 監視・管理
```bash
# プロジェクトステータス確認
./project-status.sh

# ダッシュボード起動（要: gum or fzf）
./dashboard.sh

# tmuxセッション確認
tmux list-sessions
tmux attach-session -t president       # PRESIDENT画面
tmux attach-session -t multiagent      # boss1+workers画面
```

## 役割別ガイド（/sc コマンド）
Claude Code内で以下のスラッシュコマンドで役割別ガイドを参照:
- `/sc:president:guide` - PRESIDENT向け実践ガイド
- `/sc:boss1:guide` - boss1向けタスク管理ガイド
- `/sc:worker:guide` - worker向け実装ガイド

## 重要な実装詳細

### tmuxペイン管理
- multiagentセッション: 左ペイン(0.0)がboss1、右ペイン(0.1〜)がworkers
- 動的スケーリング: NUM_WORKERSで可変（1〜無制限）
- ペイン番号とエージェント名の対応は固定

### ログ・状態管理
- 送信ログ: `logs/send_log.txt`
- worker完了フラグ: `tmp/worker[N]_done.txt`
- マスタータスク: `/workspace/[プロジェクト名]/MASTER_TASKS.md`

### 環境変数
```bash
NUM_WORKERS      # ワーカー数（デフォルト: 3）
AGENT_CMD        # 起動コマンド（デフォルト: claude）
AGENT_ARGS       # 起動引数（デフォルト: --dangerously-skip-permissions）
TMUX_WINDOW_WIDTH  # ウィンドウ幅（デフォルト: 240）
TMUX_WINDOW_HEIGHT # ウィンドウ高さ（デフォルト: 80）
```

## トラブルシューティング

### セッション関連
```bash
# セッション強制削除
tmux kill-session -t multiagent
tmux kill-session -t president

# 全セッションリセット
tmux kill-server
```

### 認証問題
- 各エージェントでブラウザ認証が必要
- 認証前のメッセージ送信は失敗する
- `--dangerously-skip-permissions`は開発環境限定

### メッセージ送信エラー
- ターゲットペインの存在確認: `tmux list-panes -a`
- セッション起動確認: `tmux has-session -t [session]`

## あなたの役割の確認
エージェントとして動作する場合、以下のドキュメントを参照:
- **PRESIDENT**: `instructions/president.md`
- **boss1**: `instructions/boss.md`  
- **worker**: `instructions/worker.md` 