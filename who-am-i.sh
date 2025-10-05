#!/bin/bash

# バナー再表示用簡易コマンド
# 使い方: ./who-am-i.sh [agent_name]

AGENT="$1"

# もしエージェント名が指定されていなければ、推測を試みる
if [ -z "$AGENT" ]; then
  # iTermのタブ名やウィンドウタイトルから推測
  if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    # タブ名に基づいて推測（簡易版）
    echo "💡 エージェント名を指定してください:"
    echo ""
    echo "使用例:"
    echo "  ./who-am-i.sh president"
    echo "  ./who-am-i.sh boss1"
    echo "  ./who-am-i.sh worker1"
    echo "  ./who-am-i.sh worker2"
    echo "  ... (worker8まで)"
    echo ""
    exit 1
  fi
fi

# エージェント識別スクリプトを呼び出し
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
"$SCRIPT_DIR/agent-identity.sh" "$AGENT"