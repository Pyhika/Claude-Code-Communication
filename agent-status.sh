#!/bin/bash

# 現在のエージェント状態を常に表示するスクリプト

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# 環境変数から現在の役割を取得
if [ -n "$AGENT_ROLE" ]; then
  AGENT="$AGENT_ROLE"
  SHORT="$AGENT_SHORT"
  EMOJI="$AGENT_EMOJI"
else
  # 環境変数がない場合、引数から取得
  AGENT="$1"
  if [ -z "$AGENT" ]; then
    echo -e "${RED}❌ エージェント情報が見つかりません${RESET}"
    echo -e "使用方法: ./agent-status.sh [agent_name]"
    exit 1
  fi

  # 簡易情報を設定
  case "$AGENT" in
    "president") SHORT="👑PRES"; EMOJI="👑" ;;
    "architect") SHORT="🏗️ARCH"; EMOJI="🏗️" ;;
    "worker1") SHORT="🎨FRONT"; EMOJI="🎨" ;;
    "worker2") SHORT="⚙️BACK"; EMOJI="⚙️" ;;
    "worker3") SHORT="🗄️DB"; EMOJI="🗄️" ;;
    "worker4") SHORT="🔒SEC"; EMOJI="🔒" ;;
    "worker5") SHORT="🧪TEST"; EMOJI="🧪" ;;
    "worker6") SHORT="🚀DEPLOY"; EMOJI="🚀" ;;
    "worker7") SHORT="📚DOCS"; EMOJI="📚" ;;
    "worker8") SHORT="🔍QA"; EMOJI="🔍" ;;
    "reviewer_a") SHORT="🔍QUA"; EMOJI="🔍" ;;
    "reviewer_b") SHORT="🛡️SEC"; EMOJI="🛡️" ;;
    *) SHORT="❓UNKNOWN"; EMOJI="❓" ;;
  esac
fi

# 色を決定
case "$AGENT" in
  "president") COLOR="$RED" ;;
  "architect") COLOR="$BLUE" ;;
  "worker1"|"worker5") COLOR="$GREEN" ;;
  "worker2"|"worker6") COLOR="$YELLOW" ;;
  "worker3"|"worker7") COLOR="$MAGENTA" ;;
  "worker4"|"worker8") COLOR="$CYAN" ;;
  "reviewer_a") COLOR="$WHITE" ;;
  "reviewer_b") COLOR="$RED" ;;
  *) COLOR="$WHITE" ;;
esac

# コンパクトなステータス表示
AGENT_UPPER=$(echo "$AGENT" | tr '[:lower:]' '[:upper:]')
echo -e "${COLOR}${BOLD}┌─ ${SHORT} ─┐${RESET}"
echo -e "${COLOR}${BOLD}│ ${EMOJI} ${AGENT_UPPER} │${RESET}"
echo -e "${COLOR}${BOLD}└────────────┘${RESET}"

# 追加情報
echo -e "${BOLD}💡 コマンド:${RESET}"
echo -e "• ${CYAN}./who-am-i.sh $AGENT${RESET} - フルバナー表示"
echo -e "• ${CYAN}./agent-status.sh${RESET} - このステータス表示"
echo -e "• ${CYAN}clear${RESET} - 画面クリア"