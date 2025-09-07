#!/bin/bash

# 🖥️ エージェント個別表示スクリプト
# 特定のエージェントのペインを全画面で表示

set -e

# 色付きログ
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

show_usage() {
    cat << EOF
📺 エージェント個別表示

使用方法:
  $0 [エージェント名]
  $0 --list
  $0 --all
  $0 --cycle

エージェント名:
  president - プロジェクト統括責任者
  boss1     - チームリーダー
  worker1-8 - 実行担当者

オプション:
  --list    利用可能なエージェント一覧
  --all     全ペインを等分表示（デフォルト）
  --cycle   各エージェントを順番に表示（5秒ごと）

例:
  $0 boss1       # boss1を全画面表示
  $0 worker1     # worker1を全画面表示
  $0 --all       # 全員を均等表示に戻す

キーボード操作:
  Ctrl+b → z     現在のペインを最大化/元に戻す
  Ctrl+b → 矢印  ペイン間移動
  Ctrl+b → d     tmuxから離脱
EOF
}

# エージェント一覧表示
list_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    
    if tmux has-session -t president 2>/dev/null; then
        echo "  president  - プロジェクト統括責任者"
    fi
    
    if tmux has-session -t multiagent 2>/dev/null; then
        panes_str=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | sort -n)
        for p in $panes_str; do
            if [ "$p" = "0" ]; then
                echo "  boss1      - チームリーダー"
            else
                echo "  worker$p    - 実行担当者"
            fi
        done
    fi
}

# エージェントを全画面表示
focus_agent() {
    local agent="$1"
    
    case "$agent" in
        president)
            if ! tmux has-session -t president 2>/dev/null; then
                log_error "presidentセッションが見つかりません"
                exit 1
            fi
            log_info "president画面にアタッチします"
            tmux attach-session -t president
            ;;
        boss1)
            if ! tmux has-session -t multiagent 2>/dev/null; then
                log_error "multiagentセッションが見つかりません"
                exit 1
            fi
            log_info "boss1（ペイン0）にフォーカスします"
            # boss1ペインを選択して最大化
            tmux select-pane -t multiagent:0.0
            tmux resize-pane -t multiagent:0.0 -Z
            tmux attach-session -t multiagent
            ;;
        worker*)
            if [[ "$agent" =~ ^worker([0-9]+)$ ]]; then
                local idx="${BASH_REMATCH[1]}"
                if ! tmux has-session -t multiagent 2>/dev/null; then
                    log_error "multiagentセッションが見つかりません"
                    exit 1
                fi
                log_info "$agent（ペイン$idx）にフォーカスします"
                # workerペインを選択して最大化
                tmux select-pane -t multiagent:0.$idx 2>/dev/null || {
                    log_error "ペイン multiagent:0.$idx が見つかりません"
                    exit 1
                }
                tmux resize-pane -t multiagent:0.$idx -Z
                tmux attach-session -t multiagent
            else
                log_error "不明なエージェント: $agent"
                exit 1
            fi
            ;;
        *)
            log_error "不明なエージェント: $agent"
            show_usage
            exit 1
            ;;
    esac
}

# 全ペインを均等表示
show_all() {
    if ! tmux has-session -t multiagent 2>/dev/null; then
        log_error "multiagentセッションが見つかりません"
        exit 1
    fi
    
    log_info "全ペインを均等表示に戻します"
    # ズーム解除
    tmux resize-pane -t multiagent:0 -Z 2>/dev/null || true
    # レイアウトを均等に
    tmux select-layout -t multiagent:0 tiled
    tmux attach-session -t multiagent
}

# サイクル表示（各エージェントを順番に表示）
cycle_agents() {
    log_info "各エージェントを5秒ごとに順番に表示します（Ctrl+Cで停止）"
    
    while true; do
        # boss1
        if tmux has-session -t multiagent 2>/dev/null; then
            echo "📍 boss1を表示中..."
            tmux select-pane -t multiagent:0.0
            tmux resize-pane -t multiagent:0.0 -Z
            sleep 5
            tmux resize-pane -t multiagent:0.0 -Z
        fi
        
        # workers
        panes=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | grep -v "^0$" | sort -n)
        for p in $panes; do
            echo "📍 worker$p を表示中..."
            tmux select-pane -t multiagent:0.$p
            tmux resize-pane -t multiagent:0.$p -Z
            sleep 5
            tmux resize-pane -t multiagent:0.$p -Z
        done
    done
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    case "$1" in
        --list)
            list_agents
            ;;
        --all)
            show_all
            ;;
        --cycle)
            cycle_agents
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            focus_agent "$1"
            ;;
    esac
}

main "$@"