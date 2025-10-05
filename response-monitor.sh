#!/bin/bash

# 🔔 応答監視システム
# エージェントからの応答を監視し、送信元に通知

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 定数読み込み
source "$SCRIPT_DIR/const/agents.sh"

# 設定
QUEUE_DIR="$SCRIPT_DIR/message-queue"
RESPONSE_TRACKING_DIR="$QUEUE_DIR/tracking"
MONITOR_INTERVAL=5  # 監視間隔（秒）

# 応答トラッキングディレクトリ初期化
init_tracking() {
    mkdir -p "$RESPONSE_TRACKING_DIR"
    for agent in "${ALL_AGENTS[@]}"; do
        local internal=$(get_internal_name "$agent")
        mkdir -p "$RESPONSE_TRACKING_DIR/$internal"
    done
}

# tmuxペインの出力を監視
monitor_agent_output() {
    local agent="$1"
    local target=$(get_tmux_target "$agent")
    local internal=$(get_internal_name "$agent")

    # セッションが存在するか確認
    if ! tmux has-session -t "${target%%:*}" 2>/dev/null; then
        return 1
    fi

    # 最新の出力を取得（最後の30行）
    local output=$(tmux capture-pane -t "$target" -p 2>/dev/null | tail -n 30)

    # 出力に応答パターンがあるか確認
    if echo "$output" | grep -q -E "(完了|完成|実装しました|作成しました|終了|Done|Completed|Finished)"; then
        # 最終チェック時刻を記録
        local last_check_file="$RESPONSE_TRACKING_DIR/$internal/last_check"
        local current_time=$(date '+%s')
        local last_check=0

        if [[ -f "$last_check_file" ]]; then
            last_check=$(cat "$last_check_file")
        fi

        # 前回チェックから10秒以上経過していれば通知
        if [[ $((current_time - last_check)) -gt 10 ]]; then
            echo "$current_time" > "$last_check_file"

            # 応答内容を抽出（最後の5行）
            local response=$(echo "$output" | tail -n 5)

            # 通知
            local icon=$(get_agent_icon "$agent")
            echo "🔔 [$icon $agent] 応答検出:"
            echo "$response" | head -n 3
            echo ""

            # ログに記録
            local log_file="$RESPONSE_TRACKING_DIR/$internal/responses.log"
            {
                echo "========================================="
                echo "TIMESTAMP: $(date '+%Y-%m-%d %H:%M:%S')"
                echo "AGENT: $agent"
                echo "========================================="
                echo "$response"
                echo ""
            } >> "$log_file"

            return 0
        fi
    fi

    return 1
}

# 全エージェントを監視
monitor_all() {
    echo "🔔 応答監視開始（間隔: ${MONITOR_INTERVAL}秒）"
    echo "終了するには Ctrl+C を押してください"
    echo ""

    init_tracking

    while true; do
        local detected=false

        for agent in "${ALL_AGENTS[@]}"; do
            if monitor_agent_output "$agent"; then
                detected=true
            fi
        done

        if [[ "$detected" == false ]]; then
            echo -ne "\r⏳ 監視中... $(date '+%H:%M:%S')"
        fi

        sleep "$MONITOR_INTERVAL"
    done
}

# 特定エージェントのみ監視
monitor_agent() {
    local agent="$1"
    local normalized=$(normalize_agent_name "$agent")

    if [[ -z "$normalized" ]]; then
        echo "❌ エラー: 不明なエージェント $agent"
        return 1
    fi

    echo "🔔 $normalized の応答監視開始"
    echo "終了するには Ctrl+C を押してください"
    echo ""

    init_tracking

    while true; do
        if ! monitor_agent_output "$normalized"; then
            echo -ne "\r⏳ 監視中... $(date '+%H:%M:%S')"
        fi

        sleep "$MONITOR_INTERVAL"
    done
}

# 応答ログ表示
show_response_log() {
    local agent="$1"
    local normalized=$(normalize_agent_name "$agent")

    if [[ -z "$normalized" ]]; then
        echo "❌ エラー: 不明なエージェント $agent"
        return 1
    fi

    local internal=$(get_internal_name "$normalized")
    local log_file="$RESPONSE_TRACKING_DIR/$internal/responses.log"

    if [[ ! -f "$log_file" ]]; then
        echo "📭 応答ログが存在しません: $normalized"
        return 0
    fi

    echo "📋 応答ログ: $normalized"
    echo "=================================="
    tail -n 50 "$log_file"
}

# バックグラウンド実行
start_background() {
    local pid_file="$QUEUE_DIR/monitor.pid"

    # 既に実行中かチェック
    if [[ -f "$pid_file" ]]; then
        local old_pid=$(cat "$pid_file")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            echo "⚠️ 監視プロセスは既に実行中です (PID: $old_pid)"
            echo "停止するには: $0 stop"
            return 1
        fi
    fi

    # バックグラウンドで実行
    nohup "$0" monitor-all > "$QUEUE_DIR/monitor.log" 2>&1 &
    local pid=$!
    echo "$pid" > "$pid_file"

    echo "✅ 応答監視をバックグラウンドで開始しました (PID: $pid)"
    echo "ログ: $QUEUE_DIR/monitor.log"
    echo "停止: $0 stop"
}

# バックグラウンド停止
stop_background() {
    local pid_file="$QUEUE_DIR/monitor.pid"

    if [[ ! -f "$pid_file" ]]; then
        echo "⚠️ 監視プロセスは実行されていません"
        return 0
    fi

    local pid=$(cat "$pid_file")

    if ps -p "$pid" > /dev/null 2>&1; then
        kill "$pid"
        echo "✅ 監視プロセスを停止しました (PID: $pid)"
    else
        echo "⚠️ PID $pid のプロセスは見つかりません"
    fi

    rm -f "$pid_file"
}

# 使用方法
usage() {
    cat << EOF
🔔 応答監視システム

使用方法:
  $0 monitor-all              - 全エージェントの応答を監視（フォアグラウンド）
  $0 monitor <AGENT>          - 特定エージェントの応答を監視
  $0 start                    - バックグラウンドで監視開始
  $0 stop                     - バックグラウンド監視停止
  $0 log <AGENT>              - 応答ログ表示

例:
  $0 start                    # バックグラウンド監視開始
  $0 monitor ARCHITECT        # ARCHITECTのみ監視
  $0 log FRONTEND             # FRONTENDの応答ログ表示
  $0 stop                     # 監視停止
EOF
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    local command="$1"
    shift

    case "$command" in
        monitor-all)
            monitor_all
            ;;
        monitor)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: エージェント名を指定してください"
                exit 1
            fi
            monitor_agent "$1"
            ;;
        start)
            start_background
            ;;
        stop)
            stop_background
            ;;
        log)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: エージェント名を指定してください"
                exit 1
            fi
            show_response_log "$1"
            ;;
        *)
            echo "❌ エラー: 不明なコマンド: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
