#!/bin/bash

# 🎨 tmux レイアウト切り替えスクリプト
# 見やすさを改善するための各種レイアウトを提供

set -e

# 色付きログ
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

show_usage() {
    cat << EOF
🎨 tmux レイアウト切り替え

使用方法:
  $0 [レイアウト名]

レイアウト:
  grid      - グリッド表示（デフォルト）
  focus     - 左側boss1大きく、右側workers小さく
  vertical  - 縦分割（上下に並べる）
  horizontal- 横分割（左右に並べる）
  main      - メインペイン＋サブペイン
  even      - 均等分割

例:
  $0 focus      # boss1を強調表示
  $0 grid       # 全員を均等なグリッド表示
  $0 vertical   # 縦に並べて表示

ヒント:
  - 画面が狭い場合は vertical がおすすめ
  - boss1を中心に見たい場合は focus
  - 全員を同時に見たい場合は grid
EOF
}

# レイアウト適用
apply_layout() {
    local layout="$1"
    
    if ! tmux has-session -t multiagent 2>/dev/null; then
        log_info "multiagentセッションが見つかりません"
        exit 1
    fi
    
    case "$layout" in
        grid)
            log_info "グリッドレイアウトを適用"
            tmux select-layout -t multiagent:0 tiled
            ;;
        focus)
            log_info "フォーカスレイアウトを適用（boss1を強調）"
            tmux select-layout -t multiagent:0 main-vertical
            tmux resize-pane -t multiagent:0.0 -x 50%
            ;;
        vertical)
            log_info "縦分割レイアウトを適用"
            tmux select-layout -t multiagent:0 even-vertical
            ;;
        horizontal)
            log_info "横分割レイアウトを適用"
            tmux select-layout -t multiagent:0 even-horizontal
            ;;
        main)
            log_info "メインペインレイアウトを適用"
            tmux select-layout -t multiagent:0 main-horizontal
            ;;
        even)
            log_info "均等分割レイアウトを適用"
            tmux select-layout -t multiagent:0 even-vertical
            ;;
        *)
            log_info "不明なレイアウト: $layout"
            show_usage
            exit 1
            ;;
    esac
    
    echo "✅ レイアウトを変更しました"
    echo "📺 確認: tmux attach-session -t multiagent"
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    apply_layout "$1"
}

main "$@"