# 👑 PRESIDENT Claude Code エージェント動作ガイド

## ⚠️ 重要：あなたがClaudeとして動作している場合

プレジデントとしてClaudeで動作している場合、boss1やworkerに指示を送るには以下の方法を使用してください：

## 方法1: Bashツールを使用（推奨）

Claudeとして動作している場合は、Bashツールから`agent-send.sh`を実行します：

```bash
# boss1に指示を送る例
bash -c "cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh boss1 'タスクを開始してください'"

# または絶対パスで実行
/Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication/agent-send.sh boss1 "指示内容"
```

## 具体的な指示の送り方

### 1. boss1への基本的な指示

```bash
# Bashツールで実行
cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh boss1 "あなたはboss1です。新しいプロジェクトを開始します。タスクをworker1-3に割り当ててください。"
```

### 2. 複雑なタスクの指示

```bash
# 複数行のメッセージを送る場合
cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh boss1 "あなたはboss1です。プロジェクト名: AIチャットボット開発。Phase 1: UI設計（worker1）、Phase 2: バックエンド実装（worker2）、Phase 3: テスト（worker3）。各workerに具体的なタスクを割り当ててください。"
```

### 3. 緊急指示

```bash
cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh boss1 "【緊急】本番環境で問題が発生しています。全workerを緊急対応モードに切り替えてください。"
```

## 実践的なワークフロー

### ステップ1: プロジェクト要件を定義
```bash
# 要件定義書を作成
cat > /workspace/project/requirements.md << 'EOF'
# プロジェクト要件
- 機能A: ユーザー認証
- 機能B: データ管理
- 機能C: レポート生成
EOF
```

### ステップ2: boss1に指示を送信
```bash
cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh boss1 "あなたはboss1です。/workspace/project/requirements.mdの要件に基づいてタスクを分解し、worker1-3に割り当ててください。"
```

### ステップ3: 進捗確認
```bash
# ステータスを確認
cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./dashboard.sh
```

## トラブルシューティング

### Q: 指示が送信されない場合

1. **tmuxセッションの確認**
```bash
tmux list-sessions
```

2. **エージェントの起動確認**
```bash
tmux capture-pane -t multiagent:0.0 -p | tail -n 5
```

3. **手動で指示を再送信**
```bash
cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh boss1 "テスト送信"
```

### Q: boss1が応答しない場合

boss1のペインを直接確認：
```bash
tmux attach-session -t multiagent
# Ctrl+B, 0 でboss1のペインに切り替え
```

## プレジデントとしての基本動作

1. **プロジェクト開始時**
   - 要件を明確化
   - タスクリストを作成
   - boss1に指示を送信

2. **実行中**
   - 30分ごとに進捗確認
   - 問題があれば介入
   - 優先順位の調整

3. **完了時**
   - 成果物の確認
   - 品質チェック
   - 次のフェーズへ

## 便利なエイリアス設定（任意）

~/.zshrc または ~/.bashrc に追加すると便利：

```bash
alias send-boss='cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh boss1'
alias send-worker1='cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./agent-send.sh worker1'
alias check-status='cd /Users/h.kitagawa/Dropbox/Development/projects/AICompany/Claude-Code-Communication && ./dashboard.sh'
```

## 重要な注意事項

⚠️ **Claudeとして動作している場合は、直接シェルコマンドを入力することはできません。必ずBashツールを使用してください。**

⚠️ **改行を含む長いメッセージは、一行にまとめて送信してください。**

⚠️ **tmuxセッションが起動していることを確認してから送信してください。**