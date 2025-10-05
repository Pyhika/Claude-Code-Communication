#!/bin/bash

# 📜 ログの詳細表示スクリプト
# 改行を含むメッセージを読みやすく表示

LOG_DIR="logs"

# 引数がない場合は最新10件を表示
LINES=${1:-10}

if [ ! -f "$LOG_DIR/send_log.txt" ]; then
  echo "❌ ログファイルが存在しません"
  exit 1
fi

echo "📜 送信ログ詳細（最新 $LINES 件）"
echo "════════════════════════════════════════════════════════════════════════════"

tail -n "$LINES" "$LOG_DIR/send_log.txt" | while IFS= read -r line; do
  # ログエントリをパース
  if [[ "$line" =~ ^\[([^\]]+)\]\ ([^:]+):\ SENT\ -\ \"(.*)\"$ ]]; then
    timestamp="${BASH_REMATCH[1]}"
    agent="${BASH_REMATCH[2]}"
    message="${BASH_REMATCH[3]}"

    # エージェントの絵文字
    case "$agent" in
      president)
        emoji="👑"
        ;;
      boss1)
        emoji="💼"
        ;;
      worker*)
        emoji="👷"
        ;;
      *)
        emoji="📨"
        ;;
    esac

    # ヘッダー行を表示
    echo ""
    echo "┌─ $emoji $agent [$timestamp]"
    echo "│"

    # メッセージを改行で分割して表示
    echo "$message" | sed 's/\\n/\n/g' | while IFS= read -r msg_line; do
      if [ -n "$msg_line" ]; then
        echo "│  $msg_line"
      fi
    done

    echo "└────────────────────────────────────────────────────────────────────────"
  fi
done

echo ""
echo "════════════════════════════════════════════════════════════════════════════"
echo ""
echo "💡 ヒント: ./view-log-detail.sh [件数] で表示件数を指定できます"