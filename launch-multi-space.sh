#!/bin/bash

# 🖥️ マルチスペース起動スクリプト
# 各グループを異なるmacOSスペース（デスクトップ）で起動

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
  cat << EOF
🖥️ マルチスペース完全自動化システム起動

📋 使い方:
  $0 [OPTIONS]

🎯 スペース配置:
  スペース1: 👑 統括グループ（PRESIDENT + ARCHITECT）
  スペース2: 🛠️ 実装グループ（8 WORKERS）
  スペース3: 🔍 レビューグループ（2 REVIEWERS）

🎨 各スペースでのレイアウト:
  --management-layout [tabs|windows|split]  - 統括グループレイアウト
  --workers-layout [tabs|windows|split]     - 実装グループレイアウト
  --reviewers-layout [tabs|windows|split]   - レビューグループレイアウト

📝 例:
  # デフォルト（全てタブレイアウト）
  $0

  # カスタムレイアウト
  $0 --management-layout tabs --workers-layout split --reviewers-layout tabs

🚀 スペース操作:
  Control + → : 次のスペース
  Control + ← : 前のスペース
  Control + 1 : スペース1（統括）
  Control + 2 : スペース2（実装）
  Control + 3 : スペース3（レビュー）
EOF
}

create_space_and_launch() {
    local space_number="$1"
    local group_name="$2"
    local layout="$3"

    echo "🖥️ スペース$space_number に $group_name を起動中..."

    # 新しいスペースを作成して移動
    osascript << EOF
tell application "Mission Control"
    activate
    delay 1
end tell

tell application "System Events"
    key code 18 using {control down}  -- Control + 1でスペース作成
    delay 2
end tell
EOF

    # そのスペースでグループを起動
    case "$group_name" in
        "management")
            "$SCRIPT_DIR/launch-by-group.sh" management --layout "$layout"
            ;;
        "workers")
            "$SCRIPT_DIR/launch-by-group.sh" workers --layout "$layout"
            ;;
        "reviewers")
            "$SCRIPT_DIR/launch-by-group.sh" reviewers --layout "$layout"
            ;;
    esac

    sleep 2
    echo "✅ スペース$space_number ($group_name) 起動完了"
}

# 引数解析
MANAGEMENT_LAYOUT="tabs"
WORKERS_LAYOUT="tabs"
REVIEWERS_LAYOUT="tabs"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --management-layout)
      MANAGEMENT_LAYOUT="$2"; shift 2;;
    --workers-layout)
      WORKERS_LAYOUT="$2"; shift 2;;
    --reviewers-layout)
      REVIEWERS_LAYOUT="$2"; shift 2;;
    --help|-h)
      usage; exit 0;;
    *)
      echo "❌ 不明なオプション: $1"; usage; exit 1;;
  esac
done

echo "🚀 マルチスペース完全自動化システム起動中..."
echo ""
echo "📐 レイアウト設定:"
echo "  統括グループ: $MANAGEMENT_LAYOUT"
echo "  実装グループ: $WORKERS_LAYOUT"
echo "  レビューグループ: $REVIEWERS_LAYOUT"
echo ""

# 既存のiTermウィンドウをクリーンアップ
echo "🧹 既存ウィンドウクリーンアップ..."
"$SCRIPT_DIR/cleanup-iterm.sh" > /dev/null 2>&1

# スペース1: 統括グループ
echo "🎯 スペース1: 統括グループ起動..."
"$SCRIPT_DIR/launch-by-group.sh" management --layout "$MANAGEMENT_LAYOUT"

sleep 3

# スペース2: 実装グループ
echo "🎯 スペース2: 実装グループ起動..."
"$SCRIPT_DIR/launch-by-group.sh" workers --layout "$WORKERS_LAYOUT"

sleep 3

# スペース3: レビューグループ
echo "🎯 スペース3: レビューグループ起動..."
"$SCRIPT_DIR/launch-by-group.sh" reviewers --layout "$REVIEWERS_LAYOUT"

echo ""
echo "✅ マルチスペース起動完了！"
echo ""
echo "🖥️ スペース配置:"
echo "  Control + 1 または Control + ← : 👑 統括（PRESIDENT + ARCHITECT）"
echo "  Control + 2                   : 🛠️ 実装（8 WORKERS）"
echo "  Control + 3 または Control + → : 🔍 レビュー（2 REVIEWERS）"
echo ""
echo "🎯 各スペースで認証を完了してください:"
echo "1. スペース1でPRESIDENT認証 → 要件入力"
echo "2. スペース2で各WORKER認証 → 自動実装確認"
echo "3. スペース3でREVIEWER認証 → 品質チェック確認"
echo ""
echo "💡 便利なコマンド:"
echo "  ./agent-status.sh                         - 全エージェント状態確認"
echo "  ./review-report-system.sh check [path]    - Wチェック実行"
echo ""
echo "🏗️ マルチスペース完全自動化システム稼働中！"