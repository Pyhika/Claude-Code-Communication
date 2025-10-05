#!/bin/bash

# 🏗️ 1:1:8:2構成グループ別起動スクリプト
# 各グループを独立したスクリーンで起動

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 定数読み込み
source "$SCRIPT_DIR/const/agents.sh"

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
            local pres_icon=$(get_agent_icon "$AGENT_PRESIDENT")
            osascript << EOF
$(create_window_with_agent "$AGENT_PRESIDENT" "$pres_icon $AGENT_PRESIDENT" "set bounds of current window to {100, 100, 800, 400}")
EOF
            sleep 2

            # 同じウィンドウにARCHITECTをタブで追加
            local arch_icon=$(get_agent_icon "$AGENT_ARCHITECT")
            osascript << EOF
$(create_tab_with_agent "$AGENT_ARCHITECT" "$arch_icon $AGENT_ARCHITECT")
EOF
            ;;
        "windows")
            # PRESIDENT
            local pres_icon=$(get_agent_icon "$AGENT_PRESIDENT")
            osascript << EOF
$(create_window_with_agent "$AGENT_PRESIDENT" "$pres_icon $AGENT_PRESIDENT" "set bounds of current window to {100, 100, 600, 350}")
EOF
            sleep 2

            # ARCHITECT
            local arch_icon=$(get_agent_icon "$AGENT_ARCHITECT")
            osascript << EOF
$(create_window_with_agent "$AGENT_ARCHITECT" "$arch_icon $AGENT_ARCHITECT" "set bounds of current window to {700, 100, 1300, 350}")
EOF
            ;;
        "split")
            # 1つのウィンドウを分割
            local pres_icon=$(get_agent_icon "$AGENT_PRESIDENT")
            osascript << EOF
$(create_window_with_agent "$AGENT_PRESIDENT" "$pres_icon $AGENT_PRESIDENT" "set bounds of current window to {100, 100, 800, 500}")
EOF
            sleep 2

            local arch_icon=$(get_agent_icon "$AGENT_ARCHITECT")
            osascript << EOF
tell application "iTerm2"
    tell current window
        tell current session
            split vertically with default profile
        end tell
        tell last session
            write text "cd '$SCRIPT_DIR'"
            write text "'$SCRIPT_DIR/agent-identity.sh' $AGENT_ARCHITECT"
            delay 1
            write text "claude --dangerously-skip-permissions"
            set name to "$arch_icon $AGENT_ARCHITECT"
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

    # 定数から実装グループを構築
    declare -a workers=()
    for agent in "${WORKER_AGENTS[@]}"; do
        local icon=$(get_agent_icon "$agent")
        workers+=("$agent:$icon $agent")
    done

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
            IFS=':' read -ra first_worker <<< "${workers[0]}"
            osascript << EOF
$(create_window_with_agent "${first_worker[0]}" "${first_worker[1]}" "set bounds of current window to {900, 100, 1600, 700}")
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

    local rev_a_icon=$(get_agent_icon "$AGENT_REVIEWER_A")
    local rev_b_icon=$(get_agent_icon "$AGENT_REVIEWER_B")
    local rev_a_internal=$(get_internal_name "$AGENT_REVIEWER_A")
    local rev_b_internal=$(get_internal_name "$AGENT_REVIEWER_B")

    # tmuxセッション作成
    echo "  📦 tmuxセッション作成中..."

    # REVIEWER_A tmuxセッション
    tmux new-session -d -s "$rev_a_internal" -c "$SCRIPT_DIR"
    tmux send-keys -t "$rev_a_internal" "./agent-identity.sh $AGENT_REVIEWER_A" C-m
    sleep 2
    tmux send-keys -t "$rev_a_internal" "claude --dangerously-skip-permissions" C-m

    # REVIEWER_B tmuxセッション
    tmux new-session -d -s "$rev_b_internal" -c "$SCRIPT_DIR"
    tmux send-keys -t "$rev_b_internal" "./agent-identity.sh $AGENT_REVIEWER_B" C-m
    sleep 2
    tmux send-keys -t "$rev_b_internal" "claude --dangerously-skip-permissions" C-m

    # iTerm2ウィンドウも作成（オプション）
    case "$layout" in
        "tabs")
            # REVIEWER_A
            osascript << EOF
$(create_window_with_agent "$AGENT_REVIEWER_A" "$rev_a_icon $AGENT_REVIEWER_A" "set bounds of current window to {100, 400, 800, 700}")
EOF
            sleep 2

            # REVIEWER_B
            osascript << EOF
$(create_tab_with_agent "$AGENT_REVIEWER_B" "$rev_b_icon $AGENT_REVIEWER_B")
EOF
            ;;
        "windows")
            # REVIEWER_A
            osascript << EOF
$(create_window_with_agent "$AGENT_REVIEWER_A" "$rev_a_icon $AGENT_REVIEWER_A" "set bounds of current window to {100, 400, 600, 650}")
EOF
            sleep 2

            # REVIEWER_B
            osascript << EOF
$(create_window_with_agent "$AGENT_REVIEWER_B" "$rev_b_icon $AGENT_REVIEWER_B" "set bounds of current window to {700, 400, 1300, 650}")
EOF
            ;;
        "split")
            # 1つのウィンドウを分割
            osascript << EOF
$(create_window_with_agent "$AGENT_REVIEWER_A" "$rev_a_icon $AGENT_REVIEWER_A" "set bounds of current window to {100, 400, 800, 700}")
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
            write text "'$SCRIPT_DIR/agent-identity.sh' $AGENT_REVIEWER_B"
            delay 1
            write text "claude --dangerously-skip-permissions"
            set name to "$rev_b_icon $AGENT_REVIEWER_B"
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