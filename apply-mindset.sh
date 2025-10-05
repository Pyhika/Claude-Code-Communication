#!/bin/bash

# YAMLベースの思考パターン適用スクリプト
# mindset-profiles.yaml から設定を読み込んで各エージェントに適用

set -e

# デフォルト値
PROFILE="core"
YAML_FILE="mindset-profiles.yaml"
DRY_RUN=false

usage() {
  cat << EOF
使い方:
  $0 [--profile PROFILE] [--yaml FILE] [--dry-run]

オプション:
  --profile PROFILE  使用するプロファイル (core|full|startup|enterprise|ai_ml|web3)
  --yaml FILE        YAMLファイルパス（デフォルト: mindset-profiles.yaml）
  --dry-run          実際には送信せず、内容を表示のみ

例:
  # コアプロファイルを適用
  $0 --profile core

  # スタートアッププロファイルを適用
  $0 --profile startup

  # AI/MLプロファイルをドライラン
  $0 --profile ai_ml --dry-run
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="$2"; shift 2;;
    --yaml)
      YAML_FILE="$2"; shift 2;;
    --dry-run)
      DRY_RUN=true; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "不明な引数: $1"; usage; exit 1;;
  esac
done

# YAMLファイルの存在確認
if [ ! -f "$YAML_FILE" ]; then
  echo "❌ YAMLファイルが見つかりません: $YAML_FILE"
  exit 1
fi

# yqまたはyj (YAML parser) の確認
if command -v yq &> /dev/null; then
  YAML_PARSER="yq"
elif command -v yj &> /dev/null; then
  YAML_PARSER="yj"
else
  echo "⚠️ YAMLパーサー（yq または yj）が見つかりません"
  echo "インストール方法:"
  echo "  macOS: brew install yq"
  echo "  Linux: snap install yq"
  echo ""
  echo "代替として、Pythonを使用します..."
  YAML_PARSER="python"
fi

# Python を使用したYAML読み込み関数
read_yaml_python() {
  local path="$1"
  python3 -c "
import yaml
import sys
with open('$YAML_FILE', 'r', encoding='utf-8') as f:
    data = yaml.safe_load(f)

# パスをドット記法で解析
path_parts = '$path'.split('.')
result = data
for part in path_parts:
    if part in result:
        result = result[part]
    else:
        print('')
        sys.exit(0)

if isinstance(result, list):
    for item in result:
        print(item)
elif isinstance(result, dict):
    print(yaml.dump(result))
else:
    print(result)
" 2>/dev/null || echo ""
}

# YAML読み込み関数
read_yaml() {
  local path="$1"

  if [ "$YAML_PARSER" = "yq" ]; then
    yq eval ".$path" "$YAML_FILE" 2>/dev/null || echo ""
  elif [ "$YAML_PARSER" = "yj" ]; then
    cat "$YAML_FILE" | yj | jq -r ".$path" 2>/dev/null || echo ""
  else
    read_yaml_python "$path"
  fi
}

# エージェントに思考パターンを送信する関数
apply_mindset_to_agent() {
  local agent="$1"
  local role="$2"
  local mindset="$3"
  local principles="$4"

  local message="🧠 思考パターン設定

あなたは${agent}です。

🎯 役割: ${role}

🧠 思考パターン: ${mindset}

📋 行動原則:
${principles}

この思考パターンに基づいて、以下を実行してください：
1. 意思決定時に思考パターンを明示的に適用する
2. 他のメンバーとの協調時に、お互いの思考パターンを尊重する
3. 定期的に思考プロセスを言語化して共有する
4. 課題解決時に、自分の思考パターンの強みを活かす"

  if [ "$DRY_RUN" = true ]; then
    echo "----------------------------------------"
    echo "📝 $agent への設定内容:"
    echo "$message"
    echo "----------------------------------------"
  else
    echo "📝 $agent に思考パターンを適用中..."
    ./agent-send.sh "$agent" "$message"
  fi
}

echo "🧠 思考パターン適用ツール"
echo "📁 設定ファイル: $YAML_FILE"
echo "🎯 プロファイル: $PROFILE"

if [ "$DRY_RUN" = true ]; then
  echo "🔍 ドライランモード（実際には送信しません）"
fi

echo ""

# プロファイルの存在確認
profile_exists=$(read_yaml "profiles.$PROFILE")
if [ -z "$profile_exists" ]; then
  echo "❌ プロファイル '$PROFILE' が見つかりません"
  echo "利用可能なプロファイル:"
  read_yaml "profiles" | grep ":" | sed 's/://g' | sed 's/^/  - /'
  exit 1
fi

# 各エージェントに設定を適用
echo "🚀 思考パターンの適用を開始します..."

# boss1 の設定
boss_role=$(read_yaml "profiles.$PROFILE.boss1.role")
boss_mindset=$(read_yaml "profiles.$PROFILE.boss1.mindset")
boss_principles=$(read_yaml "profiles.$PROFILE.boss1.principles" | sed 's/^/• /')

if [ -n "$boss_role" ]; then
  apply_mindset_to_agent "boss1" "$boss_role" "$boss_mindset" "$boss_principles"
fi

# 各workerの設定
for i in {1..8}; do
  worker="worker$i"
  worker_role=$(read_yaml "profiles.$PROFILE.$worker.role")

  if [ -n "$worker_role" ]; then
    worker_mindset=$(read_yaml "profiles.$PROFILE.$worker.mindset")
    worker_principles=$(read_yaml "profiles.$PROFILE.$worker.principles" | sed 's/^/• /')
    apply_mindset_to_agent "$worker" "$worker_role" "$worker_mindset" "$worker_principles"
  fi
done

if [ "$DRY_RUN" = false ]; then
  echo ""
  echo "✅ 思考パターンの適用が完了しました"
  echo ""
  echo "💡 確認方法:"
  echo "  1. tmux attach-session -t multiagent で画面を確認"
  echo "  2. 各エージェントが自分の思考パターンを認識しているか確認"
  echo "  3. project-status.sh でプロジェクト全体の状況を確認"
else
  echo ""
  echo "📌 これはドライランです。実際に適用するには --dry-run を外してください"
fi