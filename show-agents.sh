#!/bin/bash

# エージェント配置表示スクリプト

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
RESET='\033[0m'

clear

echo -e "${BOLD}${CYAN}
╔═══════════════════════════════════════════════════════════════════════╗
║             🤖 Multi-Agent Communication System 🤖                     ║
║                    エージェント配置ガイド                              ║
╚═══════════════════════════════════════════════════════════════════════╝${RESET}
"

echo -e "${BOLD}📊 Grid Layout (1:1:8構成)${RESET}"
echo ""
echo -e "${BOLD}${RED}🖥️  PRESIDENT ウィンドウ（独立）${RESET}"
echo -e "┌─────────────────────────────────────┐"
echo -e "│ ${RED}👑 PRESIDENT - Project Owner${RESET}       │"
echo -e "│ プロジェクト統括・最終意思決定      │"
echo -e "└─────────────────────────────────────┘"
echo ""
echo -e "${BOLD}${BLUE}🖥️  BOSS1 ウィンドウ（独立）${RESET}"
echo -e "┌─────────────────────────────────────┐"
echo -e "│ ${BLUE}💼 BOSS1 - Tech Lead${RESET}              │"
echo -e "│ 技術統括・タスク管理・進捗報告      │"
echo -e "└─────────────────────────────────────┘"
echo ""
echo -e "${BOLD}${GREEN}🖥️  WORKERS ウィンドウ（2x4グリッド）${RESET}"
echo -e "┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐"
echo -e "│ ${GREEN}🎨 WORKER1${RESET}      │ ${YELLOW}⚙️ WORKER2${RESET}      │ ${MAGENTA}🧪 WORKER3${RESET}      │ ${CYAN}📚 WORKER4${RESET}      │"
echo -e "│ UI/UX Designer  │ Backend Eng     │ QA Engineer     │ Documentation   │"
echo -e "├─────────────────┼─────────────────┼─────────────────┼─────────────────┤"
echo -e "│ ${GREEN}⚡ WORKER5${RESET}      │ ${YELLOW}🔒 WORKER6${RESET}      │ ${MAGENTA}🔍 WORKER7${RESET}      │ ${CYAN}🚀 WORKER8${RESET}      │"
echo -e "│ Performance     │ Security        │ E2E Test        │ DevOps Engineer │"
echo -e "└─────────────────┴─────────────────┴─────────────────┴─────────────────┘"
echo ""
echo -e "${BOLD}✨ 新構成の利点:${RESET}"
echo -e "• ${RED}PRESIDENT${RESET}: 完全独立で戦略的意思決定に集中"
echo -e "• ${BLUE}BOSS1${RESET}: 独立ウィンドウで技術管理に専念"
echo -e "• ${GREEN}WORKERS${RESET}: 均等な2x4グリッドで全員が見やすい"
echo -e "• 役割ごとの明確な分離で効率的な作業環境"
echo ""

echo -e "${BOLD}🎯 役割分担${RESET}"
echo -e "────────────────────────────────────────────────────────────────────────"
echo -e "${RED}👑 PRESIDENT${RESET}     : プロジェクト統括・要件定義・最終承認"
echo -e "${BLUE}💼 BOSS1${RESET}         : 技術リード・タスク管理・進捗報告"
echo -e "${GREEN}🎨 WORKER1${RESET}       : UI/UXデザイン・フロントエンド実装"
echo -e "${YELLOW}⚙️ WORKER2${RESET}       : バックエンド開発・API設計・DB設計"
echo -e "${MAGENTA}🧪 WORKER3${RESET}       : 品質保証・テスト作成・バグ検証"
echo -e "${CYAN}📚 WORKER4${RESET}       : ドキュメント作成・README・開発者体験"
echo -e "${GREEN}⚡ WORKER5${RESET}       : パフォーマンス最適化・負荷テスト"
echo -e "${YELLOW}🔒 WORKER6${RESET}       : セキュリティ監査・脆弱性対策"
echo -e "${MAGENTA}🔍 WORKER7${RESET}       : E2Eテスト・統合テスト自動化"
echo -e "${CYAN}🚀 WORKER8${RESET}       : DevOps・CI/CD・デプロイ自動化"
echo ""

echo -e "${BOLD}💬 通信フロー（iTerm直接モード）${RESET}"
echo -e "────────────────────────────────────────────────────────────────────────"
echo -e "  ${RED}PRESIDENT${RESET} （独立ウィンドウ）"
echo -e "      ⇅ 直接やり取り"
echo -e "   ${BLUE}BOSS1${RESET} （独立ウィンドウ）"
echo -e "      ⇅ 直接やり取り"
echo -e "  ${GREEN}WORKERS${RESET} （グリッドウィンドウ）"
echo -e ""
echo -e "💡 各エージェントが独立したClaude Codeインスタンス"
echo -e "💡 ウィンドウ間で直接コピー&ペーストで通信"
echo ""

echo -e "${BOLD}🔧 操作コマンド${RESET}"
echo -e "────────────────────────────────────────────────────────────────────────"
echo -e "• エージェント起動: ${CYAN}./launch-iterm.sh --layout grid --workers 8${RESET}"
echo -e "• 配置ガイド表示: ${CYAN}./show-agents.sh${RESET}"
echo -e "• 各ウィンドウで直接通信: ${CYAN}各Claude Codeで直接やり取り${RESET}"
echo ""

echo -e "${BOLD}📍 iTerm操作${RESET}"
echo -e "────────────────────────────────────────────────────────────────────────"
echo -e "• ペイン移動: ${WHITE}Cmd+Option+矢印${RESET}"
echo -e "• タブ切替: ${WHITE}Cmd+数字${RESET}"
echo -e "• ウィンドウ切替: ${WHITE}Cmd+\`${RESET}"
echo -e "• 全画面: ${WHITE}Cmd+Enter${RESET}"
echo ""