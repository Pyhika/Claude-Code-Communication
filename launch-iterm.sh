#!/bin/bash

# 🖥️ 完全自動化システム iTerm2 起動スクリプト (1:1:8:2 構成)
# PRESIDENT + ARCHITECT + 8 WORKERS + 2 REVIEWERS = 12エージェント構成

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# デフォルト設定
LAYOUT="auto"  # auto, grid, tabs, windows
NUM_WORKERS=8
WINDOW_WIDTH=140
WINDOW_HEIGHT=45

usage() {
  cat << EOF
🏗️ 完全自動化システム iTerm2 起動スクリプト (1:1:8:2構成)

📋 使い方:
  $0 [--layout LAYOUT] [--workers N]

🎨 レイアウトオプション:
  auto     - 自動最適レイアウト（推奨）
  grid     - 3x4グリッド配置（12エージェント用）
  tabs     - 1つのウィンドウに複数タブ
  windows  - 全エージェントを個別ウィンドウで開く

🤖 エージェント構成:
  👑 PRESIDENT         - AI司令塔
  🏗️ ARCHITECT         - 設計統括
  🎨 WORKER1 (FRONTEND)  - フロントエンド自動AI
  ⚙️ WORKER2 (BACKEND)   - バックエンド自動AI
  🗄️ WORKER3 (DATABASE)  - データベース自動AI
  🔒 WORKER4 (SECURITY)  - セキュリティ自動AI
  🧪 WORKER5 (TESTING)   - テスト自動AI
  🚀 WORKER6 (DEPLOY)    - デプロイ自動AI
  📚 WORKER7 (DOCS)      - ドキュメント自動AI
  🔍 WORKER8 (QA)        - 品質保証自動AI
  🔍 REVIEWER_A          - 品質レビューAI
  🛡️ REVIEWER_B          - セキュリティレビューAI

📝 例:
  # 自動レイアウトで完全システム起動
  $0

  # グリッドレイアウトで起動
  $0 --layout grid

  # 個別ウィンドウで起動
  $0 --layout windows
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    --layout|-l)
      LAYOUT="$2"; shift 2;;
    --workers|-w)
      NUM_WORKERS="$2"; shift 2;;
    --help|-h)
      usage; exit 0;;
    *)
      echo "❌ 不明なオプション: $1"; usage; exit 1;;
  esac
done

echo "🚀 完全自動化システム起動中..."
echo "📐 レイアウト: $LAYOUT"
echo "👥 ワーカー数: $NUM_WORKERS"
echo ""

# Apple Scriptの共通部分
create_window_with_agent() {
  local agent_name="$1"
  local window_name="$2"
  local position_info="$3"

cat << EOF
tell application "iTerm2"
    set newWindow to (create window with default profile)
    tell current session of newWindow
        write text "cd '$SCRIPT_DIR'"
        write text "'$SCRIPT_DIR/agent-identity.sh' $agent_name"
        delay 1
        write text "claude --dangerously-skip-permissions"
    end tell
    set name of current session of newWindow to "$window_name"
    $position_info
end tell
EOF
}

create_tab_with_agent() {
  local agent_name="$1"
  local tab_name="$2"

cat << EOF
tell application "iTerm2"
    tell current window
        set newTab to (create tab with default profile)
        tell current session of newTab
            write text "cd '$SCRIPT_DIR'"
            write text "'$SCRIPT_DIR/agent-identity.sh' $agent_name"
            delay 1
            write text "claude --dangerously-skip-permissions"
        end tell
        set name of current session of newTab to "$tab_name"
    end tell
end tell
EOF
}

# 自動レイアウト決定
if [ "$LAYOUT" = "auto" ]; then
    if [ $NUM_WORKERS -le 4 ]; then
        LAYOUT="tabs"
    elif [ $NUM_WORKERS -le 8 ]; then
        LAYOUT="grid"
    else
        LAYOUT="windows"
    fi
    echo "🎯 自動選択レイアウト: $LAYOUT"
fi

case "$LAYOUT" in
    "grid")
        echo "📊 グリッドレイアウトで起動中..."

        # 画面サイズに応じた座標計算（標準的なMacBook解像度対応）
        GRID_WIDTH=350
        GRID_HEIGHT=200

        # Step 1: PRESIDENT (左上)
        osascript << EOF
$(create_window_with_agent "president" "👑 PRESIDENT" "set bounds of current window to {50, 50, 400, 250}")
EOF

        sleep 2

        # Step 2: ARCHITECT (中上)
        osascript << EOF
$(create_window_with_agent "architect" "🏗️ ARCHITECT" "set bounds of current window to {450, 50, 800, 250}")
EOF

        sleep 2

        # Step 3: REVIEWER_A (左下)
        osascript << EOF
$(create_window_with_agent "reviewer_a" "🔍 REVIEWER_A" "set bounds of current window to {50, 280, 400, 480}")
EOF

        sleep 2

        # Step 4: REVIEWER_B (中下)
        osascript << EOF
$(create_window_with_agent "reviewer_b" "🛡️ REVIEWER_B" "set bounds of current window to {450, 280, 800, 480}")
EOF

        sleep 2

        # Step 5: WORKERS (右側2x4グリッド) - より適切な座標
        declare -a workers=(
            "worker1:🎨 FRONTEND:850:50:1200:200"
            "worker2:⚙️ BACKEND:1250:50:1600:200"
            "worker3:🗄️ DATABASE:850:220:1200:370"
            "worker4:🔒 SECURITY:1250:220:1600:370"
            "worker5:🧪 TESTING:850:390:1200:540"
            "worker6:🚀 DEPLOY:1250:390:1600:540"
            "worker7:📚 DOCS:850:560:1200:710"
            "worker8:🔍 QA:1250:560:1600:710"
        )

        for i in $(seq 1 $NUM_WORKERS); do
            if [ $i -le 8 ]; then
                IFS=':' read -ra worker_info <<< "${workers[$((i-1))]}"
                worker_name="${worker_info[0]}"
                window_title="${worker_info[1]}"
                x1="${worker_info[2]}"
                y1="${worker_info[3]}"
                x2="${worker_info[4]}"
                y2="${worker_info[5]}"

                osascript << EOF
$(create_window_with_agent "$worker_name" "$window_title" "set bounds of current window to {$x1, $y1, $x2, $y2}")
EOF
                sleep 1.5
            fi
        done
        ;;

    "tabs")
        echo "📑 タブレイアウトで起動中..."

        # Step 1: 最初のウィンドウでPRESIDENT
        osascript << EOF
$(create_window_with_agent "president" "👑 PRESIDENT" "")
EOF

        sleep 2

        # Step 2: 同じウィンドウに他のエージェントをタブで追加
        agents=("architect" "reviewer_a" "reviewer_b" "worker1" "worker2" "worker3" "worker4" "worker5" "worker6" "worker7" "worker8")
        names=("🏗️ ARCHITECT" "🔍 REVIEWER_A" "🛡️ REVIEWER_B" "🎨 FRONTEND" "⚙️ BACKEND" "🗄️ DATABASE" "🔒 SECURITY" "🧪 TESTING" "🚀 DEPLOY" "📚 DOCS" "🔍 QA")

        for i in "${!agents[@]}"; do
            if [ $i -lt $((NUM_WORKERS + 3)) ]; then  # +3 for architect and 2 reviewers
                agent_name="${agents[$i]}"
                tab_name="${names[$i]}"

                osascript << EOF
$(create_tab_with_agent "$agent_name" "$tab_name")
EOF
                sleep 1.5
            fi
        done
        ;;

    "windows")
        echo "🪟 個別ウィンドウレイアウトで起動中..."

        agents=("president" "architect" "reviewer_a" "reviewer_b" "worker1" "worker2" "worker3" "worker4" "worker5" "worker6" "worker7" "worker8")
        names=("👑 PRESIDENT" "🏗️ ARCHITECT" "🔍 REVIEWER_A" "🛡️ REVIEWER_B" "🎨 FRONTEND" "⚙️ BACKEND" "🗄️ DATABASE" "🔒 SECURITY" "🧪 TESTING" "🚀 DEPLOY" "📚 DOCS" "🔍 QA")

        for i in "${!agents[@]}"; do
            if [ $i -lt $((NUM_WORKERS + 4)) ]; then  # +4 for president, architect, and 2 reviewers
                agent_name="${agents[$i]}"
                window_name="${names[$i]}"

                osascript << EOF
$(create_window_with_agent "$agent_name" "$window_name" "")
EOF
                sleep 2
            fi
        done
        ;;

    *)
        echo "❌ サポートされていないレイアウト: $LAYOUT"
        usage
        exit 1
        ;;
esac

echo ""
echo "✅ 完全自動化システム起動完了！"
echo ""
echo "🎯 次のステップ:"
echo "1. 各ウィンドウ・タブで認証を完了してください"
echo "2. PRESIDENT で要件を入力してプロジェクトを開始"
echo "3. システムが自動的に設計→実装→レビュー→デプロイを実行"
echo ""
echo "💡 便利なコマンド:"
echo "  ./review-report-system.sh check [project_path]  - Wチェック実行"
echo "  ./agent-status.sh  - 現在のエージェント状態確認"
echo "  ./show-agents.sh   - エージェント構成確認"
echo ""
echo "🏗️ 完全自動化開発システムが稼働中です！"