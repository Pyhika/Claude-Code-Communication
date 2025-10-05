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
  echo "president|👑 PRESIDENT (統括責任者)"
  echo "architect|🏗️ ARCHITECT (設計統括)"

  # tmuxセッションから実際のペイン数を動的に取得
  local pane_count=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | wc -l | tr -d ' ')

  if [ -n "$pane_count" ] && [ "$pane_count" -gt 1 ]; then
    # boss1(pane 0)を除いた数がworker数
    local worker_count=$((pane_count - 1))
  else
    # tmuxセッションが見つからない場合はNUM_WORKERSまたはデフォルト値を使用
    local worker_count=${NUM_WORKERS:-8}
  fi

  if [ "$worker_count" -lt 1 ]; then worker_count=1; fi

  # 新システム: 専門エージェント名
  local role_names=("FRONTEND" "BACKEND" "DATABASE" "SECURITY" "TESTING" "DEPLOY" "DOCS" "QA")
  local role_icons=("🎨" "⚙️" "🗄️" "🔒" "🧪" "🚀" "📚" "🔍")
  local role_desc=("UI/UX実装" "API/サーバー" "データモデル" "セキュリティ" "テスト実装" "デプロイ" "ドキュメント" "品質保証")

  for i in $(seq 1 "$worker_count"); do
    if [ "$i" -le 8 ]; then
      echo "${role_names[$((i-1))]}|${role_icons[$((i-1))]} ${role_names[$((i-1))]} (${role_desc[$((i-1))]})"
    else
      echo "worker$i|👷 worker$i (実行担当者)"
    fi
  done
}

status_view() {
  echo "【チーム進捗状況】"

  # tmuxセッションから実際のworker数を取得
  local pane_count=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | wc -l | tr -d ' ')

  if [ -n "$pane_count" ] && [ "$pane_count" -gt 1 ]; then
    local worker_count=$((pane_count - 1))
  else
    local worker_count=${NUM_WORKERS:-8}
  fi

  # 専門エージェント名
  local role_names=("FRONTEND" "BACKEND" "DATABASE" "SECURITY" "TESTING" "DEPLOY" "DOCS" "QA")
  local role_icons=("🎨" "⚙️" "🗄️" "🔒" "🧪" "🚀" "📚" "🔍")

  # 全workerの状態を表示（ペインの最終行をチェック）
  for i in $(seq 1 "$worker_count"); do
    local last_activity=""
    local last_line=$(tmux capture-pane -t "multiagent:0.$i" -p 2>/dev/null | tail -n 5 | grep -v "^$" | tail -n 1)

    local agent_name="Worker$i"
    if [ "$i" -le 8 ]; then
      agent_name="${role_icons[$((i-1))]} ${role_names[$((i-1))]}"
    fi

    if [ -f "$TMP_DIR/worker${i}_done.txt" ]; then
      echo "$agent_name: ✅ 完了"
    elif echo "$last_line" | grep -q -E "(完了|✅|Completed|Done)"; then
      echo "$agent_name: ✅ タスク完了"
    elif echo "$last_line" | grep -q -E "(作業中|実装中|Creating|Building|🔄|🚀|📦|🛒)"; then
      echo "$agent_name: 🔄 作業中"
    else
      echo "$agent_name: ⏳ 待機中"
    fi
  done

  # プロジェクトディレクトリの状態も確認
  echo ""
  echo "【プロジェクト状態】"
  if [ -d "workspace/tea-shop" ]; then
    echo "📁 作業ディレクトリ: workspace/tea-shop/"
    if [ -f "workspace/tea-shop/package.json" ]; then
      echo "✅ Next.js プロジェクト: セットアップ完了"
    fi
    if [ -d "workspace/tea-shop/node_modules" ]; then
      echo "✅ 依存関係: インストール済み"
    fi
    if [ -d "workspace/tea-shop/app" ] || [ -d "workspace/tea-shop/src" ]; then
      echo "✅ ソースコード: 実装中"
    fi
    if [ -f "workspace/tea-shop/PROJECT_REQUIREMENTS.md" ]; then
      echo "✅ 要件定義書: 作成済み"
    fi
    if [ -f "workspace/tea-shop/MASTER_TASKS.md" ]; then
      echo "✅ タスクリスト: 作成済み"
    fi
  else
    echo "⚠️ プロジェクトディレクトリが存在しません"
  fi
  
  # Claudeの起動状態も確認
  echo ""
  echo "【Claude起動状態】"

  # presidentの状態をチェック
  local president_content=$(tmux capture-pane -t "president" -p 2>/dev/null | tail -n 20)
  if echo "$president_content" | grep -q -E "(bypass permissions|esc to interrupt|ctrl\+t to show todos|Claude Code|Welcome to Claude|^> $|───────)"; then
    echo "president: ✅ Claude起動中"
  else
    echo "president: ⚠️ Claude未起動"
  fi

  # boss1とworkersの状態をチェック
  local role_names=("ARCHITECT" "FRONTEND" "BACKEND" "DATABASE" "SECURITY" "TESTING" "DEPLOY" "DOCS" "QA")
  local role_icons=("🏗️" "🎨" "⚙️" "🗄️" "🔒" "🧪" "🚀" "📚" "🔍")

  local panes=$(tmux list-panes -t multiagent:0 -F "#{pane_index}" 2>/dev/null | sort -n)
  for idx in $panes; do
    local name="${role_icons[$idx]} ${role_names[$idx]}"

    # Claudeプロセスの確認（改善されたパターン）
    local pane_content=$(tmux capture-pane -t "multiagent:0.$idx" -p 2>/dev/null | tail -n 20)
    if echo "$pane_content" | grep -q -E "(bypass permissions|esc to interrupt|ctrl\+t to show todos|Claude Code|Welcome to Claude|^> $|───────|✢|⎿|⏵⏵)"; then
      echo "$name: ✅ Claude起動中"
    else
      echo "$name: ⚠️ Claude未起動"
    fi
  done
}

recent_logs() {
  echo "【最近の送信ログ】"
  echo "─────────────────────────────"
  if [ -f "$LOG_DIR/send_log.txt" ]; then
    # 最新20件のログを取得して、改行文字を実際の改行に変換
    tail -n 20 "$LOG_DIR/send_log.txt" | while IFS= read -r line; do
      # タイムスタンプと送信者を抽出
      if [[ "$line" =~ ^\[([^\]]+)\]\ ([^:]+):\ SENT\ -\ \"(.*)\"$ ]]; then
        timestamp="${BASH_REMATCH[1]}"
        agent="${BASH_REMATCH[2]}"
        message="${BASH_REMATCH[3]}"

        # エージェント名に色を付ける
        case "$agent" in
          president|PRESIDENT)
            agent_display="👑 PRESIDENT"
            ;;
          boss1|architect|ARCHITECT)
            agent_display="🏗️ ARCHITECT"
            ;;
          FRONTEND|frontend)
            agent_display="🎨 FRONTEND "
            ;;
          BACKEND|backend)
            agent_display="⚙️ BACKEND  "
            ;;
          DATABASE|database)
            agent_display="🗄️ DATABASE "
            ;;
          SECURITY|security)
            agent_display="🔒 SECURITY "
            ;;
          TESTING|testing)
            agent_display="🧪 TESTING  "
            ;;
          DEPLOY|deploy)
            agent_display="🚀 DEPLOY   "
            ;;
          DOCS|docs)
            agent_display="📚 DOCS     "
            ;;
          QA|qa)
            agent_display="🔍 QA       "
            ;;
          worker*)
            agent_display="👷 $agent  "
            ;;
          *)
            agent_display="   $agent    "
            ;;
        esac

        # タイムスタンプを短縮形式に変換（時刻のみ表示）
        time_only="${timestamp#* }"

        # メッセージの最初の行を取得（改行前まで）
        first_line="${message%%\\n*}"

        # 長いメッセージは切り詰めて表示
        if [ ${#first_line} -gt 60 ]; then
          first_line="${first_line:0:57}..."
        fi

        # フォーマットして出力
        printf "%-8s %s │ %s\n" "$time_only" "$agent_display" "$first_line"
      else
        # 通常のログフォーマットでない場合はそのまま表示
        echo "$line"
      fi
    done
  else
    echo "(ログなし)"
  fi
  echo "─────────────────────────────"
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
