#!/bin/bash

# 🤝 チーム連携ワークフローシステム
# PRESIDENT → ARCHITECT → WORKERS → REVIEWERS の自動連携

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 定数読み込み
source "$SCRIPT_DIR/const/agents.sh"

# メッセージキュー初期化
ensure_queue() {
    if [[ ! -d "$SCRIPT_DIR/message-queue/inbox" ]]; then
        echo "📦 メッセージキュー初期化中..."
        "$SCRIPT_DIR/message-queue.sh" init
    fi
}

# PRESIDENT → ARCHITECT への指示
president_to_architect() {
    local task="$1"

    ensure_queue

    echo "👑 PRESIDENT → 🏗️ ARCHITECT"
    echo "タスク: $task"
    echo ""

    # メッセージ送信
    "$SCRIPT_DIR/message-queue.sh" send "$AGENT_PRESIDENT" "$AGENT_ARCHITECT" "$task"

    # agent-send.shでも送信（リアルタイム表示）
    "$SCRIPT_DIR/agent-send.sh" "$AGENT_ARCHITECT" "📋 PRESIDENT からの指示: $task"

    echo ""
    echo "✅ ARCHITECTに指示を送信しました"
    echo "💡 ARCHITECTの応答を確認: ./response-monitor.sh monitor ARCHITECT"
}

# ARCHITECT → WORKERS への分割タスク
architect_to_workers() {
    local design_doc="$1"

    ensure_queue

    echo "🏗️ ARCHITECT → 8 WORKERS"
    echo "設計書: $design_doc"
    echo ""

    # 各WORKERに専門分野のタスクを送信
    local tasks=(
        "$AGENT_FRONTEND:UI/UX実装: $design_doc に基づいてフロントエンドを実装してください"
        "$AGENT_BACKEND:API実装: $design_doc に基づいてバックエンドAPIを実装してください"
        "$AGENT_DATABASE:DB設計: $design_doc に基づいてデータベーススキーマを設計・実装してください"
        "$AGENT_SECURITY:セキュリティ実装: $design_doc のセキュリティ要件を実装してください"
        "$AGENT_TESTING:テスト実装: $design_doc に基づいてテストコードを作成してください"
        "$AGENT_DEPLOY:デプロイ設定: $design_doc に基づいてCI/CDパイプラインを構築してください"
        "$AGENT_DOCS:ドキュメント作成: $design_doc に基づいてドキュメントを作成してください"
        "$AGENT_QA:品質保証: $design_doc の品質基準を確認し、全体の品質をチェックしてください"
    )

    for task_spec in "${tasks[@]}"; do
        IFS=':' read -ra parts <<< "$task_spec"
        local worker="${parts[0]}"
        local task="${parts[1]}:${parts[2]}"

        local icon=$(get_agent_icon "$worker")
        echo "  $icon $worker へタスク送信..."

        "$SCRIPT_DIR/message-queue.sh" send "$AGENT_ARCHITECT" "$worker" "$task"
        "$SCRIPT_DIR/agent-send.sh" "$worker" "📋 ARCHITECT からのタスク: $task"

        sleep 0.5
    done

    echo ""
    echo "✅ 全WORKERSにタスクを分割送信しました"
    echo "💡 応答監視: ./response-monitor.sh start"
}

# WORKERS → REVIEWERS へのレビュー依頼
workers_to_reviewers() {
    local completed_work="$1"

    ensure_queue

    echo "👷 WORKERS → 🔍 REVIEWERS"
    echo "完了作業: $completed_work"
    echo ""

    # REVIEWER_A: 品質レビュー
    local review_a_task="品質レビュー依頼: ${completed_work}のコード品質、設計パターン、保守性を確認してください"
    echo "  🔍 REVIEWER_A へレビュー依頼..."
    "$SCRIPT_DIR/message-queue.sh" send "$AGENT_QA" "$AGENT_REVIEWER_A" "$review_a_task"
    "$SCRIPT_DIR/agent-send.sh" "$AGENT_REVIEWER_A" "$review_a_task"

    sleep 0.5

    # REVIEWER_B: セキュリティレビュー
    local review_b_task="セキュリティレビュー依頼: ${completed_work}のセキュリティ、エラーハンドリング、安全性を確認してください"
    echo "  🛡️ REVIEWER_B へレビュー依頼..."
    "$SCRIPT_DIR/message-queue.sh" send "$AGENT_SECURITY" "$AGENT_REVIEWER_B" "$review_b_task"
    "$SCRIPT_DIR/agent-send.sh" "$AGENT_REVIEWER_B" "$review_b_task"

    echo ""
    echo "✅ REVIEWERSにレビュー依頼を送信しました"
    echo "💡 レビュー結果確認:"
    echo "   ./message-queue.sh list REVIEWER_A"
    echo "   ./message-queue.sh list REVIEWER_B"
}

# REVIEWERS → ARCHITECT へのレビュー報告
reviewers_to_architect() {
    local review_results="$1"

    ensure_queue

    echo "🔍 REVIEWERS → 🏗️ ARCHITECT"
    echo "レビュー結果: $review_results"
    echo ""

    # 両REVIEWERSからARCHITECTに報告
    "$SCRIPT_DIR/message-queue.sh" send "$AGENT_REVIEWER_A" "$AGENT_ARCHITECT" "品質レビュー完了: $review_results"
    "$SCRIPT_DIR/message-queue.sh" send "$AGENT_REVIEWER_B" "$AGENT_ARCHITECT" "セキュリティレビュー完了: $review_results"

    "$SCRIPT_DIR/agent-send.sh" "$AGENT_ARCHITECT" "📋 レビュー完了報告: $review_results"

    echo "✅ ARCHITECTにレビュー結果を報告しました"
}

# ARCHITECT → PRESIDENT への完了報告
architect_to_president() {
    local completion_report="$1"

    ensure_queue

    echo "🏗️ ARCHITECT → 👑 PRESIDENT"
    echo "完了報告: $completion_report"
    echo ""

    "$SCRIPT_DIR/message-queue.sh" send "$AGENT_ARCHITECT" "$AGENT_PRESIDENT" "プロジェクト完了報告: $completion_report"
    "$SCRIPT_DIR/agent-send.sh" "$AGENT_PRESIDENT" "📋 ARCHITECT からの完了報告: $completion_report"

    echo "✅ PRESIDENTに完了報告を送信しました"
}

# 完全なワークフロー実行
full_workflow() {
    local project_request="$1"

    echo "🚀 完全ワークフロー開始: $project_request"
    echo "========================================"
    echo ""

    # ステップ1: PRESIDENT → ARCHITECT
    echo "【ステップ1】PRESIDENT → ARCHITECT"
    president_to_architect "$project_request"
    echo ""
    echo "⏳ ARCHITECTの設計完了を待機中..."
    echo "   手動で次のステップに進む場合: $0 step2 \"設計書の内容\""
    echo ""
}

# ワークフローステップ2
workflow_step2() {
    local design="$1"

    echo "【ステップ2】ARCHITECT → WORKERS"
    architect_to_workers "$design"
    echo ""
    echo "⏳ WORKERSの実装完了を待機中..."
    echo "   手動で次のステップに進む場合: $0 step3 \"実装内容\""
    echo ""
}

# ワークフローステップ3
workflow_step3() {
    local implementation="$1"

    echo "【ステップ3】WORKERS → REVIEWERS"
    workers_to_reviewers "$implementation"
    echo ""
    echo "⏳ REVIEWERSのレビュー完了を待機中..."
    echo "   手動で次のステップに進む場合: $0 step4 \"レビュー結果\""
    echo ""
}

# ワークフローステップ4
workflow_step4() {
    local review="$1"

    echo "【ステップ4】REVIEWERS → ARCHITECT"
    reviewers_to_architect "$review"
    echo ""
    echo "⏳ ARCHITECTの最終確認を待機中..."
    echo "   手動で次のステップに進む場合: $0 step5 \"完了報告\""
    echo ""
}

# ワークフローステップ5
workflow_step5() {
    local report="$1"

    echo "【ステップ5】ARCHITECT → PRESIDENT"
    architect_to_president "$report"
    echo ""
    echo "✅ ワークフロー完了！"
}

# ワークフロー状態確認
workflow_status() {
    echo "📊 ワークフロー状態"
    echo "========================================"
    echo ""

    # 各エージェントのメッセージ状況
    echo "【メッセージキュー状況】"
    "$SCRIPT_DIR/message-queue.sh" stats
    echo ""

    # 監視プロセス状態
    echo "【応答監視プロセス】"
    local pid_file="$SCRIPT_DIR/message-queue/monitor.pid"
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "✅ 実行中 (PID: $pid)"
        else
            echo "⚠️ 停止中"
        fi
    else
        echo "⚠️ 未起動"
    fi
}

# 使用方法
usage() {
    cat << EOF
🤝 チーム連携ワークフローシステム

【完全自動ワークフロー】
  $0 start "<プロジェクト要件>"  - 完全ワークフロー開始

【個別ワークフロー】
  $0 p2a "<タスク>"              - PRESIDENT → ARCHITECT
  $0 a2w "<設計書>"              - ARCHITECT → WORKERS
  $0 w2r "<実装内容>"            - WORKERS → REVIEWERS
  $0 r2a "<レビュー結果>"        - REVIEWERS → ARCHITECT
  $0 a2p "<完了報告>"            - ARCHITECT → PRESIDENT

【ステップ実行】
  $0 step2 "<設計書>"            - ステップ2実行
  $0 step3 "<実装内容>"          - ステップ3実行
  $0 step4 "<レビュー結果>"      - ステップ4実行
  $0 step5 "<完了報告>"          - ステップ5実行

【状態確認】
  $0 status                      - ワークフロー状態確認

【例】
  # 完全ワークフロー開始
  $0 start "ECサイトのログイン機能を実装"

  # 個別実行
  $0 p2a "ユーザー認証機能の実装をお願いします"
  $0 a2w "JWT認証を使用したログインシステムを設計しました"
  $0 w2r "全機能の実装が完了しました"
  $0 r2a "品質・セキュリティともに問題ありません"
  $0 a2p "プロジェクト完了、全テスト通過"
EOF
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    local command="$1"
    shift

    case "$command" in
        start)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: プロジェクト要件を指定してください"
                exit 1
            fi
            full_workflow "$1"
            ;;
        p2a)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: タスクを指定してください"
                exit 1
            fi
            president_to_architect "$1"
            ;;
        a2w)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: 設計書を指定してください"
                exit 1
            fi
            architect_to_workers "$1"
            ;;
        w2r)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: 実装内容を指定してください"
                exit 1
            fi
            workers_to_reviewers "$1"
            ;;
        r2a)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: レビュー結果を指定してください"
                exit 1
            fi
            reviewers_to_architect "$1"
            ;;
        a2p)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: 完了報告を指定してください"
                exit 1
            fi
            architect_to_president "$1"
            ;;
        step2)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: 設計書を指定してください"
                exit 1
            fi
            workflow_step2 "$1"
            ;;
        step3)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: 実装内容を指定してください"
                exit 1
            fi
            workflow_step3 "$1"
            ;;
        step4)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: レビュー結果を指定してください"
                exit 1
            fi
            workflow_step4 "$1"
            ;;
        step5)
            if [[ $# -lt 1 ]]; then
                echo "❌ エラー: 完了報告を指定してください"
                exit 1
            fi
            workflow_step5 "$1"
            ;;
        status)
            workflow_status
            ;;
        *)
            echo "❌ エラー: 不明なコマンド: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
