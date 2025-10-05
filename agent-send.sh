#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# 定数読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/const/agents.sh"

# エージェント→tmuxターゲット マッピング（定数ベース）
get_agent_target() {
    local name="$1"

    # 名前の正規化（大文字小文字、レガシー名対応）
    local normalized
    normalized=$(normalize_agent_name "$name")

    if [[ -z "$normalized" ]]; then
        # 正規化できない場合、tmuxターゲット直接指定かも
        if [[ "$name" == multiagent:* ]] || [[ "$name" == president ]] || [[ "$name" == reviewer_* ]]; then
            echo "$name"
            return 0
        fi
        echo ""
        return 1
    fi

    # 正規化された名前からtmuxターゲット取得
    get_tmux_target "$normalized"
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  現在の起動状況に応じて動的に表示されます（--list を参照）。

使用例:
  $0 $AGENT_PRESIDENT "指示書に従って"
  $0 $AGENT_ARCHITECT "システム設計を開始"
  $0 $AGENT_FRONTEND "UI実装を開始してください"
  $0 worker1 "作業完了しました"  # 旧形式も使用可能
EOF
}

# エージェント一覧表示（tmux の実態に基づく）
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="

    # 統括グループ
    echo ""
    echo "【統括グループ】"

    # PRESIDENT
    if tmux has-session -t "$TMUX_PRESIDENT" 2>/dev/null; then
        echo "  $AGENT_PRESIDENT → $(get_agent_icon "$AGENT_PRESIDENT") $(get_agent_desc "$AGENT_PRESIDENT")"
    else
        echo "  $AGENT_PRESIDENT → $(get_agent_icon "$AGENT_PRESIDENT") $(get_agent_desc "$AGENT_PRESIDENT") [未起動]"
    fi

    # ARCHITECT
    if tmux has-session -t multiagent 2>/dev/null; then
        echo "  $AGENT_ARCHITECT → $(get_agent_icon "$AGENT_ARCHITECT") $(get_agent_desc "$AGENT_ARCHITECT")"
    else
        echo "  $AGENT_ARCHITECT → $(get_agent_icon "$AGENT_ARCHITECT") $(get_agent_desc "$AGENT_ARCHITECT") [未起動]"
    fi

    # 実装グループ
    echo ""
    echo "【実装グループ】"

    if tmux has-session -t multiagent 2>/dev/null; then
        for agent in "${WORKER_AGENTS[@]}"; do
            local icon=$(get_agent_icon "$agent")
            local desc=$(get_agent_desc "$agent")
            echo "  $agent → $icon $desc"
        done
    else
        for agent in "${WORKER_AGENTS[@]}"; do
            local icon=$(get_agent_icon "$agent")
            local desc=$(get_agent_desc "$agent")
            echo "  $agent → $icon $desc [未起動]"
        done
    fi

    # レビューグループ
    echo ""
    echo "【レビューグループ】"

    for agent in "${REVIEWER_AGENTS[@]}"; do
        local tmux_target=$(get_tmux_target "$agent")
        local icon=$(get_agent_icon "$agent")
        local desc=$(get_agent_desc "$agent")

        if tmux has-session -t "$tmux_target" 2>/dev/null; then
            echo "  $agent → $icon $desc"
        else
            echo "  $agent → $icon $desc [未起動]"
        fi
    done

    echo ""
    echo "【レガシー名】"
    echo "  worker1-8 (FRONTEND-QA に対応)"
    echo "  boss1 (ARCHITECT に対応)"
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    mkdir -p "$SCRIPT_DIR/logs"
    echo "[$timestamp] $agent: SENT - \"$message\"" >> "$SCRIPT_DIR/logs/send_log.txt"
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"

    echo "📤 送信中: $target ← '$message'"

    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3

    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1

    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認（セッションとペインの両方を確認）
check_target() {
    local target="$1"
    local session_name="${target%%:*}"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi

    # ペインまで厳密に確認（形式: session:win.pane）
    if [[ "$target" == *:*.* ]]; then
        local exists=false
        while IFS= read -r p; do
            if [ "$p" = "$target" ]; then exists=true; break; fi
        done < <(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index}")
        if [ "$exists" != true ]; then
            echo "❌ ターゲット '$target' のペインが見つかりません"
            return 1
        fi
    fi
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi

    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi

    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi

    local agent_name="$1"
    local message="$2"

    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")

    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi

    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi

    # メッセージ送信
    send_message "$target" "$message"

    # ログ記録
    log_send "$agent_name" "$message"

    echo "✅ 送信完了: $agent_name に '$message'"

    return 0
}

main "$@"
