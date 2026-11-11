#!/usr/bin/env bash
# 在项目仓库内初始化 docs 知识库；已存在的文件一律跳过，绝不覆盖。
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
TARGET="$ROOT/docs"

if [[ -e "$TARGET" && ! -d "$TARGET" ]]; then
  echo "错误: $TARGET 已存在且不是目录，拒绝初始化。" >&2
  exit 1
fi

PROJECT="$(basename "$ROOT")"
esc() { printf '%s' "$1" | sed 's/[&|\\]/\\&/g'; }

# docs/ 可能已有其他文档：逐文件复制，已存在的一律跳过
mkdir -p "$TARGET"
CREATED=()
SKIPPED=()
while IFS= read -r -d '' f; do
  rel="${f#"$TEMPLATES/"}"
  if [[ -e "$TARGET/$rel" ]]; then
    SKIPPED+=("$rel")
  else
    mkdir -p "$(dirname "$TARGET/$rel")"
    cp "$f" "$TARGET/$rel"
    CREATED+=("$TARGET/$rel")
  fi
done < <(find "$TEMPLATES" -type f -print0)

# 占位符替换只作用于新建文件，绝不改动已有文件
if [[ ${#CREATED[@]} -gt 0 ]]; then
  sed -i "s|{{PROJECT}}|$(esc "$PROJECT")|g; s|{{DATE}}|$DATE|g" "${CREATED[@]}"
fi

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

本项目知识库在 `docs/`。回答「环境/命令/坑/计划/契约/历史决策」前，先读 `docs/index.md` 路由到目标页；维护契约见 `docs/CLAUDE.md`。

- 随手记进 `docs/note.md`；说「查笔记」= 蒸馏收集箱 + 基于库回答
- 说「自检知识库」= Lint
- 易过期的命令与接口只在库内写一处，repo 只留指针
<!-- project-kb:end -->
EOF
  echo "已追加知识库入口: $ENTRY"
fi

if [[ ${#CREATED[@]} -eq 0 ]]; then
  echo "知识库已存在 ($TARGET): 全部文件跳过，未覆盖任何内容。"
else
  echo "已在 $TARGET 初始化知识库:"
  for f in "${CREATED[@]}"; do echo "  新建 ${f#"$ROOT/"}"; done
fi
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  for rel in "${SKIPPED[@]}"; do echo "  跳过 docs/$rel（已存在，未覆盖）"; done
fi

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
  echo "检测到 Obsidian：可把 docs 作为 vault 打开，views/ 自动表可用。"
else
  echo "未检测到 Obsidian：views/*.base 已保留但不生效，不需要可删。"
fi
