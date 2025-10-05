#!/bin/bash

# 🎯 詳細な実装計画を送信するためのスクリプト
# 大きな計画書やMermaid図を含む指示を送る場合に使用

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 引数チェック
if [ $# -lt 2 ]; then
    echo "使用方法: $0 <agent_name> <plan_file_path>"
    echo "例: $0 boss1 /workspace/tea-shop/IMPLEMENTATION_PLAN.md"
    exit 1
fi

AGENT="$1"
PLAN_FILE="$2"

# ファイルの存在確認
if [ ! -f "$PLAN_FILE" ]; then
    echo "❌ 計画ファイルが見つかりません: $PLAN_FILE"
    exit 1
fi

# ファイルサイズチェック（大きすぎる場合は分割送信を推奨）
FILE_SIZE=$(wc -c < "$PLAN_FILE")
if [ "$FILE_SIZE" -gt 10000 ]; then
    echo "⚠️ 警告: 計画ファイルが大きいです（${FILE_SIZE}バイト）"
    echo "分割送信を検討してください。"
    read -p "続行しますか？ (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# メッセージ作成
MESSAGE="あなたは${AGENT}です。

詳細な実装計画を作成しました。以下のファイルを確認してください：
${PLAN_FILE}

【重要な指示】
1. 計画書を最初に完全に読み込んでください
2. ファイルパスとリファレンスを信頼してください
3. 再検証は不要です（計画通りに実装）
4. 必要な場合のみ追加調査を行ってください
5. すべての提案されたファイル変更を実装してください

計画に従って効率的に実装を進め、完了後に報告してください。"

echo "📤 ${AGENT}に詳細計画を送信中..."
echo "📄 計画ファイル: $PLAN_FILE"
echo "────────────────────────────────────────"

# agent-send.shを使って送信
"$SCRIPT_DIR/agent-send.sh" "$AGENT" "$MESSAGE"

echo ""
echo "✅ 詳細計画を送信しました"
echo ""
echo "💡 次のステップ:"
echo "  1. ${AGENT}が計画を読み込むまで待つ"
echo "  2. 実装の進捗を ./dashboard.sh で確認"
echo "  3. 必要に応じて追加指示を送信"