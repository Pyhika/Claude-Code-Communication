#!/bin/bash

# 🏗️ 1:1:8:2構成グループ別起動スクリプト
# 各グループを独立したスクリーンで起動

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
  cat << EOF
🏗️ グループ別完全自動化システム起動

📋 使い方:
  $0 [GROUP] [OPTIONS]

🎯 グループオプション:
  all        - 全グループを順次起動（推奨）
  management - 統括グループ（PRESIDENT + ARCHITECT）
  workers    - 実装グループ（8 WORKERS）
  reviewers  - レビューグループ（2 REVIEWERS）

🎨 レイアウトオプション:
  --layout [tabs|windows|split]

📝 例:
  # 全グループを順次起動
  $0 all

  # 統括グループのみ起動
  $0 management --layout tabs

  # ワーカーグループのみ起動
  $0 workers --layout split

  # レビューグループのみ起動
  $0 reviewers --layout tabs

🖥️ スクリーン配置:
  スクリーン1: 統括グループ（PRESIDENT + ARCHITECT）
  スクリーン2: 実装グループ（8 WORKERS）
  スクリーン3: レビューグループ（2 REVIEWERS）
EOF
}

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

# 統括グループ起動（PRESIDENT + ARCHITECT）
launch_management() {
    local layout="${1:-tabs}"
    echo "👑 統括グループ起動中..."

    case "$layout" in
        "tabs")
            # 最初のウィンドウでPRESIDENT
            osascript << EOF
$(create_window_with_agent "president" "👑 PRESIDENT" "set bounds of current window to {100, 100, 800, 400}")
EOF
            sleep 2

            # 同じウィンドウにARCHITECTをタブで追加
            osascript << EOF
$(create_tab_with_agent "architect" "🏗️ ARCHITECT")
EOF
            ;;
        "windows")
            # PRESIDENT
            osascript << EOF
$(create_window_with_agent "president" "👑 PRESIDENT" "set bounds of current window to {100, 100, 600, 350}")
EOF
            sleep 2

            # ARCHITECT
            osascript << EOF
$(create_window_with_agent "architect" "🏗️ ARCHITECT" "set bounds of current window to {700, 100, 1300, 350}")
EOF
            ;;
        "split")
            # 1つのウィンドウを分割
            osascript << EOF
$(create_window_with_agent "president" "👑 PRESIDENT" "set bounds of current window to {100, 100, 800, 500}")
EOF
            sleep 2

            osascript << EOF
tell application "iTerm2"
    tell current window
        tell current session
            split vertically with default profile
        end tell
        tell last session
            write text "cd '$SCRIPT_DIR'"
            write text "'$SCRIPT_DIR/agent-identity.sh' architect"
            delay 1
            write text "claude --dangerously-skip-permissions"
            set name to "🏗️ ARCHITECT"
        end tell
    end tell
end tell
EOF
            ;;
    esac

    echo "✅ 統括グループ起動完了"
}

# 実装グループ起動（8 WORKERS）
launch_workers() {
    local layout="${1:-tabs}"
    echo "🛠️ 実装グループ起動中..."

    declare -a workers=(
        "worker1:🎨 FRONTEND"
        "worker2:⚙️ BACKEND"
        "worker3:🗄️ DATABASE"
        "worker4:🔒 SECURITY"
        "worker5:🧪 TESTING"
        "worker6:🚀 DEPLOY"
        "worker7:📚 DOCS"
        "worker8:🔍 QA"
    )

    case "$layout" in
        "tabs")
            # 最初のウィンドウでWORKER1
            IFS=':' read -ra worker_info <<< "${workers[0]}"
            osascript << EOF
$(create_window_with_agent "${worker_info[0]}" "${worker_info[1]}" "set bounds of current window to {900, 100, 1600, 600}")
EOF
            sleep 2

            # 残りのWORKERsをタブで追加
            for i in $(seq 1 7); do
                IFS=':' read -ra worker_info <<< "${workers[$i]}"
                osascript << EOF
$(create_tab_with_agent "${worker_info[0]}" "${worker_info[1]}")
EOF
                sleep 1
            done
            ;;
        "windows")
            # 各WORKERを個別ウィンドウで起動（2x4グリッド配置）
            for i in $(seq 0 7); do
                IFS=':' read -ra worker_info <<< "${workers[$i]}"
                local row=$((i / 4))
                local col=$((i % 4))
                local x=$((900 + col * 200))
                local y=$((100 + row * 250))

                osascript << EOF
$(create_window_with_agent "${worker_info[0]}" "${worker_info[1]}" "set bounds of current window to {$x, $y, $((x + 190)), $((y + 240))}")
EOF
                sleep 1
            done
            ;;
        "split")
            # 2x4分割レイアウト
            osascript << EOF
$(create_window_with_agent "worker1" "🎨 FRONTEND" "set bounds of current window to {900, 100, 1600, 700}")
EOF
            sleep 2

            # 段階的に分割（簡略化版）
            for i in $(seq 1 7); do
                IFS=':' read -ra worker_info <<< "${workers[$i]}"
                osascript << EOF
tell application "iTerm2"
    tell current window
        tell current session
            split horizontally with default profile
        end tell
        tell last session
            write text "cd '$SCRIPT_DIR'"
            write text "'$SCRIPT_DIR/agent-identity.sh' ${worker_info[0]}"
            delay 1
            write text "claude --dangerously-skip-permissions"
            set name to "${worker_info[1]}"
        end tell
    end tell
end tell
EOF
                sleep 1
            done
            ;;
    esac

    echo "✅ 実装グループ起動完了"
}

# レビューグループ起動（2 REVIEWERS）
launch_reviewers() {
    local layout="${1:-tabs}"
    echo "🔍 レビューグループ起動中..."

    case "$layout" in
        "tabs")
            # REVIEWER_A
            osascript << EOF
$(create_window_with_agent "reviewer_a" "🔍 REVIEWER_A" "set bounds of current window to {100, 400, 800, 700}")
EOF
            sleep 2

            # REVIEWER_B
            osascript << EOF
$(create_tab_with_agent "reviewer_b" "🛡️ REVIEWER_B")
EOF
            ;;
        "windows")
            # REVIEWER_A
            osascript << EOF
$(create_window_with_agent "reviewer_a" "🔍 REVIEWER_A" "set bounds of current window to {100, 400, 600, 650}")
EOF
            sleep 2

            # REVIEWER_B
            osascript << EOF
$(create_window_with_agent "reviewer_b" "🛡️ REVIEWER_B" "set bounds of current window to {700, 400, 1300, 650}")
EOF
            ;;
        "split")
            # 1つのウィンドウを分割
            osascript << EOF
$(create_window_with_agent "reviewer_a" "🔍 REVIEWER_A" "set bounds of current window to {100, 400, 800, 700}")
EOF
            sleep 2

            osascript << EOF
tell application "iTerm2"
    tell current window
        tell current session
            split vertically with default profile
        end tell
        tell last session
            write text "cd '$SCRIPT_DIR'"
            write text "'$SCRIPT_DIR/agent-identity.sh' reviewer_b"
            delay 1
            write text "claude --dangerously-skip-permissions"
            set name to "🛡️ REVIEWER_B"
        end tell
    end tell
end tell
EOF
            ;;
    esac

    echo "✅ レビューグループ起動完了"
}

# 引数解析
GROUP=""
LAYOUT="tabs"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --layout|-l)
      LAYOUT="$2"; shift 2;;
    --help|-h)
      usage; exit 0;;
    all|management|workers|reviewers)
      GROUP="$1"; shift;;
    *)
      echo "❌ 不明なオプション: $1"; usage; exit 1;;
  esac
done

if [ -z "$GROUP" ]; then
    echo "❌ グループを指定してください"
    usage
    exit 1
fi

echo "🚀 グループ別完全自動化システム起動中..."
echo "📐 グループ: $GROUP"
echo "📐 レイアウト: $LAYOUT"
echo ""

# グループ別実行
case "$GROUP" in
    "all")
        echo "🎯 全グループ起動（推奨順序）"
        echo ""
        launch_management "$LAYOUT"
        sleep 3
        launch_workers "$LAYOUT"
        sleep 3
        launch_reviewers "$LAYOUT"
        echo ""
        echo "✅ 全グループ起動完了！"
        ;;
    "management")
        launch_management "$LAYOUT"
        ;;
    "workers")
        launch_workers "$LAYOUT"
        ;;
    "reviewers")
        launch_reviewers "$LAYOUT"
        ;;
    *)
        echo "❌ 無効なグループ: $GROUP"
        usage
        exit 1
        ;;
esac

echo ""
echo "🎯 各グループでの認証を完了してください"
echo ""
echo "💡 便利なコマンド:"
echo "  ./agent-status.sh                         - エージェント状態確認"
echo "  ./review-report-system.sh check [path]    - Wチェック実行"
echo "  ./cleanup-iterm.sh                        - 全ウィンドウクリーンアップ"
echo ""
echo "🏗️ グループ別完全自動化システム稼働中！"