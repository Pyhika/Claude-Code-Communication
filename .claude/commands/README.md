# Custom Slash Commands (/sc)

## 使い方
- Claude Code上で次のように入力:
  - `/sc:president:guide`
  - `/sc:boss1:guide`
  - `/sc:worker:guide`

## 配置規則
- プロジェクト直下 `.claude/commands/` に配置
- サブディレクトリが名前空間になります（例: `president/guide.md` → `/sc:president:guide`）

## 目的
- 役割ごとの標準オペレーションを即時参照
- 指示テンプレやチェックリストを素早く呼び出し
