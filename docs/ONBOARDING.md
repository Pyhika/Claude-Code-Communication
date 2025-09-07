# 🚀 オンボーディングガイド

## 🎯 このシステムを使い始める前に

### 10秒で理解する
**AIエージェント通信システム**は、複数のAIが会社のように協力して開発を進めるシステムです。
- 👑 社長（PRESIDENT）が指示
- 🎯 マネージャー（boss1）が管理
- 👷 作業者（worker1-7）が実装

### なぜこのシステムが革新的なのか？
1. **並列処理**: 複数のAIが同時に異なるタスクを実行
2. **専門性の活用**: 各エージェントが特定分野に特化
3. **自律的な協調**: 人間の介入を最小限に自動で連携

## 📝 チェックリスト（5分で完了）

### ステップ1: 環境確認（1分）
```bash
# 必須ツールの確認
which tmux    # ターミナル分割ツール
which claude  # Claude Code CLI

# バージョン確認
tmux -V       # 2.0以上推奨
claude --version
```

### ステップ2: セットアップ（2分）
```bash
# リポジトリをクローン
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication

# 環境構築（自動）
./setup.sh

# カスタム設定例
NUM_WORKERS=5 ./setup.sh  # ワーカー数を5に
```

### ステップ3: 起動（2分）
```bash
# 方法A: 個別起動
tmux attach -t president
claude --dangerously-skip-permissions

# 方法B: 一括起動（推奨）
./start-profile.sh --profile core --yes --assign
```

## 🎭 あなたの役割を選ぶ

### 初心者向け → **社長（PRESIDENT）**
```bash
tmux attach -t president
```
最初のプロジェクト例：
```
あなたはpresidentです。シンプルなTODOアプリを作ってください。
```

### 技術者向け → **マネージャー（boss1）**
```bash
tmux attach -t boss1
```
タスク管理とチーム統括を体験できます。

### 実装者向け → **ワーカー（worker1-7）**
```bash
tmux attach -t worker1  # フロントエンド
tmux attach -t worker2  # バックエンド
tmux attach -t worker3  # インフラ
```

## 🔥 最初の30分でマスターする

### 15分目標: Hello Worldプロジェクト
1. PRESIDENTで指示
   ```
   あなたはpresidentです。
   「Hello, AI Company!」を表示するWebページを作って。
   ```
2. 自動的に展開される様子を観察
3. 結果を確認

### 30分目標: 実用アプリケーション
1. より複雑な指示を試す
   ```
   あなたはpresidentです。
   ユーザー登録機能付きのタスク管理アプリを作って。
   ```
2. 各エージェントの動きを理解
3. カスタマイズポイントを発見

## 💡 プロのコツ

### 効率を最大化する設定
```bash
# 並列処理を増やす
NUM_WORKERS=7 ./setup.sh

# 高速モデルを使用
AGENT_CMD="claude" AGENT_ARGS="--model claude-3-haiku" ./launch-agents.sh -y
```

### デバッグとモニタリング
```bash
# リアルタイムダッシュボード
./dashboard.sh

# ログ監視
tail -f logs/send_log.txt

# エージェント状態確認
./project-status.sh
```

### トラブル時の対処
```bash
# 完全リセット
tmux kill-server
rm -rf ./tmp/*
./setup.sh

# 特定エージェントのみ再起動
tmux kill-session -t worker1
tmux new-session -d -s worker1
```

## 📚 次のステップ

### レベル1: 基本操作をマスター
- [ ] 5つの簡単なプロジェクトを完了
- [ ] 各エージェントの役割を理解
- [ ] メッセージ送信を習得

### レベル2: カスタマイズと拡張
- [ ] 新しいワーカーロールを追加
- [ ] カスタム指示書を作成
- [ ] テンプレートを活用

### レベル3: 本格運用
- [ ] CI/CDパイプライン統合
- [ ] 実プロジェクトへの適用
- [ ] チーム開発での活用

## 🆘 困ったときは

### よくある質問と解決策

**Q: エージェントが応答しない**
```bash
# エージェントの状態確認
tmux ls
# 該当セッションに入って状態確認
tmux attach -t [セッション名]
```

**Q: メッセージが届かない**
```bash
# 送信ログを確認
cat logs/send_log.txt | tail -20
# テスト送信
./agent-send.sh boss1 "テストメッセージ"
```

**Q: パフォーマンスが遅い**
```bash
# ワーカー数を調整
NUM_WORKERS=3 ./setup.sh  # 減らす
# モデルを軽量化
AGENT_ARGS="--model claude-3-haiku"
```

## 📞 サポート

- **GitHub Issues**: [問題報告](https://github.com/nishimoto265/Claude-Code-Communication/issues)
- **ドキュメント**: `/docs`ディレクトリ参照
- **コミュニティ**: Discord（準備中）

---

*このガイドは5分で読めるよう最適化されています。詳細は各種ドキュメントをご覧ください。*