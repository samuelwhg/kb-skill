#!/usr/bin/env bash
# init_kb.sh 自检：铺库、二次执行拒绝、不覆盖、入口幂等、无入口文件时新建。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
INIT="$SCRIPT_DIR/init_kb.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

PROJ="$TMP/demo-proj"
mkdir -p "$PROJ"
printf '# Demo\n' > "$PROJ/CLAUDE.md"

OUT1="$(bash "$INIT" "$PROJ")"
grep -q 'Obsidian' <<<"$OUT1" || fail "未输出 Obsidian 检测提示"
for f in docs/kb/index.md docs/kb/log.md docs/kb/note.md docs/kb/sources.md \
         docs/kb/CLAUDE.md docs/kb/使用说明.md; do
  [[ -f "$PROJ/$f" ]] || fail "缺少 $f"
done
for d in wiki lessons plans views; do
  [[ -d "$PROJ/docs/kb/$d" ]] || fail "缺少分区 $d"
done
[[ "$(grep -cF '<!-- project-kb:begin -->' "$PROJ/CLAUDE.md")" -eq 1 ]] || fail "入口未写入或重复"
grep -qF 'docs/kb/index.md' "$PROJ/CLAUDE.md" || fail "入口未指向 index.md"

# 二次执行必须拒绝，且不改动已有内容
printf 'sentinel\n' >> "$PROJ/docs/kb/index.md"
if bash "$INIT" "$PROJ" >/dev/null 2>&1; then
  fail "已存在的 docs/kb 未被拒绝"
fi
grep -qx 'sentinel' "$PROJ/docs/kb/index.md" || fail "二次执行覆盖了已有内容"
[[ "$(grep -cF '<!-- project-kb:begin -->' "$PROJ/CLAUDE.md")" -eq 1 ]] || fail "二次执行重复追加入口"

# 无 CLAUDE.md / AGENTS.md 的新项目应新建 CLAUDE.md
PROJ2="$TMP/fresh"
mkdir -p "$PROJ2"
bash "$INIT" "$PROJ2" >/dev/null
grep -qF '<!-- project-kb:begin -->' "$PROJ2/CLAUDE.md" || fail "新项目未生成入口"

# 有 AGENTS.md 时应写入 AGENTS.md，而不是新建 CLAUDE.md
PROJ3="$TMP/agents-proj"
mkdir -p "$PROJ3"
printf '# Agents\n' > "$PROJ3/AGENTS.md"
bash "$INIT" "$PROJ3" >/dev/null
grep -qF '<!-- project-kb:begin -->' "$PROJ3/AGENTS.md" || fail "未写入 AGENTS.md"
[[ ! -f "$PROJ3/CLAUDE.md" ]] || fail "有 AGENTS.md 时不应新建 CLAUDE.md"

# ── install.sh ──
INSTALL="$(dirname "$SCRIPT_DIR")/install.sh"
[[ -f "$INSTALL" ]] || fail "缺少 install.sh"

# 用户级：隔离 HOME，源目录安装
HOME_FAKE="$TMP/home"
mkdir -p "$HOME_FAKE"
HOME="$HOME_FAKE" bash "$INSTALL" -s "$(dirname "$SCRIPT_DIR")" >/dev/null
UKB="$HOME_FAKE/.claude/skills/project-kb"
[[ -f "$UKB/SKILL.md" && -x "$UKB/scripts/init_kb.sh" ]] || fail "用户级安装不完整"
[[ ! -e "$UKB/install.sh" ]] || fail "安装目标不应包含 install.sh"
if HOME="$HOME_FAKE" bash "$INSTALL" -s "$(dirname "$SCRIPT_DIR")" >/dev/null 2>&1; then
  fail "目标已存在时未拒绝"
fi
HOME="$HOME_FAKE" bash "$INSTALL" -s "$(dirname "$SCRIPT_DIR")" -f >/dev/null || fail "-f 覆盖失败"

# 项目级：不带 -s，靠脚本所在目录自动识别源
PROJ4="$TMP/install-proj"
mkdir -p "$PROJ4"
bash "$INSTALL" -l -d "$PROJ4" >/dev/null
[[ -f "$PROJ4/.claude/skills/project-kb/SKILL.md" ]] || fail "项目级安装不完整"
bash "$PROJ4/.claude/skills/project-kb/scripts/init_kb.sh" "$PROJ4" >/dev/null
[[ -f "$PROJ4/docs/kb/index.md" ]] || fail "安装后的技能无法初始化知识库"

echo "PASS: project-kb init + install 自检通过"
