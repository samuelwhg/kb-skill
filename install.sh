#!/usr/bin/env bash
# project-kb 安装器：全局安装到 ~/.agents/skills/project-kb。
# 只装技能，不创建知识库；各项目自行决定是否「创建知识库」。
set -euo pipefail

# 云端仓库地址（git clone 用）。可用 -r 或 PROJECT_KB_REPO 覆盖。
DEFAULT_REPO="${PROJECT_KB_REPO:-https://gitee.com/samuelhg/kb-skill.git}"

REPO="$DEFAULT_REPO"
SRC=""
FORCE=0

usage() {
  cat <<'EOF'
用法: install.sh [选项]

全局安装到 ~/.agents/skills/project-kb，所有项目可用；不创建知识库。

  -r, --repo URL     云端仓库地址（默认取 PROJECT_KB_REPO 环境变量）
  -s, --source DIR   从本地目录安装，跳过 clone（开发/离线用）
  -f, --force        目标已存在时覆盖
  -h, --help         显示帮助

示例:
  curl -fsSL https://gitee.com/samuelhg/kb-skill/raw/master/install.sh | bash
  bash install.sh -s /path/to/kb-skill -f
EOF
}

die() { echo "错误: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
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

TARGET="$HOME/.agents/skills/project-kb"
if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  [[ "$FORCE" -eq 1 ]] || die "$TARGET 已存在；加 -f 覆盖"
  rm -rf "$TARGET"
fi

mkdir -p "$(dirname "$TARGET")"
cp -R "$SRC" "$TARGET"
rm -rf "$TARGET/.git" "$TARGET/install.sh" "$TARGET/README.md" "$TARGET/SETUP.md"
chmod +x "$TARGET/scripts/"*.sh

echo "已全局安装 project-kb: $TARGET"
echo "新会话生效；各项目自行决定是否建库：在项目里说「创建知识库」，或运行 $TARGET/scripts/init_kb.sh <项目根>"
