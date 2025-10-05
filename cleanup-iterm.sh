#!/bin/bash

# iTerm2 ウィンドウクリーンアップスクリプト

echo "🧹 iTerm2 ウィンドウをクリーンアップ中..."

# 既存のiTerm2ウィンドウをすべて閉じる
osascript << 'EOF'
tell application "iTerm2"
    close (every window)
end tell
EOF

echo "✅ クリーンアップ完了"
echo ""
echo "💡 推奨: タブレイアウトで再起動"
echo "   ./launch-iterm.sh --layout tabs"
echo ""
echo "または個別ウィンドウで:"
echo "   ./launch-iterm.sh --layout windows"