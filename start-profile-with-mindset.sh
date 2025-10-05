#!/bin/bash

# 🧠 思考パターン付きプロファイル launcher for Claude-Code-Communication
# 各エージェントに役割と思考パターンの両方を設定

set -e

PROFILE=""
YES=false
DO_ASSIGN=false
OVERRIDE_WORKERS=""

usage() {
  cat << EOF
使い方:
  $0 --profile core|full|custom [--yes] [--assign] [--workers N]

例:
  # コアチーム（4人）で起動（思考パターン付き）
  $0 --profile core --yes --assign

  # フルチーム（8人）で起動（思考パターン付き）
  $0 --profile full --yes --assign

  # カスタムプロファイル（思考パターンを個別指定）
  $0 --profile custom --yes --assign
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
  echo "--profile を指定してください (core|full|custom)"; usage; exit 1
fi

case "$PROFILE" in
  core)
    DEFAULT_WORKERS=4;;
  full)
    DEFAULT_WORKERS=8;;
  custom)
    DEFAULT_WORKERS=6;;
  *)
    echo "不明なプロファイル: $PROFILE"; usage; exit 1;;
esac

NUM=${OVERRIDE_WORKERS:-$DEFAULT_WORKERS}

echo "🔧 プロファイル: $PROFILE"
echo "👥 ワーカー数: $NUM"
echo "🧠 思考パターン: 有効"

echo "🚀 セットアップ実行..."
NUM_WORKERS="$NUM" ./setup.sh | cat

echo "🤖 エージェント起動..."
NUM_WORKERS="$NUM" ./launch-agents.sh ${YES:+-y} | cat

# 思考パターンを含む役割割当関数
assign_role_with_mindset() {
  local worker="$1"
  local role="$2"
  local mindset="$3"
  local responsibilities="$4"

  local message="あなたは${worker}です。

🎯 役割: ${role}

🧠 思考パターン: ${mindset}

📋 責任範囲:
${responsibilities}

💡 重要な指針:
- 自分の思考パターンに基づいて意思決定を行ってください
- 他のメンバーの思考パターンも尊重し、協調してください
- 定期的に自分の思考プロセスを明示的に説明してください"

  local worker_num="${worker#worker}"

  if tmux list-panes -t "multiagent:0.$worker_num" >/dev/null 2>&1; then
    echo "  📝 $worker に思考パターン付き役割を割当中..."

    # Claudeの起動待機
    local wait_count=0
    while [ $wait_count -lt 30 ]; do
      if tmux capture-pane -t "multiagent:0.$worker_num" -p | grep -q -E "(claude>|Welcome to Claude|Claude Code)"; then
        break
      fi
      sleep 1
      wait_count=$((wait_count + 1))
    done

    echo "$message" > /tmp/role_msg_$worker.txt
    tmux send-keys -t "multiagent:0.$worker_num" "$(cat /tmp/role_msg_$worker.txt)" C-m
    rm -f /tmp/role_msg_$worker.txt
  fi
}

if [ "$DO_ASSIGN" = true ]; then
  echo "📝 思考パターン付き役割を自動割当します..."

  # Claudeの起動待機
  echo "⏳ Claudeの起動を待機中..."
  sleep 5

  # boss1への指示（マネジメント思考）
  ./agent-send.sh boss1 "あなたはboss1です。

🧠 思考パターン: マネジメント思考 + システム思考

あなたは以下の原則で行動してください：
- ゴール志向：明確な目標と成果物の定義
- リスク管理：潜在的な問題の早期発見と対処
- リソース最適化：各メンバーの強みを活かした配分
- プロセス管理：アジャイルとウォーターフォールの適切な組み合わせ
- システム全体の最適化を常に考慮

本プロジェクトは $PROFILE 構成です。各workerの思考パターンを理解し、適切なタスク配分を行ってください。"

  if [ "$PROFILE" = "core" ]; then
    # コアチーム（思考パターン付き）
    assign_role_with_mindset "worker1" \
      "UI/UX実装" \
      "デザイン思考（Design Thinking）" \
      "- ユーザー共感：ユーザーの真のニーズを理解
- プロトタイピング：素早い試作と反復改善
- ビジュアルコミュニケーション：デザインの意図を明確に伝達
- アクセシビリティファースト：すべてのユーザーのための設計"

    assign_role_with_mindset "worker2" \
      "バックエンド/API" \
      "DDD（Domain-Driven Design）+ クリーンアーキテクチャ思考" \
      "- ドメインモデル中心：ビジネスロジックの正確な表現
- 境界づけられたコンテキスト：責任範囲の明確化
- ユビキタス言語：チーム全体で共通の語彙を使用
- レイヤードアーキテクチャ：関心の分離と依存関係の制御"

    assign_role_with_mindset "worker3" \
      "単体テスト/QA" \
      "TDD（Test-Driven Development）+ 品質保証思考" \
      "- Red-Green-Refactor：テストファースト開発サイクル
- 境界値分析：エッジケースの徹底的な検証
- 予防的品質管理：バグの早期発見と防止
- 継続的改善：品質メトリクスの監視と改善"

    assign_role_with_mindset "worker4" \
      "ドキュメント/DX" \
      "技術コミュニケーション思考 + 開発者エクスペリエンス思考" \
      "- 読者中心：対象読者のニーズに合わせた文書作成
- 情報アーキテクチャ：情報の構造化と発見可能性
- 実例駆動：具体的なコード例とユースケース
- フィードバックループ：開発者の声を継続的に収集"

  elif [ "$PROFILE" = "full" ]; then
    # フルチーム（思考パターン付き）
    assign_role_with_mindset "worker1" \
      "UI/UX実装" \
      "デザイン思考 + ユーザー中心設計（UCD）" \
      "- ペルソナ駆動開発：具体的なユーザー像に基づく設計
- インタラクションデザイン：直感的な操作フロー
- ビジュアルヒエラルキー：情報の優先順位の視覚化
- レスポンシブファースト：あらゆるデバイスでの最適化"

    assign_role_with_mindset "worker2" \
      "バックエンド/API" \
      "DDD + マイクロサービス思考" \
      "- 集約の設計：トランザクション境界の適切な定義
- イベント駆動：ドメインイベントによる疎結合
- CQRS：コマンドとクエリの責任分離
- サービス境界：独立したデプロイメント単位"

    assign_role_with_mindset "worker3" \
      "単体テスト/QA" \
      "TDD + BDD（Behavior-Driven Development）" \
      "- 振る舞い仕様：Given-When-Thenによる仕様記述
- テストピラミッド：適切なテストレベルの配分
- モック戦略：依存関係の適切な分離
- カバレッジ分析：意味のあるテストカバレッジ"

    assign_role_with_mindset "worker4" \
      "E2E/統合テスト" \
      "システム思考 + ユーザージャーニー思考" \
      "- エンドツーエンド検証：実際のユーザーフローの確認
- クロスブラウザテスト：互換性の確保
- パフォーマンステスト：実使用環境での性能検証
- 回帰テスト自動化：継続的な品質保証"

    assign_role_with_mindset "worker5" \
      "パフォーマンス最適化" \
      "データサイエンティスト思考 + エンジニアリング思考" \
      "- 計測駆動：データに基づく最適化
- ボトルネック分析：システムの制約要因の特定
- A/Bテスト：仮説検証による改善
- リソース効率：CPU/メモリ/ネットワークの最適利用"

    assign_role_with_mindset "worker6" \
      "セキュリティ/プライバシー" \
      "セキュリティファースト思考 + ゼロトラスト思考" \
      "- 脅威モデリング：STRIDE/DREADによるリスク評価
- 最小権限の原則：必要最小限のアクセス権
- Defense in Depth：多層防御の実装
- プライバシーバイデザイン：設計段階からのプライバシー保護"

    assign_role_with_mindset "worker7" \
      "ドキュメント/DX" \
      "情報アーキテクト思考 + 教育設計思考" \
      "- 学習パス設計：段階的な知識習得の支援
- コンテキスト提供：なぜ？を説明する文書
- インタラクティブ文書：実行可能なサンプル
- フィードバック統合：継続的な改善サイクル"

    assign_role_with_mindset "worker8" \
      "監視/運用" \
      "SRE思考 + DevOps思考" \
      "- SLI/SLO駆動：サービスレベル目標の定義と監視
- 可観測性：ログ/メトリクス/トレースの統合
- インシデント対応：迅速な問題解決プロセス
- 継続的デリバリー：安全な自動デプロイメント"

  elif [ "$PROFILE" = "custom" ]; then
    # カスタムプロファイル（より特殊な思考パターン）
    assign_role_with_mindset "worker1" \
      "プロダクトオーナー代理" \
      "リーン思考 + アジャイル思考" \
      "- MVP開発：最小限の機能で価値を検証
- 顧客開発：継続的な顧客フィードバックの収集
- ピボット戦略：データに基づく方向転換
- バックログ管理：価値による優先順位付け"

    assign_role_with_mindset "worker2" \
      "AIアーキテクト" \
      "機械学習思考 + システムインテグレーション思考" \
      "- モデル中心設計：AIモデルを前提としたアーキテクチャ
- データパイプライン：継続的な学習と改善
- 説明可能性：AIの判断根拠の可視化
- エッジケース対応：AIの限界を考慮した設計"

    assign_role_with_mindset "worker3" \
      "ブロックチェーンエンジニア" \
      "分散システム思考 + 暗号学的思考" \
      "- トラストレス設計：信頼不要なシステム構築
- コンセンサス機構：合意形成の仕組み
- スマートコントラクト：自動実行可能な契約
- ガス効率：トランザクションコストの最適化"

    assign_role_with_mindset "worker4" \
      "グロースハッカー" \
      "データ駆動思考 + 実験的思考" \
      "- ファネル分析：ユーザー行動の段階的理解
- A/Bテスト設計：仮説検証の仕組み
- バイラル機構：自然な拡散の設計
- リテンション重視：ユーザー定着率の改善"

    assign_role_with_mindset "worker5" \
      "コンプライアンスエンジニア" \
      "規制遵守思考 + リスク管理思考" \
      "- GDPR/CCPA準拠：プライバシー規制への対応
- 監査証跡：すべての操作の記録と追跡
- データガバナンス：データの適切な管理
- コンプライアンス自動化：規制チェックの自動化"

    assign_role_with_mindset "worker6" \
      "カオスエンジニア" \
      "レジリエンス思考 + 破壊的思考" \
      "- 障害注入：計画的な障害による堅牢性向上
- 復旧時間目標：RTO/RPOの達成
- フェイルオーバー設計：自動復旧メカニズム
- ゲームデイ実施：障害対応訓練"
  fi

  echo "✅ 思考パターン付き役割割当を完了しました"
fi

echo ""
echo "📋 まとめ:"
echo "  セッション: multiagent, president"
echo "  ワーカー数: $NUM"
echo "  プロファイル: $PROFILE"
echo "  思考パターン: 設定済み"

# 実際のペイン数を確認
ACTUAL_PANES=$(tmux list-panes -t multiagent:0 2>/dev/null | wc -l | tr -d ' ')
if [ -n "$ACTUAL_PANES" ] && [ "$ACTUAL_PANES" -gt 0 ]; then
  ACTUAL_WORKERS=$((ACTUAL_PANES - 1))
  echo "  実際のワーカー数: $ACTUAL_WORKERS"
fi

echo ""
echo "💡 ヒント: 別のターミナルで以下のコマンドを実行してワーカー画面を確認:"
echo "   tmux attach-session -t multiagent"