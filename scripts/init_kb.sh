#!/usr/bin/env bash
# 在项目仓库内初始化 docs/kb 知识库；已存在则拒绝，绝不覆盖。
set -euo pipefail

case "${1:-}" in
  -h|--help)
    echo "用法: init_kb.sh [项目根]   (默认当前目录)"
    exit 0
    ;;
esac

SKILL_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
TEMPLATES="$SKILL_DIR/templates"
ROOT="${1:-$PWD}"
DATE="$(date +%F)"

[[ -d "$ROOT" ]] || { echo "错误: 目录不存在: $ROOT" >&2; exit 1; }
ROOT="$(cd "$ROOT" && pwd)"
TARGET="$ROOT/docs/kb"

if [[ -e "$TARGET" ]]; then
  echo "错误: $TARGET 已存在，拒绝覆盖。要重建请先自行删除或改名。" >&2
  exit 1
fi

PROJECT="$(basename "$ROOT")"
esc() { printf '%s' "$1" | sed 's/[&|\\]/\\&/g'; }

mkdir -p "$TARGET"
cp -R "$TEMPLATES/." "$TARGET/"
find "$TARGET" -type f -exec sed -i \
  "s|{{PROJECT}}|$(esc "$PROJECT")|g; s|{{DATE}}|$DATE|g" {} +

# 根入口：优先 CLAUDE.md，其次 AGENTS.md，都没有则新建 CLAUDE.md
ENTRY="$ROOT/CLAUDE.md"
if [[ ! -f "$ENTRY" && -f "$ROOT/AGENTS.md" ]]; then
  ENTRY="$ROOT/AGENTS.md"
fi

MARK_BEGIN="<!-- project-kb:begin -->"
if [[ -f "$ENTRY" ]] && grep -qF "$MARK_BEGIN" "$ENTRY"; then
  echo "跳过: $ENTRY 已登记知识库入口"
else
  cat >> "$ENTRY" <<'EOF'

<!-- project-kb:begin -->
## 知识库

本项目知识库在 `docs/kb/`。回答「环境/命令/坑/计划/契约/历史决策」前，先读 `docs/kb/index.md` 路由到目标页；维护契约见 `docs/kb/CLAUDE.md`。

- 随手记进 `docs/kb/note.md`；说「查笔记」= 蒸馏收集箱 + 基于库回答
- 说「自检知识库」= Lint
- 易过期的命令与接口只在库内写一处，repo 只留指针
<!-- project-kb:end -->
EOF
  echo "已追加知识库入口: $ENTRY"
fi

echo "已在 $TARGET 创建知识库:"
find "$TARGET" -maxdepth 2 -not -name '.gitkeep' | sed "s|$TARGET|docs/kb|" | sort

# Obsidian 只影响 views/*.base 是否可用，不影响其余骨架
has_obsidian() {
  command -v obsidian >/dev/null 2>&1 && return 0
  [[ -d "$HOME/.config/obsidian" ]] && return 0
  [[ -d "$HOME/Library/Application Support/obsidian" ]] && return 0
  [[ -n "${APPDATA:-}" && -d "$APPDATA/obsidian" ]] && return 0
  compgen -G "/mnt/c/Users/*/AppData/Roaming/obsidian" >/dev/null && return 0
  return 1
}
if has_obsidian; then
  echo "检测到 Obsidian：可把 docs/kb 作为 vault 打开，views/ 自动表可用。"
else
  echo "未检测到 Obsidian：views/*.base 已保留但不生效，不需要可删。"
fi
