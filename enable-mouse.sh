#!/bin/bash

# 🖱️ tmuxマウス操作有効化スクリプト

set -e

# 色付きログ
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🖱️ tmuxマウス操作を有効化します"
echo "================================"

# 設定ファイルをコピー
log_info "tmux設定ファイルを適用中..."

# プロジェクトの設定ファイルをホームディレクトリにコピー
cp .tmux.conf ~/.tmux.conf

# 既存のtmuxセッションに設定を適用
if tmux list-sessions 2>/dev/null; then
    log_info "既存のtmuxセッションに設定を適用..."
    
    # 各セッションで設定をリロード
    for session in $(tmux list-sessions -F "#{session_name}"); do
        tmux source-file ~/.tmux.conf 2>/dev/null || true
        log_success "$session セッションに適用完了"
    done
    
    # グローバルにも適用
    tmux set -g mouse on
    
    # 各セッションのマウス設定を確認して有効化
    tmux list-sessions -F "#{session_name}" | while read session; do
        tmux set -t "$session" mouse on
    done
else
    log_info "tmuxセッションが見つかりません"
    log_info "次回tmux起動時に自動的に適用されます"
fi

echo ""
log_success "✅ マウス操作が有効になりました！"
echo ""
echo "📋 使える操作:"
echo "  🖱️ クリック      - ペインを選択"
echo "  🖱️ スクロール    - ログをスクロール"
echo "  🖱️ ドラッグ      - テキスト選択（コピー可能）"
echo "  🖱️ 右クリック    - ペースト（環境による）"
echo "  🖱️ ボーダードラッグ - ペインサイズ変更"
echo ""
echo "💡 追加のキーボードショートカット:"
echo "  Ctrl+b → z     - 現在のペインを最大化/元に戻す"
echo "  Ctrl+b → g     - グリッドレイアウト"
echo "  Ctrl+b → f     - フォーカスレイアウト"
echo "  Ctrl+b → v     - 縦分割レイアウト"
echo "  Ctrl+b → r     - 設定リロード"
echo ""
echo "🔄 もし反映されない場合:"
echo "  1. tmuxから一度離脱: Ctrl+b → d"
echo "  2. 再度アタッチ: tmux attach-session -t [セッション名]"