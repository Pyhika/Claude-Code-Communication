#!/bin/bash

# 🖥️ iTerm2 マルチウィンドウ起動スクリプト
# 各エージェントを独立したiTermウィンドウまたはタブで起動

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# デフォルト設定
LAYOUT="grid"  # grid, tabs, split, windows
NUM_WORKERS=4
PROFILE="core"
DO_ASSIGN=false
WINDOW_WIDTH=120
WINDOW_HEIGHT=40

usage() {
  cat << EOF
📋 使い方:
  $0 --layout LAYOUT [--workers N] [--profile PROFILE] [--assign]

🎨 レイアウトオプション:
  grid     - 2x4のグリッド配置（デフォルト、8人まで最適）
  tabs     - 1つのウィンドウに複数タブ
  split    - 1つのウィンドウを分割（4人まで最適）
  windows  - 個別ウィンドウで開く
  hybrid   - boss1とPRESIDENTは別ウィンドウ、workersはタブ

📝 例:
  # グリッドレイアウトで8人のフルチーム
  $0 --layout grid --workers 8 --profile full --assign

  # タブレイアウトで4人のコアチーム
  $0 --layout tabs --workers 4 --profile core --assign

  # 個別ウィンドウで起動
  $0 --layout windows --workers 6

  # ハイブリッド（管理者は別ウィンドウ）
  $0 --layout hybrid --workers 8 --profile full
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    --layout|-l)
      LAYOUT="$2"; shift 2;;
    --workers|-w)
      NUM_WORKERS="$2"; shift 2;;
    --profile|-p)
      PROFILE="$2"; shift 2;;
    --assign)
      DO_ASSIGN=true; shift;;
    --width)
      WINDOW_WIDTH="$2"; shift 2;;
    --height)
      WINDOW_HEIGHT="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "❌ 不明な引数: $1"; usage; exit 1;;
  esac
done

# iTerm2がインストールされているか確認
if ! osascript -e 'tell application "System Events" to return exists application process "iTerm"' &>/dev/null; then
  echo "❌ iTerm2がインストールされていません"
  echo "🔗 https://iterm2.com からインストールしてください"
  exit 1
fi

echo "🚀 iTermマルチウィンドウ起動"
echo "📊 レイアウト: $LAYOUT"
echo "👥 ワーカー数: $NUM_WORKERS"
echo "🎯 プロファイル: $PROFILE"

# iTermシステムではtmuxセッションは不要
echo "🔧 iTerm直接起動モード（tmux不要）"

# AppleScript生成関数
generate_applescript() {
  local layout="$1"
  local num_workers="$2"

  case "$layout" in
    "grid")
      cat << 'EOF'
tell application "iTerm"
  -- PRESIDENTウィンドウ（独立）
  create window with default profile
  tell current window
    set title to "👑 PRESIDENT - Project Control Center"
    tell current session
      set name to "👑 PRESIDENT - Project Owner"
    end tell
    delay 0.5
    tell current session
      write text "cd $SCRIPT_DIR && ./agent-identity.sh president && claude --dangerously-skip-permissions"
    end tell
  end tell

  -- BOSS1ウィンドウ（独立）
  create window with default profile
  tell current window
    set title to "💼 BOSS1 - Technical Leadership"
    tell current session
      set name to "💼 BOSS1 - Tech Lead"
    end tell
    delay 0.5
    tell current session
      write text "cd $SCRIPT_DIR && ./agent-identity.sh boss1 && claude --dangerously-skip-permissions"
    end tell
  end tell

  -- WORKERSウィンドウ（2x4グリッド）
  create window with default profile
  tell current window
    set title to "👥 WORKERS - Development Team"

    -- worker1（左上起点）
    set worker1_session to current session
    tell worker1_session
      set name to "🎨 WORKER1 - UI/UX"
    end tell
    delay 0.5
    tell worker1_session
      write text "cd $SCRIPT_DIR && ./agent-identity.sh worker1 && claude --dangerously-skip-permissions"
    end tell

    -- 上段を作成: worker1, worker2, worker3, worker4
    delay 1.0
    tell worker1_session
      set worker2_session to (split vertically with default profile)
    end tell
    delay 0.5
    tell worker2_session
      set name to "⚙️ WORKER2 - Backend"
      write text "cd $SCRIPT_DIR && ./agent-identity.sh worker2 && claude --dangerously-skip-permissions"
    end tell

    if NUM_WORKERS_COUNT > 2 then
      delay 1.0
      tell worker2_session
        set worker3_session to (split vertically with default profile)
      end tell
      delay 0.5
      tell worker3_session
        set name to "🧪 WORKER3 - Test/QA"
        write text "cd $SCRIPT_DIR && ./agent-identity.sh worker3 && claude --dangerously-skip-permissions"
      end tell
    end if

    if NUM_WORKERS_COUNT > 3 then
      delay 1.0
      tell worker3_session
        set worker4_session to (split vertically with default profile)
      end tell
      delay 0.5
      tell worker4_session
        set name to "📚 WORKER4 - Docs/DX"
        write text "cd $SCRIPT_DIR && ./agent-identity.sh worker4 && claude --dangerously-skip-permissions"
      end tell
    end if

    -- 下段を作成: worker5, worker6, worker7, worker8
    if NUM_WORKERS_COUNT > 4 then
      delay 1.0
      tell worker1_session
        set worker5_session to (split horizontally with default profile)
      end tell
      delay 0.5
      tell worker5_session
        set name to "⚡ WORKER5 - Performance"
        write text "cd $SCRIPT_DIR && ./agent-identity.sh worker5 && claude --dangerously-skip-permissions"
      end tell
    end if

    if NUM_WORKERS_COUNT > 5 then
      delay 1.0
      tell worker2_session
        set worker6_session to (split horizontally with default profile)
      end tell
      delay 0.5
      tell worker6_session
        set name to "🔒 WORKER6 - Security"
        write text "cd $SCRIPT_DIR && ./agent-identity.sh worker6 && claude --dangerously-skip-permissions"
      end tell
    end if

    if NUM_WORKERS_COUNT > 6 then
      delay 1.0
      tell worker3_session
        set worker7_session to (split horizontally with default profile)
      end tell
      delay 0.5
      tell worker7_session
        set name to "🔍 WORKER7 - E2E Test"
        write text "cd $SCRIPT_DIR && ./agent-identity.sh worker7 && claude --dangerously-skip-permissions"
      end tell
    end if

    if NUM_WORKERS_COUNT > 7 then
      delay 1.0
      tell worker4_session
        set worker8_session to (split horizontally with default profile)
      end tell
      delay 0.5
      tell worker8_session
        set name to "🚀 WORKER8 - DevOps"
        write text "cd $SCRIPT_DIR && ./agent-identity.sh worker8 && claude --dangerously-skip-permissions"
      end tell
    end if
  end tell
end tell
EOF
      ;;

    "tabs")
      cat << 'EOF'
tell application "iTerm"
  create window with default profile
  tell current window
    -- boss1タブ
    tell current session
      set name to "boss1 - Tech Lead"
      write text "claude --dangerously-skip-permissions"
    end tell

    -- worker タブを作成
    set workerTabs to {}
    repeat with i from 1 to NUM_WORKERS_COUNT
      set newTab to (create tab with default profile)
      tell current session of newTab
        set name to "worker" & i
        write text "claude --dangerously-skip-permissions"" & i
      end tell
    end repeat

    -- 最初のタブに戻る
    select tab 1
  end tell

  -- PRESIDENTを別ウィンドウで
  create window with default profile
  tell current window
    tell current session
      set name to "👑 PRESIDENT - Project Owner"
      write text "cd $SCRIPT_DIR && ./agent-identity.sh president && claude --dangerously-skip-permissions"
    end tell
  end tell
end tell
EOF
      ;;

    "split")
      cat << 'EOF'
tell application "iTerm"
  create window with default profile
  tell current window
    -- 4分割レイアウト（2x2）
    set session1 to current session
    tell session1
      set name to "boss1 - Tech Lead"
      write text "claude --dangerously-skip-permissions"
    end tell

    -- 右上
    tell session1
      set session2 to (split vertically with default profile)
    end tell
    tell session2
      set name to "worker1 - UI/UX"
      write text "claude --dangerously-skip-permissions"
    end tell

    -- 左下
    tell session1
      set session3 to (split horizontally with default profile)
    end tell
    tell session3
      set name to "worker2 - Backend"
      write text "claude --dangerously-skip-permissions"
    end tell

    -- 右下
    if NUM_WORKERS_COUNT > 2 then
      tell session2
        set session4 to (split horizontally with default profile)
      end tell
      tell session4
        set name to "worker3 - Test/QA"
        write text "claude --dangerously-skip-permissions"
      end tell
    end if

    -- 5人以上の場合はタブを追加
    if NUM_WORKERS_COUNT > 3 then
      repeat with i from 4 to NUM_WORKERS_COUNT
        set newTab to (create tab with default profile)
        tell current session of newTab
          set name to "worker" & i
          write text "claude --dangerously-skip-permissions"" & i
        end tell
      end repeat
    end if
  end tell

  -- PRESIDENTを別ウィンドウで
  create window with default profile
  tell current window
    tell current session
      set name to "👑 PRESIDENT - Project Owner"
      write text "cd $SCRIPT_DIR && ./agent-identity.sh president && claude --dangerously-skip-permissions"
    end tell
  end tell
end tell
EOF
      ;;

    "windows")
      cat << 'EOF'
tell application "iTerm"
  -- PRESIDENTウィンドウ
  create window with default profile
  tell current window
    set bounds to {50, 50, 800, 600}
    tell current session
      set name to "👑 PRESIDENT - Project Owner"
      write text "cd $SCRIPT_DIR && ./agent-identity.sh president && claude --dangerously-skip-permissions"
    end tell
  end tell

  -- boss1ウィンドウ
  create window with default profile
  tell current window
    set bounds to {870, 50, 1620, 600}
    tell current session
      set name to "boss1 - Tech Lead"
      write text "claude --dangerously-skip-permissions"
    end tell
  end tell

  -- 各workerを個別ウィンドウで
  set xPos to 50
  set yPos to 650
  repeat with i from 1 to NUM_WORKERS_COUNT
    create window with default profile
    tell current window
      set windowWidth to 750
      set windowHeight to 500

      -- 2列配置
      if i > 4 then
        set xPos to 870
        set yPos to 650 + ((i - 5) * 120)
      else
        set yPos to 650 + ((i - 1) * 120)
      end if

      set bounds to {xPos, yPos, xPos + windowWidth, yPos + windowHeight}
      tell current session
        set name to "worker" & i
        write text "claude --dangerously-skip-permissions"" & i
      end tell
    end tell
  end repeat
end tell
EOF
      ;;

    "hybrid")
      cat << 'EOF'
tell application "iTerm"
  -- 管理者用ウィンドウ（boss1とPRESIDENT）
  create window with default profile
  tell current window
    -- boss1
    set boss1Session to current session
    tell boss1Session
      set name to "boss1 - Tech Lead"
      write text "claude --dangerously-skip-permissions"
    end tell

    -- PRESIDENTを右に分割
    tell boss1Session
      set presidentSession to (split vertically with default profile)
    end tell
    tell presidentSession
      set name to "PRESIDENT - Project Owner"
      write text "claude --dangerously-skip-permissions"
    end tell
  end tell

  -- ワーカー用ウィンドウ（タブで管理）
  create window with default profile
  tell current window
    -- worker1
    tell current session
      set name to "worker1 - UI/UX"
      write text "claude --dangerously-skip-permissions"
    end tell

    -- 残りのworkerをタブで追加
    repeat with i from 2 to NUM_WORKERS_COUNT
      set newTab to (create tab with default profile)
      tell current session of newTab
        set name to "worker" & i
        write text "claude --dangerously-skip-permissions"" & i
      end tell
    end repeat

    -- 最初のタブに戻る
    select tab 1
  end tell
end tell
EOF
      ;;

    *)
      echo "❌ 不明なレイアウト: $layout"
      exit 1
      ;;
  esac
}

# AppleScriptを生成してファイルに保存
SCRIPT_FILE="/tmp/launch_iterm_agents.applescript"
generate_applescript "$LAYOUT" "$NUM_WORKERS" | \
  sed "s/NUM_WORKERS_COUNT/$NUM_WORKERS/g" | \
  sed "s|\$SCRIPT_DIR|$SCRIPT_DIR|g" > "$SCRIPT_FILE"

# AppleScriptを実行
echo "🎬 iTermウィンドウを起動中..."
osascript "$SCRIPT_FILE"

# iTermシステムでは各ペインで直接起動するため、役割割り当ては不要
if [ "$DO_ASSIGN" = true ]; then
  echo "✅ 各エージェントは起動時に自動的に役割が設定されます"
  echo "💡 各画面でブラウザ認証を完了してください"
fi

# 後処理
rm -f "$SCRIPT_FILE"

echo ""
echo "✅ iTermマルチウィンドウ起動完了"
echo ""
echo "📋 レイアウト説明:"
case "$LAYOUT" in
  "grid")
    echo "  • 2x4グリッド配置でworkerを表示"
    echo "  • PRESIDENTは別ウィンドウ"
    echo "  • 最大8人まで効率的に表示"
    ;;
  "tabs")
    echo "  • 1つのウィンドウに複数タブ"
    echo "  • タブ切り替えは Cmd+数字キー"
    echo "  • PRESIDENTは別ウィンドウ"
    ;;
  "split")
    echo "  • 1つのウィンドウを4分割"
    echo "  • 5人以上はタブで追加"
    echo "  • PRESIDENTは別ウィンドウ"
    ;;
  "windows")
    echo "  • 各エージェントが独立ウィンドウ"
    echo "  • 自動的に配置調整"
    echo "  • ウィンドウ管理ツールとの併用推奨"
    ;;
  "hybrid")
    echo "  • 管理者（boss1/PRESIDENT）は1つのウィンドウ"
    echo "  • workerは別ウィンドウのタブ"
    echo "  • 管理と実装の分離"
    ;;
esac

echo ""
echo "🎮 操作方法:"
echo "  • ペイン移動: Cmd+Option+矢印"
echo "  • タブ切替: Cmd+数字"
echo "  • ウィンドウ切替: Cmd+\`"
echo "  • 全画面: Cmd+Enter"
echo ""
echo "💡 ヒント:"
echo "  • ./project-status.sh でプロジェクト状況確認"
echo "  • ./agent-send.sh [agent] [message] でメッセージ送信"
echo "  • ./dashboard.sh で統合ダッシュボード表示"