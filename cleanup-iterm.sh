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
echo "🚀 次のコマンドでマルチスペースシステムを起動:"
echo "   ./launch-multi-space.sh --management-layout tabs --workers-layout tabs --reviewers-layout tabs"
echo ""
echo "📋 起動後の構成:"
echo "   Control + 1 : 👑 統括グループ (PRESIDENT + ARCHITECT)"
echo "   Control + 2 : 🛠️ 実装グループ (8 WORKERS)"
echo "   Control + 3 : 🔍 レビューグループ (2 REVIEWERS)"