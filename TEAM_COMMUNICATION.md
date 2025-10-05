# 🤝 チーム双方向通信システム

## 概要

マルチエージェントシステムにおける完全な双方向通信を実現します。

### アーキテクチャ

```
PRESIDENT (統括責任者)
    ↓ 指示
ARCHITECT (設計統括)
    ↓ タスク分割
8 WORKERS (実装担当)
  - FRONTEND (🎨 UI/UX実装)
  - BACKEND (⚙️ サーバー実装)
  - DATABASE (🗄️ DB設計実装)
  - SECURITY (🔒 セキュリティ実装)
  - TESTING (🧪 テスト実装)
  - DEPLOY (🚀 デプロイ実装)
  - DOCS (📚 ドキュメント作成)
  - QA (🔍 品質保証)
    ↓ レビュー依頼
2 REVIEWERS (レビュー担当)
  - REVIEWER_A (🔍 品質レビュー)
  - REVIEWER_B (🛡️ セキュリティレビュー)
    ↓ レビュー結果
ARCHITECT → PRESIDENT (完了報告)
```

## 主要コンポーネント

### 1. メッセージキューシステム (`message-queue.sh`)

エージェント間のメッセージ送受信を管理します。

#### 初期化
```bash
./message-queue.sh init
```

#### メッセージ送信
```bash
./message-queue.sh send <FROM> <TO> "<MESSAGE>"

# 例
./message-queue.sh send PRESIDENT ARCHITECT "システム設計を開始してください"
./message-queue.sh send ARCHITECT FRONTEND "UIを実装してください"
./message-queue.sh send FRONTEND REVIEWER_A "UIのレビューをお願いします"
```

#### 受信メッセージ確認
```bash
./message-queue.sh list <AGENT>

# 例
./message-queue.sh list ARCHITECT
./message-queue.sh list REVIEWER_A
```

#### メッセージ読み取り
```bash
./message-queue.sh read <AGENT> <MESSAGE_NUMBER>

# 例
./message-queue.sh read ARCHITECT 1
```

#### 統計情報
```bash
./message-queue.sh stats
```

### 2. 応答監視システム (`response-monitor.sh`)

エージェントからの応答を自動監視し、通知します。

#### バックグラウンド監視開始
```bash
./response-monitor.sh start
```

#### 特定エージェントのみ監視
```bash
./response-monitor.sh monitor <AGENT>

# 例
./response-monitor.sh monitor ARCHITECT
./response-monitor.sh monitor REVIEWER_A
```

#### 応答ログ確認
```bash
./response-monitor.sh log <AGENT>

# 例
./response-monitor.sh log FRONTEND
./response-monitor.sh log REVIEWER_B
```

#### 監視停止
```bash
./response-monitor.sh stop
```

### 3. チーム連携ワークフロー (`team-workflow.sh`)

標準的なワークフローを自動化します。

#### 完全ワークフロー開始
```bash
./team-workflow.sh start "<プロジェクト要件>"

# 例
./team-workflow.sh start "ECサイトのログイン機能を実装してください"
```

これは以下のステップを自動実行します：
1. PRESIDENT → ARCHITECT（要件伝達）
2. ARCHITECT → 8 WORKERS（タスク分割）
3. WORKERS → REVIEWERS（レビュー依頼）
4. REVIEWERS → ARCHITECT（レビュー結果報告）
5. ARCHITECT → PRESIDENT（完了報告）

#### 個別ワークフロー実行

```bash
# PRESIDENT → ARCHITECT
./team-workflow.sh p2a "ユーザー認証機能を実装してください"

# ARCHITECT → WORKERS
./team-workflow.sh a2w "JWT認証を使用したログインシステムを設計しました"

# WORKERS → REVIEWERS
./team-workflow.sh w2r "全機能の実装が完了しました"

# REVIEWERS → ARCHITECT
./team-workflow.sh r2a "品質・セキュリティともに問題ありません"

# ARCHITECT → PRESIDENT
./team-workflow.sh a2p "プロジェクト完了、全テスト通過しました"
```

#### ステップ実行

```bash
./team-workflow.sh step2 "設計書の内容"
./team-workflow.sh step3 "実装内容"
./team-workflow.sh step4 "レビュー結果"
./team-workflow.sh step5 "完了報告"
```

#### ワークフロー状態確認
```bash
./team-workflow.sh status
```

## 使用例

### シナリオ1: 新機能開発

```bash
# 1. システム初期化
./message-queue.sh init
./response-monitor.sh start

# 2. PRESIDENTからの指示
./team-workflow.sh p2a "ECサイトのカート機能を実装してください"

# 3. ARCHITECTの応答を確認
./message-queue.sh list ARCHITECT
./response-monitor.sh log ARCHITECT

# 4. WORKERSへタスク分割
./team-workflow.sh a2w "カート機能の設計書: ..."

# 5. 各WORKERの進捗確認
./message-queue.sh stats

# 6. 実装完了後、REVIEWERSへレビュー依頼
./team-workflow.sh w2r "カート機能の実装完了"

# 7. レビュー結果確認
./message-queue.sh list REVIEWER_A
./message-queue.sh list REVIEWER_B

# 8. レビュー完了報告
./team-workflow.sh r2a "レビュー完了、問題なし"

# 9. PRESIDENTへ最終報告
./team-workflow.sh a2p "カート機能完成、全テスト通過"
```

### シナリオ2: バグ修正ワークフロー

```bash
# 1. セキュリティ問題の報告
./message-queue.sh send REVIEWER_B SECURITY "XSS脆弱性を発見しました"

# 2. SECURITYの受信確認
./message-queue.sh list SECURITY
./message-queue.sh read SECURITY 1

# 3. 修正後、再レビュー依頼
./message-queue.sh send SECURITY REVIEWER_B "XSS対策を実装しました"

# 4. レビュー結果確認
./message-queue.sh list REVIEWER_B
```

### シナリオ3: 品質改善

```bash
# 1. QAからの指摘
./message-queue.sh send QA REVIEWER_A "コード品質の総合レビューをお願いします"

# 2. レビュー依頼を各WORKERSに展開
./message-queue.sh send REVIEWER_A FRONTEND "UIコードの品質確認"
./message-queue.sh send REVIEWER_A BACKEND "APIコードの品質確認"
./message-queue.sh send REVIEWER_A DATABASE "スキーマの品質確認"

# 3. 各WORKERの改善結果を確認
./response-monitor.sh monitor FRONTEND
```

## メッセージキューの特徴

### 1. 永続化
すべてのメッセージはファイルとして保存され、セッション終了後も確認可能

### 2. アーカイブ機能
読み取ったメッセージは自動的にアーカイブに移動

### 3. タイムスタンプ
全メッセージに送信時刻を記録

### 4. 双方向性
送信と受信の両方をサポート

### 5. tmux統合
メッセージはtmuxペインにもリアルタイム表示

## ディレクトリ構造

```
message-queue/
├── inbox/           # 受信メッセージ
│   ├── president/
│   ├── architect/
│   ├── worker1/     # FRONTEND
│   ├── worker2/     # BACKEND
│   ├── worker3/     # DATABASE
│   ├── worker4/     # SECURITY
│   ├── worker5/     # TESTING
│   ├── worker6/     # DEPLOY
│   ├── worker7/     # DOCS
│   ├── worker8/     # QA
│   ├── reviewer_a/
│   └── reviewer_b/
├── outbox/          # 送信メッセージ（将来の拡張用）
├── archive/         # 読み取り済みメッセージ
└── tracking/        # 応答監視データ
```

## トラブルシューティング

### メッセージが届かない

```bash
# 1. キューが初期化されているか確認
./message-queue.sh stats

# 2. エージェント名が正しいか確認
./agent-send.sh --list

# 3. tmuxセッションが起動しているか確認
tmux list-sessions
```

### 応答が検出されない

```bash
# 1. 監視プロセスが起動しているか確認
./team-workflow.sh status

# 2. 手動で監視開始
./response-monitor.sh start

# 3. 特定エージェントの出力を直接確認
tmux attach -t multiagent:0.1  # FRONTEND
```

### メッセージが溜まりすぎた

```bash
# 全エージェントのinboxをクリア（アーカイブに移動）
for agent in PRESIDENT ARCHITECT FRONTEND BACKEND DATABASE SECURITY TESTING DEPLOY DOCS QA REVIEWER_A REVIEWER_B; do
    ./message-queue.sh clear "$agent"
done
```

## ベストプラクティス

### 1. 応答監視は常に起動
```bash
./response-monitor.sh start
```

### 2. 定期的に統計確認
```bash
./message-queue.sh stats
./team-workflow.sh status
```

### 3. 重要なメッセージはアーカイブを確認
```bash
ls -la message-queue/archive/architect/
```

### 4. REVIEWERSは必ず最終チェックに活用
```bash
# 実装完了後、必ずレビュー依頼
./team-workflow.sh w2r "実装内容の説明"
```

## 今後の拡張予定

- [ ] Webダッシュボード
- [ ] Slack/Discord統合
- [ ] メッセージ検索機能
- [ ] 自動応答機能
- [ ] メッセージテンプレート
- [ ] ワークフロー統計レポート

## 関連ドキュメント

- [CLAUDE.md](CLAUDE.md) - システム全体の概要
- [const/README.md](const/README.md) - 定数管理システム
- [PRESIDENT_GUIDE.md](PRESIDENT_GUIDE.md) - PRESIDENT用ガイド

## サポート

問題が発生した場合は、以下を確認してください：

1. `./message-queue.sh stats` でシステム状態確認
2. `./team-workflow.sh status` でワークフロー状態確認
3. ログファイル確認: `message-queue/monitor.log`
