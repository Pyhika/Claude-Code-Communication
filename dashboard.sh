#!/bin/bash

# 🧭 Dashboard (TUI) for Claude-Code-Communication
# 依存: gum または fzf（どちらかがあれば最低限動作）

set -e

# 設定
LOG_DIR="logs"
TMP_DIR="tmp"
TEMPLATES_DIR="templates"

# 検出
has_cmd() { command -v "$1" >/dev/null 2>&1; }

use_gum=false
if has_cmd gum; then
  use_gum=true
fi

if ! has_cmd fzf && [ "$use_gum" = false ]; then
  echo "❌ gum または fzf が必要です。インストールして再実行してください。"
  echo "  gum: brew install gum"
  echo "  fzf: brew install fzf"
  exit 1
fi

mkdir -p "$LOG_DIR" "$TMP_DIR" "$TEMPLATES_DIR"

list_agents() {
  echo "president|president"
  echo "boss1|multiagent:0.0"
  # workers は NUM_WORKERS から推測（存在しない場合もとりあえず表示）
  local n=${NUM_WORKERS:-3}
  if [ "$n" -lt 1 ]; then n=1; fi
  for i in $(seq 1 "$n"); do
    echo "worker$i|multiagent:0.$i"
  done
}

status_view() {
  echo "【チーム進捗状況】"
  for i in 1 2 3; do
    if [ -f "$TMP_DIR/worker${i}_done.txt" ]; then
      echo "Worker$i: ✅ 完了"
    else
      echo "Worker$i: 🔄 作業中"
    fi
  done
}

recent_logs() {
  echo "【最近の送信ログ】"
  if [ -f "$LOG_DIR/send_log.txt" ]; then
    tail -n 20 "$LOG_DIR/send_log.txt"
  else
    echo "(ログなし)"
  fi
}

pick_template() {
  local files=("$TEMPLATES_DIR"/*.txt)
  if [ ! -e "${files[0]}" ]; then
    echo "(テンプレートなし)"
    return 1
  fi
  if [ "$use_gum" = true ]; then
    gum choose "${files[@]}"
  else
    printf "%s\n" "${files[@]}" | fzf --prompt="テンプレート選択> "
  fi
}

send_message() {
  local agent_line="$1"  # name|target
  local agent_name="${agent_line%%|*}"
  local message="$2"
  ./agent-send.sh "$agent_name" "$message"
}

compose_message_from_template() {
  local tpl_path="$1"
  echo "テンプレート: $tpl_path"
  echo "プロジェクトIDを入力してください: "
  read -r pid
  echo "優先度を入力してください (low|normal|high): "
  read -r prio
  echo "本文を入力してください (改行可、Ctrl-Dで終了):"
  local body
  body=$(cat)
  local header="[agent-msg]\nproject_id: $pid\npriority: $prio\n---\n"
  echo -e "$header$(cat "$tpl_path")\n$body"
}

main_menu() {
  while true; do
    if [ "$use_gum" = true ]; then
      choice=$(printf "エージェント一覧\n状態表示\n最近ログ\nテンプレ送信\n自由入力送信\n終了\n" | gum choose)
    else
      choice=$(printf "エージェント一覧\n状態表示\n最近ログ\nテンプレ送信\n自由入力送信\n終了\n" | fzf --prompt="Dashboard> " --height=10 --layout=reverse --border)
    fi
    case "$choice" in
      "エージェント一覧")
        list_agents | sed 's/|/ -> /'
        ;;
      "状態表示")
        status_view
        ;;
      "最近ログ")
        recent_logs
        ;;
      "テンプレ送信")
        agent_line=$(list_agents | ( [ "$use_gum" = true ] && gum choose || fzf --prompt="送信先選択> " ))
        [ -z "$agent_line" ] && continue
        tpl=$(pick_template) || continue
        msg=$(compose_message_from_template "$tpl")
        send_message "$agent_line" "$msg"
        ;;
      "自由入力送信")
        agent_line=$(list_agents | ( [ "$use_gum" = true ] && gum choose || fzf --prompt="送信先選択> " ))
        [ -z "$agent_line" ] && continue
        if [ "$use_gum" = true ]; then
          msg=$(gum write --placeholder="メッセージ本文を入力")
        else
          echo "本文を入力（Ctrl-Dで確定）:"
          msg=$(cat)
        fi
        send_message "$agent_line" "$msg"
        ;;
      "終了")
        break
        ;;
    esac
  done
}

main_menu
