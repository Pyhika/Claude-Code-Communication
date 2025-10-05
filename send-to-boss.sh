#!/bin/bash

# 🚀 簡単にboss1に指示を送るためのヘルパースクリプト
# プレジデントがClaudeで動作している時に使いやすくする

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# メッセージが引数で渡されていない場合
if [ $# -eq 0 ]; then
    echo "📝 boss1への指示を入力してください（Ctrl+Dで送信）:"
    MESSAGE=$(cat)
else
    MESSAGE="$*"
fi

# メッセージが空の場合はエラー
if [ -z "$MESSAGE" ]; then
    echo "❌ メッセージが空です"
    exit 1
fi

# 自動的に「あなたはboss1です」を追加
FULL_MESSAGE="あなたはboss1です。$MESSAGE"

echo "📤 boss1に送信中..."
echo "────────────────────"
echo "$FULL_MESSAGE"
echo "────────────────────"

# agent-send.shを実行
"$SCRIPT_DIR/agent-send.sh" boss1 "$FULL_MESSAGE"

echo ""
echo "✅ 送信完了"
echo "💡 ヒント: ./dashboard.sh で状態を確認できます"