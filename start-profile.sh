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
    ./agent-send.sh "$worker" "$role_msg"
  else
    echo "⚠️ $worker のペインが存在しないため、スキップします"
  fi
}

if [ "$DO_ASSIGN" = true ]; then
  echo "📝 役割を自動割当します（Claudeの認証完了後に有効）..."
  sleep 1
  # boss1 へ全体方針
  ./agent-send.sh boss1 "あなたはboss1です。\n本プロジェクトは $PROFILE 構成で開始します。\n各workerに役割を割り当て、10分ごとの進捗確認を実施してください。"

  if [ "$PROFILE" = "core" ]; then
    # コア（4人想定）
    assign_role worker1 "あなたはworker1です。役割: UI/UX実装。\n主担当: デザインシステム/レスポンシブ/アクセシビリティ。\n成果: 主要ページのUI実装と簡易コンポーネント。"
    assign_role worker2 "あなたはworker2です。役割: バックエンド/API。\n主担当: APIエンドポイント/データモデル/永続化の骨組み。\n成果: CRUDの最小実装とヘルスチェック。"
    assign_role worker3 "あなたはworker3です。役割: 単体テスト/QA。\n主担当: ユニットテスト・lint・基本CIの整備。\n成果: 主要ユースケースのテストカバレッジ確保。"
    assign_role worker4 "あなたはworker4です。役割: ドキュメント/DX。\n主担当: README/起動手順/開発ガイド。\n成果: 初見でも10分で開発に参加できる状態。"
    # 5,6 がいる場合の拡張（任意）
    if [ "$NUM" -ge 5 ]; then
      assign_role worker5 "あなたはworker5です。役割: UI/パフォーマンス改善（任意）。\n主担当: Core Web Vitalsの初期改善。"
    fi
    if [ "$NUM" -ge 6 ]; then
      assign_role worker6 "あなたはworker6です。役割: セキュリティ基盤（任意）。\n主担当: 基本的な入力検証/ヘッダ/依存脆弱性チェック。"
    fi
  else
    # フル（8人想定）
    assign_role worker1 "あなたはworker1です。役割: UI/UX実装。\n主担当: デザインシステム/レスポンシブ/アクセシビリティ。"
    assign_role worker2 "あなたはworker2です。役割: バックエンド/API。\n主担当: API設計/データモデル/永続化/エラーハンドリング。"
    assign_role worker3 "あなたはworker3です。役割: 単体テスト/QA。\n主担当: ユニットテスト/モック/lint/基本CI。"
    assign_role worker4 "あなたはworker4です。役割: E2E/回帰テスト。\n主担当: 主要導線の自動E2E・回帰セット整備。"
    assign_role worker5 "あなたはworker5です。役割: パフォーマンス最適化。\n主担当: LCP/CLS/INP/レイテンシの改善。"
    assign_role worker6 "あなたはworker6です。役割: セキュリティ/プライバシー。\n主担当: 認証・認可・PII保護・ヘッダ設定。"
    assign_role worker7 "あなたはworker7です。役割: ドキュメント/DX。\n主担当: ガイド/テンプレ/サンプル/オンボーディング整備。"
    assign_role worker8 "あなたはworker8です。役割: 監視/運用。\n主担当: ログ/メトリクス/アラート/稼働監視の初期設定。"
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
