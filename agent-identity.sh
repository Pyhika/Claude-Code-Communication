#!/bin/bash

# エージェント識別表示スクリプト
# 各エージェントの画面に色付きバナーと役割を表示

# 定数読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/const/agents.sh"

AGENT="$1"

# 役割名エイリアス（統一命名を内部名にマッピング）
INTERNAL_NAME=$(get_internal_name "$AGENT")
if [[ -z "$INTERNAL_NAME" ]]; then
    # 直接内部名が渡された場合もある
    INTERNAL_NAME="$AGENT"
fi

# カラーコード定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

# エージェント別の色とロール設定
case "$INTERNAL_NAME" in
  "president")
    COLOR="$RED"
    EMOJI="$ICON_PRESIDENT"
    ROLE="$AGENT_PRESIDENT - $DESC_PRESIDENT"
    BANNER="
${RED}═══════════════════════════════════════════════════════════
${BOLD}${RED}     $EMOJI $AGENT_PRESIDENT - AI PROJECT COMMANDER $EMOJI
${RED}═══════════════════════════════════════════════════════════${RESET}
    役割: 完全自動化システムの最高司令官
    権限: プロジェクト承認、品質基準決定、最終判定
    自動化: 要件解析、技術選択、完了判定の自動実行
    通信: ${AGENT_ARCHITECT}への自動指示、統合レビューの最終承認
${RED}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "architect")
    COLOR="$BLUE"
    EMOJI="$ICON_ARCHITECT"
    ROLE="$AGENT_ARCHITECT - $DESC_ARCHITECT"
    BANNER="
${BLUE}═══════════════════════════════════════════════════════════
${BOLD}${BLUE}     $EMOJI $AGENT_ARCHITECT - SYSTEM DESIGN LEAD $EMOJI
${BLUE}═══════════════════════════════════════════════════════════${RESET}
    役割: システム設計・アーキテクチャ自動決定
    権限: 技術スタック選択、設計書生成、品質統制
    自動化: DB設計、API設計、UI設計の自動生成
    通信: ${AGENT_PRESIDENT}からの要件受信、WORKERSへの自動タスク分割
    品質管理: 2人レビューワーからの報告統合・判定
${BLUE}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker1")
    COLOR="$GREEN"
    EMOJI="$ICON_FRONTEND"
    ROLE="$AGENT_FRONTEND - $DESC_FRONTEND"
    BANNER="
${GREEN}═══════════════════════════════════════════════════════════
${BOLD}${GREEN}     $EMOJI $AGENT_FRONTEND - FRONTEND_AI $EMOJI
${GREEN}═══════════════════════════════════════════════════════════${RESET}
    役割: フロントエンド完全自動実装
    自動化: React/Vue/Angular自動選択・実装
    専門機能: レスポンシブ自動適用、SEO自動最適化
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${GREEN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker2")
    COLOR="$YELLOW"
    EMOJI="$ICON_BACKEND"
    ROLE="$AGENT_BACKEND - $DESC_BACKEND"
    BANNER="
${YELLOW}═══════════════════════════════════════════════════════════
${BOLD}${YELLOW}     $EMOJI $AGENT_BACKEND - BACKEND_AI $EMOJI
${YELLOW}═══════════════════════════════════════════════════════════${RESET}
    役割: バックエンド完全自動実装
    自動化: Node.js/Python/Go自動選択・API自動生成
    専門機能: REST/GraphQL自動判定、認証システム自動組込
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker3")
    COLOR="$MAGENTA"
    EMOJI="$ICON_DATABASE"
    ROLE="$AGENT_DATABASE - $DESC_DATABASE"
    BANNER="
${MAGENTA}═══════════════════════════════════════════════════════════
${BOLD}${MAGENTA}     $EMOJI $AGENT_DATABASE - DATABASE_AI $EMOJI
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}
    役割: データベース完全自動設計・構築
    自動化: SQL/NoSQL自動選択、テーブル設計自動生成
    専門機能: マイグレーション自動作成、パフォーマンス自動最適化
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker4")
    COLOR="$CYAN"
    EMOJI="$ICON_SECURITY"
    ROLE="$AGENT_SECURITY - $DESC_SECURITY"
    BANNER="
${CYAN}═══════════════════════════════════════════════════════════
${BOLD}${CYAN}     $EMOJI $AGENT_SECURITY - SECURITY_AI $EMOJI
${CYAN}═══════════════════════════════════════════════════════════${RESET}
    役割: セキュリティ完全自動実装
    自動化: 脆弱性自動スキャン・修正、認証自動実装
    専門機能: HTTPS自動設定、OWASP対策自動適用
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker5")
    COLOR="$GREEN"
    EMOJI="$ICON_TESTING"
    ROLE="$AGENT_TESTING - $DESC_TESTING"
    BANNER="
${GREEN}═══════════════════════════════════════════════════════════
${BOLD}${GREEN}     $EMOJI $AGENT_TESTING - TESTING_AI $EMOJI
${GREEN}═══════════════════════════════════════════════════════════${RESET}
    役割: テスト完全自動生成・実行
    自動化: 単体・統合・E2Eテスト自動生成
    専門機能: パフォーマンステスト自動実行
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${GREEN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker6")
    COLOR="$YELLOW"
    EMOJI="$ICON_DEPLOY"
    ROLE="$AGENT_DEPLOY - $DESC_DEPLOY"
    BANNER="
${YELLOW}═══════════════════════════════════════════════════════════
${BOLD}${YELLOW}     $EMOJI $AGENT_DEPLOY - DEPLOY_AI $EMOJI
${YELLOW}═══════════════════════════════════════════════════════════${RESET}
    役割: デプロイ完全自動実行
    自動化: CI/CDパイプライン自動構築、クラウド環境自動セットアップ
    専門機能: コンテナ化自動実装、監視・ログ自動設定
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker7")
    COLOR="$MAGENTA"
    EMOJI="$ICON_DOCS"
    ROLE="$AGENT_DOCS - $DESC_DOCS"
    BANNER="
${MAGENTA}═══════════════════════════════════════════════════════════
${BOLD}${MAGENTA}     $EMOJI $AGENT_DOCS - DOCS_AI $EMOJI
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}
    役割: ドキュメント完全自動生成
    自動化: API文書自動生成、ユーザーマニュアル自動作成
    専門機能: 技術文書自動作成、保守マニュアル自動生成
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker8")
    COLOR="$CYAN"
    EMOJI="$ICON_QA"
    ROLE="$AGENT_QA - $DESC_QA"
    BANNER="
${CYAN}═══════════════════════════════════════════════════════════
${BOLD}${CYAN}     $EMOJI $AGENT_QA - QA_AI $EMOJI
${CYAN}═══════════════════════════════════════════════════════════${RESET}
    役割: 品質保証完全自動化
    自動化: コード品質自動チェック、パフォーマンス自動測定
    専門機能: ユーザビリティ自動テスト、バグ自動検出・修正
    通信: ${AGENT_ARCHITECT}からのタスク受信、REVIEWERへ成果自動送信
${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "reviewer_a")
    COLOR="$WHITE"
    EMOJI="$ICON_REVIEWER_A"
    ROLE="$AGENT_REVIEWER_A - $DESC_REVIEWER_A"
    BANNER="
${WHITE}═══════════════════════════════════════════════════════════
${BOLD}${WHITE}     $EMOJI $AGENT_REVIEWER_A - QUALITY REVIEWER $EMOJI
${WHITE}═══════════════════════════════════════════════════════════${RESET}
    役割: 品質重視の自動レビュー実行
    専門領域: コード品質、設計パターン、保守性
    自動チェック: 構造・命名・パフォーマンス・標準準拠
    報告先: ${AGENT_ARCHITECT}への品質評価レポート自動送信
${WHITE}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "reviewer_b")
    COLOR="$RED"
    EMOJI="$ICON_REVIEWER_B"
    ROLE="$AGENT_REVIEWER_B - $DESC_REVIEWER_B"
    BANNER="
${RED}═══════════════════════════════════════════════════════════
${BOLD}${RED}     $EMOJI $AGENT_REVIEWER_B - SECURITY REVIEWER $EMOJI
${RED}═══════════════════════════════════════════════════════════${RESET}
    役割: セキュリティ・安全性重視の自動レビュー実行
    専門領域: セキュリティ、エラーハンドリング、安全性
    自動チェック: 脆弱性・例外処理・データ検証・運用安全性
    報告先: ${AGENT_ARCHITECT}へのセキュリティ評価レポート自動送信
${RED}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  *)
    COLOR="$WHITE"
    EMOJI="❓"
    ROLE="Unknown Agent"
    BANNER="
${WHITE}═══════════════════════════════════════════════════════════
${BOLD}${WHITE}     ❓ UNKNOWN AGENT ❓
${WHITE}═══════════════════════════════════════════════════════════${RESET}
    エージェントが識別できません
${WHITE}═══════════════════════════════════════════════════════════${RESET}"
    ;;
esac

# バナーを表示
clear
echo -e "$BANNER"
echo ""
echo -e "${BOLD}作業ディレクトリ:${RESET} /workspace/[プロジェクト名]"
echo -e "${BOLD}コマンド:${RESET} claude --dangerously-skip-permissions"
echo ""
echo -e "${COLOR}${BOLD}準備完了！Claude Codeを起動します...${RESET}"
echo ""

# 環境変数として役割を設定（後で参照可能）
export AGENT_ROLE="$INTERNAL_NAME"
export AGENT_EMOJI="$EMOJI"
export AGENT_DESCRIPTION="$ROLE"

# 簡易識別用の環境変数も設定
case "$INTERNAL_NAME" in
  "president") export AGENT_SHORT="${ICON_PRESIDENT}PRES" ;;
  "architect") export AGENT_SHORT="${ICON_ARCHITECT}ARCH" ;;
  "worker1") export AGENT_SHORT="${ICON_FRONTEND}FRONT" ;;
  "worker2") export AGENT_SHORT="${ICON_BACKEND}BACK" ;;
  "worker3") export AGENT_SHORT="${ICON_DATABASE}DB" ;;
  "worker4") export AGENT_SHORT="${ICON_SECURITY}SEC" ;;
  "worker5") export AGENT_SHORT="${ICON_TESTING}TEST" ;;
  "worker6") export AGENT_SHORT="${ICON_DEPLOY}DEPLOY" ;;
  "worker7") export AGENT_SHORT="${ICON_DOCS}DOCS" ;;
  "worker8") export AGENT_SHORT="${ICON_QA}QA" ;;
  "reviewer_a") export AGENT_SHORT="${ICON_REVIEWER_A}QUA" ;;
  "reviewer_b") export AGENT_SHORT="${ICON_REVIEWER_B}SEC" ;;
  *) export AGENT_SHORT="❓UNKNOWN" ;;
esac

# シェルプロンプトに役割表示を追加
if [ -n "$ZSH_VERSION" ]; then
  # zsh用
  echo "export PS1='${COLOR}[${AGENT_SHORT}]${RESET} %~ %# '"
elif [ -n "$BASH_VERSION" ]; then
  # bash用
  echo "export PS1='${COLOR}[${AGENT_SHORT}]${RESET} \w \$ '"
fi

# 便利なエイリアスを設定
echo "alias whoami='$SCRIPT_DIR/who-am-i.sh $INTERNAL_NAME'"
echo "alias status='$SCRIPT_DIR/agent-status.sh'"
echo "alias role='echo \"Role: \$AGENT_ROLE (\$AGENT_SHORT)\"'"

echo ""
echo -e "${BOLD}💡 使用可能なコマンド:${RESET}"
echo -e "• ${CYAN}whoami${RESET} - フルバナー再表示"
echo -e "• ${CYAN}status${RESET} - コンパクトなステータス表示"
echo -e "• ${CYAN}role${RESET} - 現在の役割を確認"
echo -e "• ${CYAN}clear${RESET} - 画面をクリア"

# 安定化のため少し待機
sleep 1
