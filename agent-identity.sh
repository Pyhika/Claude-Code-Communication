#!/bin/bash

# エージェント識別表示スクリプト
# 各エージェントの画面に色付きバナーと役割を表示

AGENT="$1"

# 役割名エイリアス（統一命名をworker番号/内部名にマッピング）
case "$AGENT" in
  # 統括グループ
  "PRESIDENT") AGENT="president" ;;
  "ARCHITECT") AGENT="architect" ;;

  # 実装グループ
  "FRONTEND") AGENT="worker1" ;;
  "BACKEND") AGENT="worker2" ;;
  "DATABASE") AGENT="worker3" ;;
  "SECURITY") AGENT="worker4" ;;
  "TESTING") AGENT="worker5" ;;
  "DEPLOY") AGENT="worker6" ;;
  "DOCS") AGENT="worker7" ;;
  "QA") AGENT="worker8" ;;

  # レビューグループ
  "REVIEWER_A") AGENT="reviewer_a" ;;
  "REVIEWER_B") AGENT="reviewer_b" ;;
esac

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
case "$AGENT" in
  "president")
    COLOR="$RED"
    EMOJI="👑"
    ROLE="PRESIDENT - プロジェクト統括責任者"
    BANNER="
${RED}═══════════════════════════════════════════════════════════
${BOLD}${RED}     👑 PRESIDENT - AI PROJECT COMMANDER 👑
${RED}═══════════════════════════════════════════════════════════${RESET}
    役割: 完全自動化システムの最高司令官
    権限: プロジェクト承認、品質基準決定、最終判定
    自動化: 要件解析、技術選択、完了判定の自動実行
    通信: architectへの自動指示、統合レビューの最終承認
${RED}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "architect")
    COLOR="$BLUE"
    EMOJI="🏗️"
    ROLE="ARCHITECT - システム設計統括"
    BANNER="
${BLUE}═══════════════════════════════════════════════════════════
${BOLD}${BLUE}     🏗️ ARCHITECT - SYSTEM DESIGN LEAD 🏗️
${BLUE}═══════════════════════════════════════════════════════════${RESET}
    役割: システム設計・アーキテクチャ自動決定
    権限: 技術スタック選択、設計書生成、品質統制
    自動化: DB設計、API設計、UI設計の自動生成
    通信: presidentからの要件受信、workersへの自動タスク分割
    品質管理: 2人レビューワーからの報告統合・判定
${BLUE}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker1")
    COLOR="$GREEN"
    EMOJI="🎨"
    ROLE="WORKER1 - フロントエンド自動AI"
    BANNER="
${GREEN}═══════════════════════════════════════════════════════════
${BOLD}${GREEN}     🎨 WORKER1 - FRONTEND_AI 🎨
${GREEN}═══════════════════════════════════════════════════════════${RESET}
    役割: フロントエンド完全自動実装
    自動化: React/Vue/Angular自動選択・実装
    専門機能: レスポンシブ自動適用、SEO自動最適化
    通信: architectからのタスク受信、reviewerへ成果自動送信
${GREEN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker2")
    COLOR="$YELLOW"
    EMOJI="⚙️"
    ROLE="WORKER2 - バックエンド自動AI"
    BANNER="
${YELLOW}═══════════════════════════════════════════════════════════
${BOLD}${YELLOW}     ⚙️ WORKER2 - BACKEND_AI ⚙️
${YELLOW}═══════════════════════════════════════════════════════════${RESET}
    役割: バックエンド完全自動実装
    自動化: Node.js/Python/Go自動選択・API自動生成
    専門機能: REST/GraphQL自動判定、認証システム自動組込
    通信: architectからのタスク受信、reviewerへ成果自動送信
${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker3")
    COLOR="$MAGENTA"
    EMOJI="🗄️"
    ROLE="WORKER3 - データベース自動AI"
    BANNER="
${MAGENTA}═══════════════════════════════════════════════════════════
${BOLD}${MAGENTA}     🗄️ WORKER3 - DATABASE_AI 🗄️
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}
    役割: データベース完全自動設計・構築
    自動化: SQL/NoSQL自動選択、テーブル設計自動生成
    専門機能: マイグレーション自動作成、パフォーマンス自動最適化
    通信: architectからのタスク受信、reviewerへ成果自動送信
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker4")
    COLOR="$CYAN"
    EMOJI="🔒"
    ROLE="WORKER4 - セキュリティ自動AI"
    BANNER="
${CYAN}═══════════════════════════════════════════════════════════
${BOLD}${CYAN}     🔒 WORKER4 - SECURITY_AI 🔒
${CYAN}═══════════════════════════════════════════════════════════${RESET}
    役割: セキュリティ完全自動実装
    自動化: 脆弱性自動スキャン・修正、認証自動実装
    専門機能: HTTPS自動設定、OWASP対策自動適用
    通信: architectからのタスク受信、reviewerへ成果自動送信
${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker5")
    COLOR="$GREEN"
    EMOJI="🧪"
    ROLE="WORKER5 - テスト自動AI"
    BANNER="
${GREEN}═══════════════════════════════════════════════════════════
${BOLD}${GREEN}     🧪 WORKER5 - TESTING_AI 🧪
${GREEN}═══════════════════════════════════════════════════════════${RESET}
    役割: テスト完全自動生成・実行
    自動化: 単体・統合・E2Eテスト自動生成
    専門機能: パフォーマンステスト自動実行
    通信: architectからのタスク受信、reviewerへ成果自動送信
${GREEN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker6")
    COLOR="$YELLOW"
    EMOJI="🚀"
    ROLE="WORKER6 - デプロイ自動AI"
    BANNER="
${YELLOW}═══════════════════════════════════════════════════════════
${BOLD}${YELLOW}     🚀 WORKER6 - DEPLOY_AI 🚀
${YELLOW}═══════════════════════════════════════════════════════════${RESET}
    役割: デプロイ完全自動実行
    自動化: CI/CDパイプライン自動構築、クラウド環境自動セットアップ
    専門機能: コンテナ化自動実装、監視・ログ自動設定
    通信: architectからのタスク受信、reviewerへ成果自動送信
${YELLOW}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker7")
    COLOR="$MAGENTA"
    EMOJI="📚"
    ROLE="WORKER7 - ドキュメント自動AI"
    BANNER="
${MAGENTA}═══════════════════════════════════════════════════════════
${BOLD}${MAGENTA}     📚 WORKER7 - DOCS_AI 📚
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}
    役割: ドキュメント完全自動生成
    自動化: API文書自動生成、ユーザーマニュアル自動作成
    専門機能: 技術文書自動作成、保守マニュアル自動生成
    通信: architectからのタスク受信、reviewerへ成果自動送信
${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "worker8")
    COLOR="$CYAN"
    EMOJI="🔍"
    ROLE="WORKER8 - 品質保証自動AI"
    BANNER="
${CYAN}═══════════════════════════════════════════════════════════
${BOLD}${CYAN}     🔍 WORKER8 - QA_AI 🔍
${CYAN}═══════════════════════════════════════════════════════════${RESET}
    役割: 品質保証完全自動化
    自動化: コード品質自動チェック、パフォーマンス自動測定
    専門機能: ユーザビリティ自動テスト、バグ自動検出・修正
    通信: architectからのタスク受信、reviewerへ成果自動送信
${CYAN}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "reviewer_a")
    COLOR="$WHITE"
    EMOJI="🔍"
    ROLE="REVIEWER_A - 品質レビューAI"
    BANNER="
${WHITE}═══════════════════════════════════════════════════════════
${BOLD}${WHITE}     🔍 REVIEWER_A - QUALITY REVIEWER 🔍
${WHITE}═══════════════════════════════════════════════════════════${RESET}
    役割: 品質重視の自動レビュー実行
    専門領域: コード品質、設計パターン、保守性
    自動チェック: 構造・命名・パフォーマンス・標準準拠
    報告先: architectへの品質評価レポート自動送信
${WHITE}═══════════════════════════════════════════════════════════${RESET}"
    ;;

  "reviewer_b")
    COLOR="$RED"
    EMOJI="🛡️"
    ROLE="REVIEWER_B - セキュリティレビューAI"
    BANNER="
${RED}═══════════════════════════════════════════════════════════
${BOLD}${RED}     🛡️ REVIEWER_B - SECURITY REVIEWER 🛡️
${RED}═══════════════════════════════════════════════════════════${RESET}
    役割: セキュリティ・安全性重視の自動レビュー実行
    専門領域: セキュリティ、エラーハンドリング、安全性
    自動チェック: 脆弱性・例外処理・データ検証・運用安全性
    報告先: architectへのセキュリティ評価レポート自動送信
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
export AGENT_ROLE="$AGENT"
export AGENT_EMOJI="$EMOJI"
export AGENT_DESCRIPTION="$ROLE"

# 簡易識別用の環境変数も設定
case "$AGENT" in
  "president") export AGENT_SHORT="👑PRES" ;;
  "architect") export AGENT_SHORT="🏗️ARCH" ;;
  "worker1") export AGENT_SHORT="🎨FRONT" ;;
  "worker2") export AGENT_SHORT="⚙️BACK" ;;
  "worker3") export AGENT_SHORT="🗄️DB" ;;
  "worker4") export AGENT_SHORT="🔒SEC" ;;
  "worker5") export AGENT_SHORT="🧪TEST" ;;
  "worker6") export AGENT_SHORT="🚀DEPLOY" ;;
  "worker7") export AGENT_SHORT="📚DOCS" ;;
  "worker8") export AGENT_SHORT="🔍QA" ;;
  "reviewer_a") export AGENT_SHORT="🔍QUA" ;;
  "reviewer_b") export AGENT_SHORT="🛡️SEC" ;;
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
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "alias whoami='$SCRIPT_DIR/who-am-i.sh $AGENT'"
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