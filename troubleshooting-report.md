# トラブルシューティングレポート：PRESIDENT-Worker通信問題

## 問題の診断結果

### 現在の状況
- **症状**: PRESIDENTがworkerとやり取りを行わない
- **根本原因**: PRESIDENTからboss1への指示送信方法の理解不足

### システム状態
✅ tmuxセッション: 正常（multiagent, president）
✅ ペイン構成: 正常（boss1 + worker1-8）
✅ メッセージ送信機能: 正常（agent-send.sh動作確認済み）
✅ Claude起動コマンド: 送信済み（認証待ち）

## 解決方法

### PRESIDENTからboss1への正しい指示方法

1. **PRESIDENTセッションで直接指示を入力**
   ```bash
   # PRESIDENTのClaude画面で以下を入力
   あなたはPRESIDENTです。
   boss1に対して、以下のプロジェクトを指示してください：
   「ECサイトの検索機能を高速化する。レスポンスを3秒から0.5秒以内に改善。」
   
   ./agent-send.sh boss1 "ECサイト検索高速化プロジェクトを開始してください。
   目標：レスポンス時間を3秒→0.5秒に改善
   期限：今から2時間
   必要リソース：worker1-8全員
   成功基準：検索速度0.5秒以内、同時接続1000ユーザー対応"
   ```

     5. 即座に実行できるコマンド

  PRESIDENTのClaude内で：

  # IT企業サイトプロジェクトの場合
  ./agent-send.sh boss1 "workspace変更指示：
  mkdir -p /workspace/it-company-website
  cd /workspace/it-company-website
  全workerをこのディレクトリで作業させてください。"

  # または既存のDailyBudgetプロジェクトの場合
  ./agent-send.sh boss1 "workspace変更指示：
  cd /Users/h.kitagawa/AllProject/CursourProjects/DailyBudget
  全workerをこのディレクトリで作業させてください。"

  3. 全エージェントのworkspace統一

  PRESIDENTのClaude内で以下を実行：

  # boss1に新しいworkspaceを通知
  ./agent-send.sh boss1 "作業ディレクトリを変更します。
  新workspace: /workspace/[プロジェクト名]
  全workerを新しいディレクトリに移動してください。

  mkdir -p /workspace/[プロジェクト名]
  cd /workspace/[プロジェクト名]"

  boss1が自動的に各workerに通知：
  # boss1が各workerに送信
  ./agent-send.sh worker1 "作業ディレクトリ変更：
  cd /workspace/[プロジェクト名]"

2. **PRESIDENTがboss1に送信するコマンドを実行**
   PRESIDENTのClaude内で上記の`./agent-send.sh`コマンドが実行されます

3. **boss1からworkerへの指示伝達**
   boss1が自動的に各workerに役割を割り当てます

## 重要なポイント

### ✅ 正しい通信フロー
```
PRESIDENT (Claude内でagent-sendコマンド実行)
    ↓
boss1 (指示を受信し、タスク分解)
    ↓
worker1-8 (各自の役割で実行)
    ↓
boss1 (進捗集約)
    ↓
PRESIDENT (報告受信)
```

### ❌ よくある間違い
- PRESIDENTの外部からagent-sendを使う（PRESIDENTのClaude内で実行する必要がある）
- boss1を経由せずに直接workerに指示を送る
- Claude認証前にメッセージを送信する

## 確認手順

1. **PRESIDENT画面を確認**
   ```bash
   tmux attach-session -t president
   ```
   - Claudeが起動し、認証が完了していることを確認
   - `claude@`プロンプトが表示されていることを確認

2. **boss1画面を確認**
   ```bash
   tmux attach-session -t multiagent
   tmux select-pane -t multiagent:0.0
   ```
   - boss1のClaudeが起動していることを確認
   - PRESIDENTからのメッセージを待機中であることを確認

3. **通信テスト**
   PRESIDENTのClaude内で：
   ```bash
   ./agent-send.sh boss1 "テストメッセージ：通信確認"
   ```
   boss1画面でメッセージが表示されることを確認

## トラブルシューティング

### Claude認証が完了していない場合
1. 各ペインでブラウザ認証を完了
2. 認証後、各エージェントに役割を再送信：
   ```bash
   ./agent-send.sh president "あなたはPRESIDENTです。プロジェクト統括責任者として行動してください。"
   ./agent-send.sh boss1 "あなたはboss1です。テックリードとしてworkerを管理してください。"
   ```

### メッセージが届かない場合
1. tmuxペインが正しく存在するか確認：
   ```bash
   tmux list-panes -t multiagent:0
   ```
2. agent-send.shの動作確認：
   ```bash
   ./agent-send.sh --list
   ```

## 推奨される次のアクション

1. PRESIDENTセッションにアタッチ
2. Claude認証を完了
3. PRESIDENTのClaude内でboss1への指示を送信
4. boss1の画面でメッセージ受信を確認
5. プロジェクトを開始

これらの手順により、PRESIDENT-Worker間の通信が正常に機能するはずです。
