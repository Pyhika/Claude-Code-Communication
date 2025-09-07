# 🤖 Claude Code エージェント通信システム

複数のAIが協力して働く、まるで会社のような開発システムです

## 📌 これは何？

**3行で説明すると：**
1. 複数のAIエージェント（社長・マネージャー・作業者）が協力して開発
2. それぞれ異なるターミナル画面で動作し、メッセージを送り合う
3. 人間の組織のように役割分担して、効率的に開発を進める

**実際の成果：**
- 3時間で完成したアンケートシステム（EmotiFlow）
- 12個の革新的アイデアを生成
- 100%のテストカバレッジ

## 🎬 5分で動かしてみよう！

### 必要なもの
- Mac または Linux
- tmux（ターミナル分割ツール）
- Claude Code CLI
- （任意）gum または fzf（ダッシュボード用）

### 手順

#### 1️⃣ ダウンロード（30秒）
```bash
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication
```

#### 2️⃣ 環境構築（1分）
```bash
./setup.sh
```
- 依存チェック: `tmux` と `claude` コマンドの存在とバージョンを自動確認します
- エラー時はインストール方法リンクを提示します
- `NUM_WORKERS` でワーカー数を可変にできます（デフォルト 3）
  - 例: `NUM_WORKERS=5 ./setup.sh`

これでバックグラウンドに5つのターミナル画面が準備されます！

#### 3️⃣ 社長画面を開いてAI起動（2分）

**社長画面を開く：**
```bash
tmux attach-session -t president
```

**社長画面でClaudeを起動：**
```bash
# ブラウザで認証が必要
claude --dangerously-skip-permissions
```

#### 4️⃣ 部下たちを一括起動（1分）

新しいターミナルで：
```bash
# 既定（Claude）
./launch-agents.sh -y

# ほかのモデル/クライアントを使う例（マルチモデル対応）
AGENT_CMD="claude" AGENT_ARGS="--dangerously-skip-permissions" ./launch-agents.sh -y
# OpenAI やローカルLLMなどに差し替えも可
```
- `NUM_WORKERS` を合わせて設定すると、起動対象も自動で増減します

NUM_WORKERSと同時指定の例:
```bash
NUM_WORKERS=5 AGENT_CMD="claude" AGENT_ARGS="--dangerously-skip-permissions" ./launch-agents.sh -y
```

#### 5️⃣ ダッシュボード（任意）
```bash
./dashboard.sh
```
- エージェント一覧/状態/最近ログの確認
- テンプレ選択送信・自由入力送信（`templates/*.txt`）
- 依存: `gum` または `fzf`（未インストールなら `brew install gum` または `brew install fzf`）

#### 6️⃣ 魔法の言葉を入力（30秒）

そして入力：
```
あなたはpresidentです。おしゃれな充実したIT企業のホームページを作成して。
```

**すると自動的に：**
1. 社長がマネージャーに指示
2. マネージャーが3人の作業者に仕事を割り振り
3. みんなで協力して開発
4. 完成したら社長に報告

## 🧭 役割別スラッシュコマンド（/sc）
Claude Code上で、次のように役割ガイドを呼び出せます。
```
/sc:president:guide
/sc:boss1:guide
/sc:worker:guide
```
- コマンド定義は `.claude/commands/` に配置（サブディレクトリが名前空間）

## 🏢 登場人物（エージェント）

### 👑 社長（PRESIDENT）
- **役割**: 全体の方針を決める
- **特徴**: ユーザーの本当のニーズを理解する天才
- **口癖**: 「このビジョンを実現してください」

### 🎯 マネージャー（boss1）
- **役割**: チームをまとめる中間管理職
- **特徴**: メンバーの創造性を引き出す達人
- **口癖**: 「革新的なアイデアを3つ以上お願いします」

### 👷 作業者たち（worker1, 2, 3）
- **worker1**: デザイン担当（UI/UX）
- **worker2**: データ処理担当
- **worker3**: テスト担当

## 💬 どうやってコミュニケーションする？

### メッセージの送り方
```bash
./agent-send.sh [相手の名前] "[メッセージ]"

# 例：マネージャーに送る
./agent-send.sh boss1 "新しいプロジェクトです"

# 例：作業者1に送る
./agent-send.sh worker1 "UIを作ってください"
```
- `./agent-send.sh --list` は tmux の実ペイン/`NUM_WORKERS` に連動して動的に変化します

### 実際のやり取りの例

**社長 → マネージャー：**
```
あなたはboss1です。

【プロジェクト名】アンケートシステム開発

【ビジョン】
誰でも簡単に使えて、結果がすぐ見られるシステム

【成功基準】
- 3クリックで回答完了
- リアルタイムで結果表示

革新的なアイデアで実現してください。
```

**マネージャー → 作業者：**
```
あなたはworker1です。

【プロジェクト】アンケートシステム

【チャレンジ】
UIデザインの革新的アイデアを3つ以上提案してください。

【フォーマット】
1. アイデア名：[キャッチーな名前]
   概要：[説明]
   革新性：[何が新しいか]
```

## 📁 重要なファイルの説明

### 指示書（instructions/）
各エージェントの行動マニュアルです

**president.md** - 社長の指示書
```markdown
# あなたの役割
最高の経営者として、ユーザーのニーズを理解し、
ビジョンを示してください

# ニーズの5層分析
1. 表層：何を作るか
2. 機能層：何ができるか  
3. 便益層：何が改善されるか
4. 感情層：どう感じたいか
5. 価値層：なぜ重要か
```

**boss.md** - マネージャーの指示書
```markdown
# あなたの役割
天才的なファシリテーターとして、
チームの創造性を最大限に引き出してください

# 10分ルール
10分ごとに進捗を確認し、
困っているメンバーをサポートします
```

**worker.md** - 作業者の指示書
```markdown
# あなたの役割
専門性を活かして、革新的な実装をしてください

# タスク管理
1. やることリストを作る
2. 順番に実行
3. 完了したら報告
```

### CLAUDE.md
システム全体の設定ファイル
```markdown
# Agent Communication System

## エージェント構成
- PRESIDENT: 統括責任者
- boss1: チームリーダー  
- worker1,2,3: 実行担当

## メッセージ送信
./agent-send.sh [相手] "[メッセージ]"
```

## 🔧 困ったときは

### Q: エージェントが反応しない
```bash
# 状態を確認
tmux ls

# 再起動
./setup.sh
```

### Q: メッセージが届かない
```bash
# ログを見る
cat logs/send_log.txt

# 手動でテスト
./agent-send.sh boss1 "テスト"
```

### Q: 最初からやり直したい
```bash
# 全部リセット
tmux kill-server
rm -rf ./tmp/*
./setup.sh
```

## 🚀 自分のプロジェクトを作る

### 簡単な例：TODOアプリを作る

社長（PRESIDENT）で入力：
```
あなたはpresidentです。
TODOアプリを作ってください。
シンプルで使いやすく、タスクの追加・削除・完了ができるものです。
```

すると自動的に：
1. マネージャーがタスクを分解
2. worker1がUI作成
3. worker2がデータ管理
4. worker3がテスト作成
5. 完成！

## 📊 システムの仕組み（図解）

### 画面構成
```

```

## 🚀 プロファイル起動（core/full）
コア→フルへ段階拡張できるランチャーを用意しています。
```bash
# コア（4人）で起動
./start-profile.sh --profile core --yes

# フル（8人）で起動 + 自動役割割当
./start-profile.sh --profile full --yes --assign

# 人数を上書きしたい場合
./start-profile.sh --profile core --workers 6 --yes
```
