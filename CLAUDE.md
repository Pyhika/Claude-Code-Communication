# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要
1:1:8:2構成のマルチエージェント開発システム。
macOSスペース分離により、統括・実装・レビューの3グループが独立したスクリーンで協調動作します。

## システム構成

### 🎯 スペース1: 統括グループ (1:1)
- **PRESIDENT**: AI司令塔、要件解析、最終判定
- **ARCHITECT**: 設計統括、システム設計、タスク分割

### 🛠️ スペース2: 実装グループ (8)
- **FRONTEND**: UI/UX実装
- **BACKEND**: API/サーバーサイド
- **DATABASE**: データモデル/永続化
- **SECURITY**: 認証/認可/セキュリティ
- **TESTING**: テスト実装
- **DEPLOY**: デプロイ/インフラ
- **DOCS**: ドキュメント作成
- **QA**: 品質保証

### 🔍 スペース3: レビューグループ (2)
- **REVIEWER_A**: 品質レビュー、コード品質、パフォーマンス
- **REVIEWER_B**: セキュリティレビュー、脆弱性チェック、安全性確認

## 基本コマンド

### システム起動
```bash
# 1. 既存ウィンドウクリーンアップ
./cleanup-iterm.sh

# 2. マルチスペース起動（全グループを3つのスペースに配置）
./launch-multi-space.sh \
  --management-layout tabs \
  --workers-layout tabs \
  --reviewers-layout tabs
```

### 監視・管理
```bash
# 全エージェント状態確認
./agent-status.sh

# Wチェック実行（品質・セキュリティダブルチェック）
./review-report-system.sh check [path]

# エージェント一覧確認
./agent-send.sh --list
```

### エージェント間通信
```bash
# 利用可能なエージェント名を確認
./agent-send.sh --list

# ARCHITECTに指示（全体設計担当）
./agent-send.sh architect "システム設計を開始してください"

# 専門エージェントに直接指示
./agent-send.sh FRONTEND "UI実装を開始してください"
./agent-send.sh BACKEND "API実装を開始してください"
./agent-send.sh DATABASE "データモデル設計を開始してください"
./agent-send.sh SECURITY "セキュリティチェックを開始してください"
./agent-send.sh TESTING "テスト実装を開始してください"
./agent-send.sh DEPLOY "デプロイ準備を開始してください"
./agent-send.sh DOCS "ドキュメント作成を開始してください"
./agent-send.sh QA "品質チェックを開始してください"

# 旧形式（worker番号）も使用可能
./agent-send.sh worker1 "タスクを開始してください"
```

## ワークフロー

### 1. システム起動
```bash
./cleanup-iterm.sh
./launch-multi-space.sh --management-layout tabs --workers-layout tabs --reviewers-layout tabs
```

### 2. 認証完了
- **スペース1** (Control + 1): PRESIDENT + ARCHITECT で認証
- **スペース2** (Control + 2): 8 WORKERS で認証
- **スペース3** (Control + 3): 2 REVIEWERS で認証

### 3. プロジェクト実行
1. **スペース1** → PRESIDENTで要件入力（例: "ECサイトを作りたい"）
2. **スペース2** → 各WORKERの自動実装を確認
3. **スペース3** → REVIEWERの品質・セキュリティチェックを確認

## スペース操作

### macOSスペース切り替え
- `Control + →`: 次のスペース
- `Control + ←`: 前のスペース
- `Control + 1`: スペース1（統括）
- `Control + 2`: スペース2（実装）
- `Control + 3`: スペース3（レビュー）

## 役割別ガイド
各エージェントの詳細な動作指示は以下を参照:
- **PRESIDENT**: `instructions/president.md`
- **ARCHITECT**: （boss1の役割を継承）`instructions/boss.md`
- **WORKERS**: `instructions/worker.md`

## 作業ディレクトリ
- 共通作業場所: `/workspace/[プロジェクト名]/`
- 全エージェントが同じディレクトリで作業

## トラブルシューティング

### システムリセット
```bash
# 全ウィンドウクリーンアップ
./cleanup-iterm.sh

# 再起動
./launch-multi-space.sh --management-layout tabs --workers-layout tabs --reviewers-layout tabs
```

### 認証エラー
- 各スペースで全エージェントのブラウザ認証が必要
- 認証前のメッセージ送信は失敗します

### エージェント状態確認
```bash
# 全エージェントのステータス確認
./agent-status.sh

# 特定パスのWチェック
./review-report-system.sh check workspace/project-name/
```
