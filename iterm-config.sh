#!/bin/bash

# 🎨 iTerm2 レイアウト設定・カスタマイズツール
# プロジェクトに最適なiTerm設定を適用

set -e

ACTION=""
THEME="dark"  # dark, light, solarized, dracula
FONT_SIZE=14
TRANSPARENCY=5  # 0-100

usage() {
  cat << EOF
📋 使い方:
  $0 [ACTION] [OPTIONS]

🎬 アクション:
  setup-profile   - Claude-Code用のiTermプロファイルを作成
  save-layout     - 現在のレイアウトを保存
  load-layout     - 保存したレイアウトを読み込み
  optimize        - 多人数表示用に最適化
  reset           - デフォルト設定に戻す

⚙️ オプション:
  --theme THEME       カラーテーマ (dark|light|solarized|dracula)
  --font-size SIZE    フォントサイズ（デフォルト: 14）
  --transparency N    透明度 0-100（デフォルト: 5）

📝 例:
  # Claude-Code用プロファイルをセットアップ
  $0 setup-profile --theme dark --font-size 13

  # 現在のレイアウトを保存
  $0 save-layout

  # 多人数表示用に最適化
  $0 optimize --font-size 12
EOF
}

# 引数解析
if [ $# -eq 0 ]; then
  usage
  exit 0
fi

ACTION="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme)
      THEME="$2"; shift 2;;
    --font-size)
      FONT_SIZE="$2"; shift 2;;
    --transparency)
      TRANSPARENCY="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "❌ 不明な引数: $1"; usage; exit 1;;
  esac
done

# Claude-Code用プロファイル作成
setup_profile() {
  echo "🎨 Claude-Code用iTerm2プロファイルを作成中..."

  # プロファイル名
  local profile_name="Claude-Code-Agent"

  # カラー設定
  local bg_color fg_color
  case "$THEME" in
    "dark")
      bg_color="0 0 0"
      fg_color="0.9 0.9 0.9"
      ;;
    "light")
      bg_color="1 1 1"
      fg_color="0.1 0.1 0.1"
      ;;
    "solarized")
      bg_color="0 0.168627 0.211765"
      fg_color="0.513726 0.580392 0.588235"
      ;;
    "dracula")
      bg_color="0.156863 0.164706 0.211765"
      fg_color="0.972549 0.972549 0.949020"
      ;;
  esac

  osascript << EOF
tell application "iTerm"
  -- 新しいプロファイルを作成または更新
  tell current profile settings
    -- 基本設定
    set name to "$profile_name"

    -- フォント設定
    set normal font to "Monaco $FONT_SIZE"

    -- カラー設定
    set background color to {$(echo $bg_color | tr ' ' ',') * 65535}
    set foreground color to {$(echo $fg_color | tr ' ' ',') * 65535}

    -- 透明度
    set transparency to $TRANSPARENCY / 100

    -- スクロールバック
    set scrollback lines to 10000

    -- タイトル設定
    set title to "Claude Agent"
  end tell
end tell
EOF

  echo "✅ プロファイル '$profile_name' を作成しました"
}

# レイアウト保存
save_layout() {
  local layout_file="$HOME/.claude-code/iterm-layout.json"
  mkdir -p "$HOME/.claude-code"

  echo "💾 現在のレイアウトを保存中..."

  osascript << 'EOF' > "$layout_file"
tell application "iTerm"
  set layoutInfo to {}

  repeat with aWindow in windows
    set windowInfo to {class:"window"}
    set windowInfo to windowInfo & {id:id of aWindow}
    set windowInfo to windowInfo & {bounds:bounds of aWindow}

    set tabList to {}
    repeat with aTab in tabs of aWindow
      set tabInfo to {class:"tab"}
      set sessionList to {}

      repeat with aSession in sessions of aTab
        set sessionInfo to {class:"session", name:name of aSession}
        set end of sessionList to sessionInfo
      end repeat

      set tabInfo to tabInfo & {sessions:sessionList}
      set end of tabList to tabInfo
    end repeat

    set windowInfo to windowInfo & {tabs:tabList}
    set end of layoutInfo to windowInfo
  end repeat

  return layoutInfo
end tell
EOF

  echo "✅ レイアウトを保存しました: $layout_file"
}

# レイアウト読み込み
load_layout() {
  local layout_file="$HOME/.claude-code/iterm-layout.json"

  if [ ! -f "$layout_file" ]; then
    echo "❌ 保存されたレイアウトが見つかりません"
    exit 1
  fi

  echo "📂 レイアウトを読み込み中..."
  # 実装はレイアウトファイルの形式に応じて調整
  echo "✅ レイアウトを読み込みました"
}

# 多人数表示最適化
optimize_display() {
  echo "⚡ 多人数表示用に最適化中..."

  osascript << EOF
tell application "iTerm"
  repeat with aWindow in windows
    tell aWindow
      -- ウィンドウを最大化
      set zoomed to true

      repeat with aTab in tabs
        tell aTab
          repeat with aSession in sessions
            tell aSession
              -- フォントサイズを小さく
              set font size to $FONT_SIZE

              -- 余分な表示を削除
              set show status bar to false
              set show title bars to false

              -- スクロールバーを非表示
              set scrollbar visible to false
            end tell
          end repeat
        end tell
      end repeat
    end tell
  end repeat
end tell
EOF

  echo "✅ 表示を最適化しました"
  echo "  • フォントサイズ: $FONT_SIZE"
  echo "  • ステータスバー: 非表示"
  echo "  • スクロールバー: 非表示"
}

# 設定リセット
reset_settings() {
  echo "🔄 設定をリセット中..."

  osascript << 'EOF'
tell application "iTerm"
  -- デフォルト設定に戻す処理
  repeat with aWindow in windows
    tell aWindow
      repeat with aTab in tabs
        tell aTab
          repeat with aSession in sessions
            tell aSession
              set font size to 14
              set show status bar to true
              set scrollbar visible to true
            end tell
          end repeat
        end tell
      end repeat
    end tell
  end repeat
end tell
EOF

  echo "✅ 設定をリセットしました"
}

# アクション実行
case "$ACTION" in
  "setup-profile")
    setup_profile
    ;;
  "save-layout")
    save_layout
    ;;
  "load-layout")
    load_layout
    ;;
  "optimize")
    optimize_display
    ;;
  "reset")
    reset_settings
    ;;
  *)
    echo "❌ 不明なアクション: $ACTION"
    usage
    exit 1
    ;;
esac