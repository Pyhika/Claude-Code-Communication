# Custom Slash Commands (/sc)

## 使い方
Claude Code上で次のように入力:
- `/sc:president:guide` - PRESIDENT向けガイド
- `/sc:architect:guide` - ARCHITECT向けガイド
- `/sc:worker:guide` - WORKER向けガイド

## 新システム (1:1:8:2構成)
- **PRESIDENT**: プロジェクト統括、要件定義、最終判定
- **ARCHITECT**: 設計統括、タスク分配（旧boss1）
- **WORKERS**: 8つの専門エージェント
  - FRONTEND, BACKEND, DATABASE, SECURITY
  - TESTING, DEPLOY, DOCS, QA

## 配置規則
- プロジェクト直下 `.claude/commands/` に配置
- サブディレクトリが名前空間になります（例: `president/guide.md` → `/sc:president:guide`）

## 目的
- 役割ごとの標準オペレーションを即時参照
- 指示テンプレやチェックリストを素早く呼び出し
