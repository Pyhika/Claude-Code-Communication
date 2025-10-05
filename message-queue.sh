#!/bin/bash

# 📬 メッセージキューシステム
# エージェント間の双方向通信を実現

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 定数読み込み
source "$SCRIPT_DIR/const/agents.sh"

# メッセージキューディレクトリ
QUEUE_DIR="$SCRIPT_DIR/message-queue"
INBOX_DIR="$QUEUE_DIR/inbox"
OUTBOX_DIR="$QUEUE_DIR/outbox"
ARCHIVE_DIR="$QUEUE_DIR/archive"

# ディレクトリ初期化
init_queue() {
    mkdir -p "$INBOX_DIR" "$OUTBOX_DIR" "$ARCHIVE_DIR"

    # 各エージェントのinboxを作成
    for agent in "${ALL_AGENTS[@]}"; do
        local internal=$(get_internal_name "$agent")
        mkdir -p "$INBOX_DIR/$internal"
        mkdir -p "$OUTBOX_DIR/$internal"
        mkdir -p "$ARCHIVE_DIR/$internal"
    done

    echo "✅ メッセージキュー初期化完了"
}

# メッセージ送信（キューに追加）
send_message() {
    local from="$1"
    local to="$2"
    local message="$3"

    # 送信元・送信先の正規化
    local from_normalized=$(normalize_agent_name "$from")
    local to_normalized=$(normalize_agent_name "$to")

    if [[ -z "$from_normalized" ]] || [[ -z "$to_normalized" ]]; then
        echo "❌ エラー: 不明なエージェント FROM=$from TO=$to"
        return 1
    fi

    local to_internal=$(get_internal_name "$to_normalized")
    local timestamp=$(date '+%Y%m%d_%H%M%S_%N')
    local message_file="$INBOX_DIR/$to_internal/${timestamp}_from_${from}.msg"

    # メッセージファイル作成
    cat > "$message_file" << EOF
FROM: $from_normalized
TO: $to_normalized
TIMESTAMP: $(date '+%Y-%m-%d %H:%M:%S')
MESSAGE_ID: ${timestamp}

$message
EOF

    echo "📬 メッセージ送信: $from_normalized → $to_normalized"
    echo "   ファイル: $message_file"

    # tmuxにも送信（リアルタイム表示用）
    local target=$(get_tmux_target "$to_normalized")
    if tmux has-session -t "${target%%:*}" 2>/dev/null; then
        tmux send-keys -t "$target" C-c
        sleep 0.2
        tmux send-keys -t "$target" "echo '📬 新着メッセージ from $from_normalized: $message'"
        tmux send-keys -t "$target" C-m
        sleep 0.3
        tmux send-keys -t "$target" "$message"
        tmux send-keys -t "$target" C-m
    fi

    return 0
}

# 受信メッセージ一覧表示
list_inbox() {
    local agent="$1"
    local normalized=$(normalize_agent_name "$agent")

    if [[ -z "$normalized" ]]; then
        echo "❌ エラー: 不明なエージェント $agent"
        return 1
    fi

    local internal=$(get_internal_name "$normalized")
    local inbox="$INBOX_DIR/$internal"

    if [[ ! -d "$inbox" ]]; then
        echo "⚠️ Inboxが存在しません: $agent"
        return 1
    fi

    local count=$(find "$inbox" -name "*.msg" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$count" -eq 0 ]]; then
        echo "📭 受信メッセージなし: $normalized"
        return 0
    fi

    echo "📬 受信メッセージ一覧: $normalized ($count件)"
    echo "=================================="

    local idx=1
    for msg_file in "$inbox"/*.msg; do
        if [[ -f "$msg_file" ]]; then
            local from=$(grep "^FROM:" "$msg_file" | cut -d' ' -f2)
            local timestamp=$(grep "^TIMESTAMP:" "$msg_file" | cut -d' ' -f2-)
            local preview=$(tail -n +6 "$msg_file" | head -n 1)

            echo "[$idx] $timestamp - from $from"
            echo "    ${preview:0:60}..."
            idx=$((idx + 1))
        fi
    done
}

# メッセージ読み取り
read_message() {
    local agent="$1"
    local message_number="$2"

    local normalized=$(normalize_agent_name "$agent")
    if [[ -z "$normalized" ]]; then
        echo "❌ エラー: 不明なエージェント $agent"
        return 1
    fi

    local internal=$(get_internal_name "$normalized")
    local inbox="$INBOX_DIR/$internal"

    local msg_file=$(find "$inbox" -name "*.msg" 2>/dev/null | sort | sed -n "${message_number}p")

    if [[ -z "$msg_file" ]] || [[ ! -f "$msg_file" ]]; then
        echo "❌ メッセージが見つかりません: #$message_number"
        return 1
    fi

    echo "=================================="
    cat "$msg_file"
    echo "=================================="

    # アーカイブに移動
    local archive_file="$ARCHIVE_DIR/$internal/$(basename "$msg_file")"
    mv "$msg_file" "$archive_file"
    echo "📦 アーカイブ: $archive_file"
}

# 全メッセージ削除
clear_inbox() {
    local agent="$1"
    local normalized=$(normalize_agent_name "$agent")

    if [[ -z "$normalized" ]]; then
        echo "❌ エラー: 不明なエージェント $agent"
        return 1
    fi

    local internal=$(get_internal_name "$normalized")
    local inbox="$INBOX_DIR/$internal"

    local count=$(find "$inbox" -name "*.msg" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$count" -eq 0 ]]; then
        echo "📭 削除するメッセージがありません"
        return 0
    fi

    # アーカイブに移動
    for msg_file in "$inbox"/*.msg; do
        if [[ -f "$msg_file" ]]; then
            local archive_file="$ARCHIVE_DIR/$internal/$(basename "$msg_file")"
            mv "$msg_file" "$archive_file"
        fi
    done

    echo "📦 $count件のメッセージをアーカイブしました"
}

# 統計情報
show_stats() {
    echo "📊 メッセージキュー統計"
    echo "=================================="

    for agent in "${ALL_AGENTS[@]}"; do
        local internal=$(get_internal_name "$agent")
        local icon=$(get_agent_icon "$agent")
        local inbox_count=$(find "$INBOX_DIR/$internal" -name "*.msg" 2>/dev/null | wc -l | tr -d ' ')
        local archive_count=$(find "$ARCHIVE_DIR/$internal" -name "*.msg" 2>/dev/null | wc -l | tr -d ' ')

        if [[ "$inbox_count" -gt 0 ]] || [[ "$archive_count" -gt 0 ]]; then
            echo "$icon $agent: 受信 $inbox_count件, アーカイブ $archive_count件"
        fi
    done
}

# 使用方法
usage() {
    cat << EOF
📬 メッセージキューシステム

使用方法:
  $0 init                          - キュー初期化
  $0 send <FROM> <TO> <MESSAGE>    - メッセージ送信
  $0 list <AGENT>                  - 受信メッセージ一覧
  $0 read <AGENT> <NUMBER>         - メッセージ読み取り
  $0 clear <AGENT>                 - 受信ボックスクリア
  $0 stats                         - 統計情報表示

例:
  $0 init
  $0 send PRESIDENT ARCHITECT "システム設計を開始してください"
  $0 list ARCHITECT
  $0 read ARCHITECT 1
  $0 stats
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
        init)
            init_queue
            ;;
        send)
            if [[ $# -lt 3 ]]; then
                echo "❌ エラー: 引数不足"
                echo "使用方法: $0 send <FROM> <TO> <MESSAGE>"
                exit 1
            fi
            send_message "$1" "$2" "$3"
            ;;
        list)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: エージェント名を指定してください"
                exit 1
            fi
            list_inbox "$1"
            ;;
        read)
            if [[ $# -lt 2 ]]; then
                echo "❌ エラー: エージェント名とメッセージ番号を指定してください"
                exit 1
            fi
            read_message "$1" "$2"
            ;;
        clear)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: エージェント名を指定してください"
                exit 1
            fi
            clear_inbox "$1"
            ;;
        stats)
            show_stats
            ;;
        *)
            echo "❌ エラー: 不明なコマンド: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
