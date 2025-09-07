#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# エージェント→tmuxターゲット マッピング（動的対応）
get_agent_target() {
    local name="$1"
    case "$name" in
        "president") echo "president" ;;
        "boss1") echo "multiagent:0.0" ;;
        worker*)
            # workerN を動的に multiagent:0.N に解決
            if [[ "$name" =~ ^worker([0-9]+)$ ]]; then
                local idx="${BASH_REMATCH[1]}"
                echo "multiagent:0.$idx"
            else
                echo ""
            fi
            ;;
        *) echo "" ;;
    esac
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
  $0 president "指示書に従って"
  $0 boss1 "Hello World プロジェクト開始指示"
  $0 worker1 "作業完了しました"
EOF
}

# エージェント一覧表示（tmux の実態に基づく。未起動なら NUM_WORKERS fallback）
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="

    # president
    if tmux has-session -t president 2>/dev/null; then
        echo "  president → president      (プロジェクト統括責任者)"
    else
        echo "  president → president      (プロジェクト統括責任者) [未起動かも]"
    fi

    if tmux has-session -t multiagent 2>/dev/null; then
        # multiagent:0 のペイン番号一覧を取得（ポータブル実装）
        panes_str=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | sort -n)
        if [ -n "$panes_str" ]; then
            for p in $panes_str; do
                if [ "$p" = "0" ]; then
                    echo "  boss1     → multiagent:0.0  (チームリーダー)"
                else
                    echo "  worker$p   → multiagent:0.$p  (実行担当者)"
                fi
            done
            return
        fi
        # ペインが取れない場合は fallback
    fi

    # Fallback: NUM_WORKERS または 3
    local n=${NUM_WORKERS:-3}
    if [ "$n" -lt 1 ]; then n=1; fi
    echo "  boss1     → multiagent:0.0  (チームリーダー)"
    for i in $(seq 1 "$n"); do
        echo "  worker$i   → multiagent:0.$i  (実行担当者)"
    done
    echo "  [注] multiagent セッションが未起動か、ペイン情報を取得できませんでした"
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
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
