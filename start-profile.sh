#!/bin/bash

# 🌟 Profile launcher for Claude-Code-Communication
# core: 4人で開始（UI/API/単体テスト/ドキュメント）
# full: 8人に拡張（E2E/性能/セキュリティ/監視 追加）

set -e

PROFILE=""
YES=false
DO_ASSIGN=false
OVERRIDE_WORKERS=""

usage() {
  cat << EOF
使い方:
  $0 --profile core|full [--yes] [--assign] [--workers N]

例:
  # コアチーム（4人）で起動
  $0 --profile core --yes

  # フルチーム（8人）で起動し、役割を自動割当
  $0 --profile full --yes --assign

  # ワーカー数を明示的に上書き
  $0 --profile core --workers 6 --yes
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"; shift 2;;
    --yes|-y)
      YES=true; shift;;
    --assign)
      DO_ASSIGN=true; shift;;
    --workers)
      OVERRIDE_WORKERS="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "不明な引数: $1"; usage; exit 1;;
  esac
done

if [ -z "$PROFILE" ]; then
  echo "--profile を指定してください (core|full)"; usage; exit 1
fi

case "$PROFILE" in
  core)
    DEFAULT_WORKERS=4;;
  full)
    DEFAULT_WORKERS=8;;
  *)
    echo "不明なプロファイル: $PROFILE"; usage; exit 1;;
esac

NUM=${OVERRIDE_WORKERS:-$DEFAULT_WORKERS}
if ! [[ "$NUM" =~ ^[0-9]+$ ]]; then
  echo "--workers の値が不正です: $NUM"; exit 1
fi
if [ "$NUM" -lt 1 ]; then NUM=1; fi

echo "🔧 プロファイル: $PROFILE"
echo "👥 ワーカー数: $NUM"

echo "🚀 セットアップ実行..."
NUM_WORKERS="$NUM" ./setup.sh | cat

echo "🤖 エージェント起動..."
NUM_WORKERS="$NUM" ./launch-agents.sh ${YES:+-y} | cat

assign_role() {
  local worker="$1"; shift
  local role_msg="$*"

  # workerのペイン番号を取得
  local worker_num="${worker#worker}"

  # ペインが存在するか確認
  if tmux list-panes -t "multiagent:0.$worker_num" >/dev/null 2>&1; then
    # Claudeが起動するまで待機（最大30秒）
    echo "  ⏳ $worker のClaude起動を待機中..."
    local wait_count=0
    while [ $wait_count -lt 30 ]; do
      # プロンプトが表示されているかチェック（Claudeが起動済みの場合）
      if tmux capture-pane -t "multiagent:0.$worker_num" -p | grep -q "claude>" || \
         tmux capture-pane -t "multiagent:0.$worker_num" -p | grep -q "Welcome to Claude"; then
        break
      fi
      sleep 1
      wait_count=$((wait_count + 1))
    done

    # 改行文字を実際の改行に変換してメッセージを送信
    echo "$role_msg" | sed 's/\\n/\n/g' > /tmp/role_msg_$worker.txt
    tmux send-keys -t "multiagent:0.$worker_num" "$(cat /tmp/role_msg_$worker.txt)" C-m
    rm -f /tmp/role_msg_$worker.txt
  else
    echo "⚠️ $worker のペインが存在しないため、スキップします"
  fi
}

if [ "$DO_ASSIGN" = true ]; then
  echo "📝 役割を自動割当します..."

  # Claudeの起動を待機（最大60秒）
  echo "⏳ Claudeの起動を待機中（最大60秒）..."
  total_wait=0
  all_ready=false

  while [ $total_wait -lt 60 ]; do
    all_ready=true

    # boss1のチェック
    if ! tmux capture-pane -t "multiagent:0.0" -p 2>/dev/null | grep -q -E "(claude>|Welcome to Claude|Claude Code)"; then
      all_ready=false
    fi

    # 各workerのチェック
    for i in $(seq 1 "$NUM"); do
      if ! tmux capture-pane -t "multiagent:0.$i" -p 2>/dev/null | grep -q -E "(claude>|Welcome to Claude|Claude Code)"; then
        all_ready=false
        break
      fi
    done

    if [ "$all_ready" = true ]; then
      echo "✅ 全エージェントのClaude起動を確認しました"
      break
    fi

    sleep 2
    total_wait=$((total_wait + 2))
  done

  if [ "$all_ready" = false ]; then
    echo "⚠️ 一部のClaudeが起動していません。手動で起動後、役割を割り当ててください。"
  fi

  sleep 2

  # boss1 へ全体方針
  ./agent-send.sh boss1 "あなたはboss1です。本プロジェクトは $PROFILE 構成で開始します。各workerに役割を割り当て、10分ごとの進捗確認を実施してください。"

  if [ "$PROFILE" = "core" ]; then
    # コア（4人想定）
    assign_role worker1 "あなたはworker1です。役割: UI/UX実装。主担当: デザインシステム/レスポンシブ/アクセシビリティ。成果: 主要ページのUI実装と簡易コンポーネント。"
    assign_role worker2 "あなたはworker2です。役割: バックエンド/API。主担当: APIエンドポイント/データモデル/永続化の骨組み。成果: CRUDの最小実装とヘルスチェック。"
    assign_role worker3 "あなたはworker3です。役割: 単体テスト/QA。主担当: ユニットテスト・lint・基本CIの整備。成果: 主要ユースケースのテストカバレッジ確保。"
    assign_role worker4 "あなたはworker4です。役割: ドキュメント/DX。主担当: README/起動手順/開発ガイド。成果: 初見でも10分で開発に参加できる状態。"
    # 5,6 がいる場合の拡張（任意）
    if [ "$NUM" -ge 5 ]; then
      assign_role worker5 "あなたはworker5です。役割: UI/パフォーマンス改善（任意）。主担当: Core Web Vitalsの初期改善。"
    fi
    if [ "$NUM" -ge 6 ]; then
      assign_role worker6 "あなたはworker6です。役割: セキュリティ基盤（任意）。主担当: 基本的な入力検証/ヘッダ/依存脆弱性チェック。"
    fi
  else
    # フル（8人想定）
    assign_role worker1 "あなたはworker1です。役割: UI/UX実装。主担当: デザインシステム/レスポンシブ/アクセシビリティ。"
    assign_role worker2 "あなたはworker2です。役割: バックエンド/API。主担当: API設計/データモデル/永続化/エラーハンドリング。"
    assign_role worker3 "あなたはworker3です。役割: 単体テスト/QA。主担当: ユニットテスト/モック/lint/基本CI。"
    assign_role worker4 "あなたはworker4です。役割: E2E/回帰テスト。主担当: 主要導線の自動E2E・回帰セット整備。"
    assign_role worker5 "あなたはworker5です。役割: パフォーマンス最適化。主担当: LCP/CLS/INP/レイテンシの改善。"
    assign_role worker6 "あなたはworker6です。役割: セキュリティ/プライバシー。主担当: 認証・認可・PII保護・ヘッダ設定。"
    assign_role worker7 "あなたはworker7です。役割: ドキュメント/DX。主担当: ガイド/テンプレ/サンプル/オンボーディング整備。"
    assign_role worker8 "あなたはworker8です。役割: 監視/運用。主担当: ログ/メトリクス/アラート/稼働監視の初期設定。"
  fi

  echo "✅ 役割割当コマンドの送信を完了しました（未認証の場合は送信が失敗することがあります）。"
fi

echo "📋 まとめ:"
echo "  セッション: multiagent, president"
echo "  要求ワーカー数: $NUM"

# 実際のペイン数を確認
ACTUAL_PANES=$(tmux list-panes -t multiagent:0 2>/dev/null | wc -l | tr -d ' ')
if [ -n "$ACTUAL_PANES" ] && [ "$ACTUAL_PANES" -gt 0 ]; then
  ACTUAL_WORKERS=$((ACTUAL_PANES - 1))
  echo "  実際のワーカー数: $ACTUAL_WORKERS (boss1 + worker1-$ACTUAL_WORKERS)"
  if [ "$ACTUAL_WORKERS" -lt "$NUM" ]; then
    echo "  ⚠️ 注意: スペース不足により、一部のワーカーが作成されませんでした"
  fi
else
  echo "  ⚠️ multiagentセッションが見つかりません"
fi

echo "  役割割当: ${DO_ASSIGN}"

# 自動的にワーカーの画面を新しいターミナルウィンドウで開く
echo ""
echo "🖥️ ワーカー画面を開きます..."

# macOSの場合、新しいターミナルウィンドウでmultiagentセッションを開く
if [[ "$OSTYPE" == "darwin"* ]]; then
  # iTerm2が利用可能で、複数ワーカーの場合は専用レイアウトを提案
  if command -v osascript &> /dev/null && osascript -e 'tell application "System Events" to return exists application process "iTerm"' &>/dev/null 2>&1; then
    if [ "$NUM" -gt 4 ]; then
      echo "💡 多数のワーカーを見やすく表示するには:"
      echo "   ./launch-iterm.sh --layout grid --workers $NUM --profile $PROFILE"
      echo ""
      echo "または通常のiTermウィンドウで開く場合:"
    fi

    # iTerm2の場合
    osascript -e 'tell application "iTerm"
      create window with default profile
      tell current session of current window
        write text "tmux attach-session -t multiagent"
      end tell
    end tell' 2>/dev/null || true
    echo "✅ ワーカー画面を新しいiTermウィンドウで開きました"
  elif [[ -n "$ITERM_SESSION_ID" ]]; then
    # iTerm2内から実行している場合
    osascript -e 'tell application "iTerm"
      create window with default profile
      tell current session of current window
        write text "tmux attach-session -t multiagent"
      end tell
    end tell' 2>/dev/null || true
    echo "✅ ワーカー画面を新しいiTermウィンドウで開きました"
  else
    # Terminal.appの場合
    osascript -e 'tell application "Terminal"
      do script "tmux attach-session -t multiagent"
    end tell' 2>/dev/null || true
    echo "✅ ワーカー画面を新しいターミナルウィンドウで開きました"
  fi
else
  # Linux/他のOSの場合のヒント表示
  echo "💡 別のターミナルで以下のコマンドを実行してワーカー画面を開いてください:"
  echo "   tmux attach-session -t multiagent"
fi
