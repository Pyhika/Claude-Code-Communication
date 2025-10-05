#!/bin/bash

# 🚀 マルチエージェントシステム完全起動スクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 マルチエージェントシステム起動中..."
echo "========================================"
echo ""

# ステップ1: クリーンアップ
echo "【ステップ1】既存環境のクリーンアップ"
if command -v cleanup-iterm.sh &> /dev/null; then
    ./cleanup-iterm.sh
else
    echo "⚠️ cleanup-iterm.sh が見つかりません（スキップ）"
fi
echo ""

# ステップ2: グループ起動
echo "【ステップ2】全グループ起動"

# 起動方法を選択
if [[ "$1" == "--multi-space" ]]; then
    echo "  📐 マルチスペースモードで起動..."
    ./launch-multi-space.sh \
        --management-layout tabs \
        --workers-layout tabs \
        --reviewers-layout tabs
else
    echo "  📐 グループ別モードで起動..."

    # 統括グループ
    echo "  👑 統括グループ起動中..."
    ./launch-by-group.sh management --layout tabs
    sleep 2

    # 実装グループ
    echo "  👷 実装グループ起動中..."
    ./launch-by-group.sh workers --layout tabs
    sleep 2

    # レビューグループ
    echo "  🔍 レビューグループ起動中..."
    ./launch-by-group.sh reviewers --layout tabs
    sleep 2
fi

echo "✅ 全グループ起動完了"
echo ""

# ステップ3: メッセージキュー初期化
echo "【ステップ3】メッセージキュー初期化"
./message-queue.sh init
echo ""

# ステップ4: 応答監視開始
echo "【ステップ4】応答監視システム起動"
./response-monitor.sh start
echo ""

# ステップ5: 起動確認
echo "【ステップ5】起動確認"
echo ""
echo "📊 tmuxセッション:"
tmux list-sessions 2>/dev/null || echo "⚠️ tmuxセッションが見つかりません"
echo ""

echo "📊 システム状態:"
./team-workflow.sh status
echo ""

# 完了
echo "========================================"
echo "✅ マルチエージェントシステム起動完了！"
echo "========================================"
echo ""
echo "💡 便利なコマンド:"
echo "  ./agent-send.sh --list                  # エージェント一覧"
echo "  ./team-workflow.sh start \"要件\"         # ワークフロー開始"
echo "  ./message-queue.sh stats                # メッセージ統計"
echo "  ./response-monitor.sh log <AGENT>       # 応答ログ確認"
echo "  ./team-workflow.sh status               # システム状態確認"
echo ""
echo "📖 詳細なガイド:"
echo "  cat TEAM_COMMUNICATION.md               # 通信システムガイド"
echo "  cat CLAUDE.md                           # システム概要"
echo ""
