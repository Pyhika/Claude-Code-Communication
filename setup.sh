#!/bin/bash

# 🚀 Multi-Agent Communication Demo 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo 環境構築"
echo "==========================================="
echo ""

# STEP 0: 依存チェック（tmux / claude）
log_info "🔎 依存関係チェック..."
check_cmd() {
    local cmd_name="$1"
    local version_cmd="$2"
    if ! command -v "$cmd_name" >/dev/null 2>&1; then
        echo "❌ 必須コマンドが見つかりません: $cmd_name"
        case "$cmd_name" in
            tmux)
                echo "  👉 インストール例 (macOS): brew install tmux"
                echo "  👉 ドキュメント: https://tmuxcheatsheet.com/"
                ;;
            claude)
                echo "  👉 Claude Code CLI をインストールしてください"
                echo "     参考: https://docs.anthropic.com/ja/docs/claude-code/overview"
                ;;
        esac
        exit 1
    else
        if [ -n "$version_cmd" ]; then
            local ver_output
            ver_output=$(eval "$version_cmd" 2>/dev/null || true)
            if [ -n "$ver_output" ]; then
                echo "   - $cmd_name version: $ver_output"
            else
                echo "   - $cmd_name は検出されました（バージョン取得不可）"
            fi
        fi
    fi
}
check_cmd "tmux" "tmux -V"
check_cmd "claude" "claude --version"
log_success "✅ 依存関係 OK"
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t multiagent 2>/dev/null && log_info "multiagentセッション削除完了" || log_info "multiagentセッションは存在しませんでした"
tmux kill-session -t president 2>/dev/null && log_info "presidentセッション削除完了" || log_info "presidentセッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/worker*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（可変ペイン：boss1 + workers）
log_info "📺 multiagentセッション作成開始 (可変ペイン)..."

# 最初のペイン作成（十分な仮想サイズを確保）
WIN_W=${TMUX_WINDOW_WIDTH:-240}
WIN_H=${TMUX_WINDOW_HEIGHT:-80}
tmux new-session -d -s multiagent -n "agents" -x "$WIN_W" -y "$WIN_H"
# 念のためリサイズ
tmux resize-window -t multiagent:0 -x "$WIN_W" -y "$WIN_H" 2>/dev/null || true

# 動的スケール: NUM_WORKERS（デフォルト3）
NUM_WORKERS=${NUM_WORKERS:-3}
if [ "$NUM_WORKERS" -lt 1 ]; then NUM_WORKERS=1; fi

# レイアウト選択（ワーカー数に応じて最適化）
if [ "$NUM_WORKERS" -le 3 ]; then
    # 3人以下: 左右分割（見やすい）
    tmux split-window -h -t "multiagent:0"
    
    # 右側で NUM_WORKERS-1 回 分割
    if [ "$NUM_WORKERS" -gt 1 ]; then
        for _ in $(seq 2 "$NUM_WORKERS"); do
            tallest=$(tmux list-panes -t multiagent:0 -F "#{pane_index} #{pane_height}" | awk '$1!=0 {print $0}' | sort -k2 -nr | head -1 | cut -d' ' -f1)
            if [ -z "$tallest" ]; then tallest=1; fi
            if ! tmux split-window -v -t "multiagent:0.$tallest" 2>/dev/null; then
                WIN_H=$((WIN_H + 20))
                tmux resize-window -t multiagent:0 -y "$WIN_H" 2>/dev/null || true
                tmux split-window -v -t "multiagent:0.$tallest"
            fi
        done
    fi
    # boss1を大きく表示
    tmux select-layout -t multiagent:0 main-vertical
    tmux resize-pane -t multiagent:0.0 -x 40%
else
    # 4人以上: グリッド表示（全員を見やすく）
    for i in $(seq 1 "$NUM_WORKERS"); do
        if ! tmux split-window -t "multiagent:0" 2>/dev/null; then
            # スペースが足りない場合はウィンドウサイズを拡大
            WIN_H=$((WIN_H + 20))
            tmux resize-window -t multiagent:0 -y "$WIN_H" 2>/dev/null || true
            # tiledレイアウトで再配置してから再試行
            tmux select-layout -t multiagent:0 tiled 2>/dev/null || true
            if ! tmux split-window -t "multiagent:0" 2>/dev/null; then
                log_warn "⚠️ ペイン $((i+1)) の作成をスキップ（スペース不足）"
                break
            fi
        fi
    done
    tmux select-layout -t multiagent:0 tiled
fi

# ペインタイトル設定
log_info "ペインタイトル設定中..."

# boss1 設定（左ペイン 0.0）
tmux select-pane -t "multiagent:0.0" -T "boss1"
tmux send-keys -t "multiagent:0.0" "cd $(pwd)" C-m
tmux send-keys -t "multiagent:0.0" "export PS1='(\[\033[1;31m\]boss1\[\033[0m\]) \[\033[1;32m\]\\w\[\033[0m\]\\$ '" C-m
tmux send-keys -t "multiagent:0.0" "echo '=== boss1 エージェント ==='" C-m

# workers 設定（右ペイン群 0.1+）
idx=1
while [ $idx -le $NUM_WORKERS ]; do
    pane_index=$((idx))
    title="worker$idx"
    tmux select-pane -t "multiagent:0.$pane_index" -T "$title" 2>/dev/null || true
    tmux send-keys -t "multiagent:0.$pane_index" "cd $(pwd)" C-m
    tmux send-keys -t "multiagent:0.$pane_index" "export PS1='(\[\033[1;34m\]$title\[\033[0m\]) \[\033[1;32m\]\\w\[\033[0m\]\\$ '" C-m
    tmux send-keys -t "multiagent:0.$pane_index" "echo '=== $title エージェント ==='" C-m
    idx=$((idx + 1))
done

# 最終的にレイアウト整形
tmux select-layout -t multiagent:0 even-vertical 2>/dev/null || true

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 3: presidentセッション作成（1ペイン）
log_info "👑 presidentセッション作成開始..."

tmux new-session -d -s president -x "$WIN_W" -y "$WIN_H"
tmux send-keys -t president "cd $(pwd)" C-m
tmux send-keys -t president "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\\w\[\033[0m\]\\$ '" C-m
tmux send-keys -t president "echo '=== PRESIDENT セッション ==='" C-m
tmux send-keys -t president "echo 'プロジェクト統括責任者'" C-m
tmux send-keys -t president "echo '========================'" C-m

log_success "✅ presidentセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
echo "  multiagentセッション（boss1 + workers）:"
echo "    Pane 0: boss1     (チームリーダー)"
for i in $(seq 1 "$NUM_WORKERS"); do
  echo "    Pane $i: worker$i   (実行担当者)"
done

echo ""
echo "  presidentセッション（1ペイン）:"
echo "    Pane 0: PRESIDENT (プロジェクト統括)"

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""

echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t multiagent   # マルチエージェント確認"
echo "     tmux attach-session -t president    # プレジデント確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # 手順1: President認証"
echo "     tmux send-keys -t president 'claude --dangerously-skip-permissions' C-m"
echo "     # 手順2: 認証後、multiagent起動（boss1 + workers）"
echo "     tmux send-keys -t multiagent:0.0 'claude --dangerously-skip-permissions' C-m"
echo "     for i in $(seq 1 $NUM_WORKERS); do tmux send-keys -t multiagent:0.$i 'claude --dangerously-skip-permissions' C-m; done"
