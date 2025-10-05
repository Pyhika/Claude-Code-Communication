#!/bin/bash
# agents.sh - エージェント定数の一元管理
# このファイルで定義された定数を全スクリプトで使用すること

# ====================================
# エージェント名定義（公式名）
# ====================================

# 統括グループ
declare -r AGENT_PRESIDENT="PRESIDENT"
declare -r AGENT_ARCHITECT="ARCHITECT"

# 実装グループ（8 WORKERS）
declare -r AGENT_FRONTEND="FRONTEND"
declare -r AGENT_BACKEND="BACKEND"
declare -r AGENT_DATABASE="DATABASE"
declare -r AGENT_SECURITY="SECURITY"
declare -r AGENT_TESTING="TESTING"
declare -r AGENT_DEPLOY="DEPLOY"
declare -r AGENT_DOCS="DOCS"
declare -r AGENT_QA="QA"

# レビューグループ
declare -r AGENT_REVIEWER_A="REVIEWER_A"
declare -r AGENT_REVIEWER_B="REVIEWER_B"

# ====================================
# 内部識別子（tmuxターゲット）
# ====================================

# 統括グループ
declare -r TMUX_PRESIDENT="president"
declare -r TMUX_ARCHITECT="multiagent:0.0"

# 実装グループ
declare -r TMUX_FRONTEND="multiagent:0.1"
declare -r TMUX_BACKEND="multiagent:0.2"
declare -r TMUX_DATABASE="multiagent:0.3"
declare -r TMUX_SECURITY="multiagent:0.4"
declare -r TMUX_TESTING="multiagent:0.5"
declare -r TMUX_DEPLOY="multiagent:0.6"
declare -r TMUX_DOCS="multiagent:0.7"
declare -r TMUX_QA="multiagent:0.8"

# レビューグループ
declare -r TMUX_REVIEWER_A="reviewer_a"
declare -r TMUX_REVIEWER_B="reviewer_b"

# ====================================
# 内部名（agent-identity用）
# ====================================

# 統括グループ
declare -r INTERNAL_PRESIDENT="president"
declare -r INTERNAL_ARCHITECT="architect"

# 実装グループ
declare -r INTERNAL_FRONTEND="worker1"
declare -r INTERNAL_BACKEND="worker2"
declare -r INTERNAL_DATABASE="worker3"
declare -r INTERNAL_SECURITY="worker4"
declare -r INTERNAL_TESTING="worker5"
declare -r INTERNAL_DEPLOY="worker6"
declare -r INTERNAL_DOCS="worker7"
declare -r INTERNAL_QA="worker8"

# レビューグループ
declare -r INTERNAL_REVIEWER_A="reviewer_a"
declare -r INTERNAL_REVIEWER_B="reviewer_b"

# ====================================
# アイコン定義
# ====================================

# 統括グループ
declare -r ICON_PRESIDENT="👑"
declare -r ICON_ARCHITECT="🏗️"

# 実装グループ
declare -r ICON_FRONTEND="🎨"
declare -r ICON_BACKEND="⚙️"
declare -r ICON_DATABASE="🗄️"
declare -r ICON_SECURITY="🔒"
declare -r ICON_TESTING="🧪"
declare -r ICON_DEPLOY="🚀"
declare -r ICON_DOCS="📚"
declare -r ICON_QA="🔍"

# レビューグループ
declare -r ICON_REVIEWER_A="🔍"
declare -r ICON_REVIEWER_B="🛡️"

# ====================================
# 役割説明
# ====================================

# 統括グループ
declare -r DESC_PRESIDENT="統括責任者"
declare -r DESC_ARCHITECT="設計統括"

# 実装グループ
declare -r DESC_FRONTEND="UI/UX実装"
declare -r DESC_BACKEND="サーバー実装"
declare -r DESC_DATABASE="DB設計実装"
declare -r DESC_SECURITY="セキュリティ実装"
declare -r DESC_TESTING="テスト実装"
declare -r DESC_DEPLOY="デプロイ実装"
declare -r DESC_DOCS="ドキュメント作成"
declare -r DESC_QA="品質保証"

# レビューグループ
declare -r DESC_REVIEWER_A="レビュー担当A"
declare -r DESC_REVIEWER_B="レビュー担当B"

# ====================================
# エージェント配列（グループ別）
# ====================================

# 統括グループ（2エージェント）
declare -ra MANAGEMENT_AGENTS=(
    "$AGENT_PRESIDENT"
    "$AGENT_ARCHITECT"
)

# 実装グループ（8エージェント）
declare -ra WORKER_AGENTS=(
    "$AGENT_FRONTEND"
    "$AGENT_BACKEND"
    "$AGENT_DATABASE"
    "$AGENT_SECURITY"
    "$AGENT_TESTING"
    "$AGENT_DEPLOY"
    "$AGENT_DOCS"
    "$AGENT_QA"
)

# レビューグループ（2エージェント）
declare -ra REVIEWER_AGENTS=(
    "$AGENT_REVIEWER_A"
    "$AGENT_REVIEWER_B"
)

# 全エージェント（12エージェント）
declare -ra ALL_AGENTS=(
    "${MANAGEMENT_AGENTS[@]}"
    "${WORKER_AGENTS[@]}"
    "${REVIEWER_AGENTS[@]}"
)

# ====================================
# ヘルパー関数
# ====================================

# エージェント名からtmuxターゲットを取得
get_tmux_target() {
    local agent="$1"
    case "$agent" in
        "$AGENT_PRESIDENT") echo "$TMUX_PRESIDENT" ;;
        "$AGENT_ARCHITECT") echo "$TMUX_ARCHITECT" ;;
        "$AGENT_FRONTEND") echo "$TMUX_FRONTEND" ;;
        "$AGENT_BACKEND") echo "$TMUX_BACKEND" ;;
        "$AGENT_DATABASE") echo "$TMUX_DATABASE" ;;
        "$AGENT_SECURITY") echo "$TMUX_SECURITY" ;;
        "$AGENT_TESTING") echo "$TMUX_TESTING" ;;
        "$AGENT_DEPLOY") echo "$TMUX_DEPLOY" ;;
        "$AGENT_DOCS") echo "$TMUX_DOCS" ;;
        "$AGENT_QA") echo "$TMUX_QA" ;;
        "$AGENT_REVIEWER_A") echo "$TMUX_REVIEWER_A" ;;
        "$AGENT_REVIEWER_B") echo "$TMUX_REVIEWER_B" ;;
        *) echo "" ;;
    esac
}

# エージェント名から内部名を取得
get_internal_name() {
    local agent="$1"
    case "$agent" in
        "$AGENT_PRESIDENT") echo "$INTERNAL_PRESIDENT" ;;
        "$AGENT_ARCHITECT") echo "$INTERNAL_ARCHITECT" ;;
        "$AGENT_FRONTEND") echo "$INTERNAL_FRONTEND" ;;
        "$AGENT_BACKEND") echo "$INTERNAL_BACKEND" ;;
        "$AGENT_DATABASE") echo "$INTERNAL_DATABASE" ;;
        "$AGENT_SECURITY") echo "$INTERNAL_SECURITY" ;;
        "$AGENT_TESTING") echo "$INTERNAL_TESTING" ;;
        "$AGENT_DEPLOY") echo "$INTERNAL_DEPLOY" ;;
        "$AGENT_DOCS") echo "$INTERNAL_DOCS" ;;
        "$AGENT_QA") echo "$INTERNAL_QA" ;;
        "$AGENT_REVIEWER_A") echo "$INTERNAL_REVIEWER_A" ;;
        "$AGENT_REVIEWER_B") echo "$INTERNAL_REVIEWER_B" ;;
        *) echo "" ;;
    esac
}

# エージェント名からアイコンを取得
get_agent_icon() {
    local agent="$1"
    case "$agent" in
        "$AGENT_PRESIDENT") echo "$ICON_PRESIDENT" ;;
        "$AGENT_ARCHITECT") echo "$ICON_ARCHITECT" ;;
        "$AGENT_FRONTEND") echo "$ICON_FRONTEND" ;;
        "$AGENT_BACKEND") echo "$ICON_BACKEND" ;;
        "$AGENT_DATABASE") echo "$ICON_DATABASE" ;;
        "$AGENT_SECURITY") echo "$ICON_SECURITY" ;;
        "$AGENT_TESTING") echo "$ICON_TESTING" ;;
        "$AGENT_DEPLOY") echo "$ICON_DEPLOY" ;;
        "$AGENT_DOCS") echo "$ICON_DOCS" ;;
        "$AGENT_QA") echo "$ICON_QA" ;;
        "$AGENT_REVIEWER_A") echo "$ICON_REVIEWER_A" ;;
        "$AGENT_REVIEWER_B") echo "$ICON_REVIEWER_B" ;;
        *) echo "" ;;
    esac
}

# エージェント名から説明を取得
get_agent_desc() {
    local agent="$1"
    case "$agent" in
        "$AGENT_PRESIDENT") echo "$DESC_PRESIDENT" ;;
        "$AGENT_ARCHITECT") echo "$DESC_ARCHITECT" ;;
        "$AGENT_FRONTEND") echo "$DESC_FRONTEND" ;;
        "$AGENT_BACKEND") echo "$DESC_BACKEND" ;;
        "$AGENT_DATABASE") echo "$DESC_DATABASE" ;;
        "$AGENT_SECURITY") echo "$DESC_SECURITY" ;;
        "$AGENT_TESTING") echo "$DESC_TESTING" ;;
        "$AGENT_DEPLOY") echo "$DESC_DEPLOY" ;;
        "$AGENT_DOCS") echo "$DESC_DOCS" ;;
        "$AGENT_QA") echo "$DESC_QA" ;;
        "$AGENT_REVIEWER_A") echo "$DESC_REVIEWER_A" ;;
        "$AGENT_REVIEWER_B") echo "$DESC_REVIEWER_B" ;;
        *) echo "" ;;
    esac
}

# エージェント名の正規化（大文字小文字、レガシー名対応）
normalize_agent_name() {
    local input="$1"
    local upper
    upper=$(echo "$input" | tr '[:lower:]' '[:upper:]')  # 大文字化（互換性のある方法）

    # レガシー名のマッピング
    case "$upper" in
        "PRESIDENT") echo "$AGENT_PRESIDENT" ;;
        "ARCHITECT"|"BOSS1") echo "$AGENT_ARCHITECT" ;;
        "FRONTEND"|"WORKER1") echo "$AGENT_FRONTEND" ;;
        "BACKEND"|"WORKER2") echo "$AGENT_BACKEND" ;;
        "DATABASE"|"WORKER3") echo "$AGENT_DATABASE" ;;
        "SECURITY"|"WORKER4") echo "$AGENT_SECURITY" ;;
        "TESTING"|"WORKER5") echo "$AGENT_TESTING" ;;
        "DEPLOY"|"WORKER6") echo "$AGENT_DEPLOY" ;;
        "DOCS"|"WORKER7") echo "$AGENT_DOCS" ;;
        "QA"|"WORKER8") echo "$AGENT_QA" ;;
        "REVIEWER_A") echo "$AGENT_REVIEWER_A" ;;
        "REVIEWER_B") echo "$AGENT_REVIEWER_B" ;;
        *) echo "" ;;
    esac
}

# エージェントが存在するか確認
is_valid_agent() {
    local agent="$1"
    local normalized
    normalized=$(normalize_agent_name "$agent")
    [[ -n "$normalized" ]] && return 0 || return 1
}

# ====================================
# 使用例
# ====================================
#
# source const/agents.sh
#
# # エージェント名を使用
# echo "$AGENT_FRONTEND"  # FRONTEND
#
# # tmuxターゲットを取得
# target=$(get_tmux_target "$AGENT_FRONTEND")
# tmux send-keys -t "$target" "message"
#
# # 内部名を取得
# internal=$(get_internal_name "$AGENT_FRONTEND")
# export AGENT_NAME="$internal"
#
# # アイコンと説明を取得
# icon=$(get_agent_icon "$AGENT_FRONTEND")
# desc=$(get_agent_desc "$AGENT_FRONTEND")
# echo "$icon $AGENT_FRONTEND ($desc)"
#
# # 名前の正規化
# normalized=$(normalize_agent_name "frontend")  # FRONTEND
# normalized=$(normalize_agent_name "worker1")   # FRONTEND
#
