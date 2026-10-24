#!/usr/bin/env bash
# project-kb 安装器：用户级（默认）或项目级（-l）。
set -euo pipefail

# 云端仓库地址（git clone 用）。留空则必须用 -r 或 PROJECT_KB_REPO 提供。
DEFAULT_REPO="${PROJECT_KB_REPO:-}"

MODE=user
DEST=""
REPO="$DEFAULT_REPO"
SRC=""
FORCE=0

usage() {
  cat <<'EOF'
用法: install.sh [选项]

  -l, --local        安装到项目级 <项目>/.claude/skills/project-kb（默认用户级 ~/.claude/skills）
  -d, --dir DIR      项目根目录（配合 -l，默认当前目录）
  -r, --repo URL     云端仓库地址（默认取 PROJECT_KB_REPO 环境变量）
  -s, --source DIR   从本地目录安装，跳过 clone（开发/离线用）
  -f, --force        目标已存在时覆盖
  -h, --help         显示帮助

示例:
  curl -fsSL <raw>/install.sh | bash -s -- -r <repo-url>
  curl -fsSL <raw>/install.sh | bash -s -- -r <repo-url> -l
  bash install.sh -s /path/to/project-kb -l -d /path/to/project
EOF
}

die() { echo "错误: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--local) MODE=local; shift ;;
    -d|--dir) [[ $# -ge 2 ]] || die "$1 需要参数"; DEST="$2"; shift 2 ;;
    -r|--repo) [[ $# -ge 2 ]] || die "$1 需要参数"; REPO="$2"; shift 2 ;;
    -s|--source) [[ $# -ge 2 ]] || die "$1 需要参数"; SRC="$2"; shift 2 ;;
    -f|--force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "未知参数: $1（-h 查看帮助）" ;;
  esac
done

TMP=""
cleanup() { if [[ -n "$TMP" ]]; then rm -rf "$TMP"; fi; }
trap cleanup EXIT

# 定位源：本地目录 > 脚本所在目录 > clone 云端仓库
if [[ -z "$SRC" ]]; then
  SELF_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
  if [[ -f "$SELF_DIR/SKILL.md" && -d "$SELF_DIR/templates" ]]; then
    SRC="$SELF_DIR"
  else
    [[ -n "$REPO" ]] || die "未提供仓库地址：用 -r URL 或设置 PROJECT_KB_REPO"
    command -v git >/dev/null || die "需要 git 才能从云端安装"
    TMP="$(mktemp -d)"
    git clone --depth 1 "$REPO" "$TMP/repo" >/dev/null 2>&1 || die "克隆失败: $REPO"
    SRC="$TMP/repo"
  fi
fi
[[ -f "$SRC/SKILL.md" && -f "$SRC/scripts/init_kb.sh" && -d "$SRC/templates" ]] || die "源目录不完整: $SRC"

# 目标位置
if [[ "$MODE" == local ]]; then
  ROOT="${DEST:-$PWD}"
  [[ -d "$ROOT" ]] || die "项目目录不存在: $ROOT"
  ROOT="$(cd "$ROOT" && pwd)"
  TARGET="$ROOT/.claude/skills/project-kb"
else
  [[ -z "$DEST" ]] || die "-d 仅用于 -l 项目级安装"
  TARGET="$HOME/.claude/skills/project-kb"
fi

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  [[ "$FORCE" -eq 1 ]] || die "$TARGET 已存在；加 -f 覆盖"
  rm -rf "$TARGET"
fi

mkdir -p "$(dirname "$TARGET")"
cp -R "$SRC" "$TARGET"
rm -rf "$TARGET/.git" "$TARGET/install.sh" "$TARGET/README.md"
chmod +x "$TARGET/scripts/"*.sh

echo "已安装 project-kb ($MODE): $TARGET"
if [[ "$MODE" == local ]]; then
  echo "项目内使用：在新会话里说「初始化知识库」，或运行 $TARGET/scripts/init_kb.sh ."
else
  echo "新会话生效；任意项目可说「初始化知识库」"
fi
