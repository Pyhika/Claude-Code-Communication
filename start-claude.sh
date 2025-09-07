#!/bin/bash

# 🤖 Claude Code 起動スクリプト
# 各エージェントのペインでClaude Codeを起動

set -e

# 色付きログ
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

show_usage() {
    cat << EOF
🤖 Claude Code 起動ツール

使用方法:
  $0 [オプション]

オプション:
  --all      全エージェントで起動（デフォルト）
  --president PRESIDENTのみ起動
  --boss     boss1のみ起動
  --workers  workersのみ起動
  --check    起動状態を確認
  --restart  再起動（既存を終了して新規起動）

例:
  $0               # 全エージェントで起動
  $0 --check       # 起動状態を確認
  $0 --restart     # 全エージェントを再起動
  $0 --workers     # workersのみ起動

注意:
  - 各ペインでブラウザ認証が必要です
  - 認証後、役割メッセージを送信してください
EOF
}

# 起動状態チェック
check_status() {
    echo "📊 Claude Code 起動状態:"
    echo "========================"
    
    # PRESIDENT
    local president_cmd=$(tmux list-panes -t president -F "#{pane_current_command}" 2>/dev/null || echo "none")
    if [[ "$president_cmd" == "node" ]]; then
        echo "✅ president: 起動済み"
    else
        echo "❌ president: 未起動（$president_cmd）"
    fi
    
    # multiagent
    if tmux has-session -t multiagent 2>/dev/null; then
        local panes=$(tmux list-panes -t multiagent:0 -F "#{pane_index} #{pane_current_command}" 2>/dev/null)
        while IFS=' ' read -r idx cmd; do
            local agent_name=""
            if [ "$idx" = "0" ]; then
                agent_name="boss1"
            else
                agent_name="worker$idx"
            fi
            
            if [[ "$cmd" == "node" ]]; then
                echo "✅ $agent_name: 起動済み"
            else
                echo "❌ $agent_name: 未起動（$cmd）"
            fi
        done <<< "$panes"
    fi
}

# Claude起動関数
launch_claude() {
    local target="$1"
    local name="$2"
    
    # 現在のコマンドを確認
    local current_cmd=$(tmux list-panes -t "$target" -F "#{pane_current_command}" 2>/dev/null || echo "none")
    
    if [[ "$current_cmd" == "node" ]]; then
        log_info "$name は既に起動しています"
        return 0
    fi
    
    log_info "$name でClaude Codeを起動中..."
    
    # Ctrl+Cで現在のコマンドを中断
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # Claude起動コマンド送信
    tmux send-keys -t "$target" "claude --dangerously-skip-permissions" C-m
    sleep 0.5
    
    log_success "$name で起動コマンドを送信しました"
}

# 全エージェント起動
launch_all() {
    log_info "全エージェントでClaude Codeを起動します..."
    
    # PRESIDENT
    if tmux has-session -t president 2>/dev/null; then
        launch_claude "president" "president"
    else
        log_warning "presidentセッションが見つかりません"
    fi
    
    # multiagent
    if tmux has-session -t multiagent 2>/dev/null; then
        # boss1
        launch_claude "multiagent:0.0" "boss1"
        
        # workers
        local num_workers=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | grep -v "^0$" | wc -l)
        for i in $(seq 1 $num_workers); do
            launch_claude "multiagent:0.$i" "worker$i"
        done
    else
        log_warning "multiagentセッションが見つかりません"
    fi
    
    echo ""
    log_success "✅ 全エージェントへの起動コマンド送信完了"
    echo ""
    echo "📋 次のステップ:"
    echo "1. 各画面でブラウザ認証を完了してください"
    echo "2. 認証後、役割を認識させてください:"
    echo "   ./agent-send.sh president \"あなたはpresidentです\""
    echo "   ./agent-send.sh boss1 \"あなたはboss1です\""
    echo "   ./agent-send.sh worker1 \"あなたはworker1です\""
}

# PRESIDENT のみ起動
launch_president() {
    if tmux has-session -t president 2>/dev/null; then
        launch_claude "president" "president"
    else
        log_warning "presidentセッションが見つかりません"
    fi
}

# boss1 のみ起動
launch_boss() {
    if tmux has-session -t multiagent 2>/dev/null; then
        launch_claude "multiagent:0.0" "boss1"
    else
        log_warning "multiagentセッションが見つかりません"
    fi
}

# workers のみ起動
launch_workers() {
    if tmux has-session -t multiagent 2>/dev/null; then
        local num_workers=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | grep -v "^0$" | wc -l)
        for i in $(seq 1 $num_workers); do
            launch_claude "multiagent:0.$i" "worker$i"
        done
    else
        log_warning "multiagentセッションが見つかりません"
    fi
}

# 再起動
restart_all() {
    log_info "全エージェントを再起動します..."
    
    # 既存のClaude終了
    if tmux has-session -t president 2>/dev/null; then
        tmux send-keys -t president C-c
        sleep 0.5
    fi
    
    if tmux has-session -t multiagent 2>/dev/null; then
        local panes=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null)
        for p in $panes; do
            tmux send-keys -t "multiagent:0.$p" C-c
            sleep 0.2
        done
    fi
    
    sleep 1
    
    # 新規起動
    launch_all
}

# メイン処理
main() {
    case "${1:-}" in
        --check)
            check_status
            ;;
        --president)
            launch_president
            ;;
        --boss)
            launch_boss
            ;;
        --workers)
            launch_workers
            ;;
        --restart)
            restart_all
            ;;
        --all|"")
            launch_all
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            log_warning "不明なオプション: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"