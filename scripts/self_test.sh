#!/usr/bin/env bash
# init_kb.sh 自检：铺库、二次执行跳过不覆盖、已有 docs 保护、入口幂等、全局安装不铺库。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
INIT="$SCRIPT_DIR/init_kb.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

PROJ="$TMP/demo-proj"
mkdir -p "$PROJ"
printf '# Demo\n' > "$PROJ/AGENTS.md"

OUT1="$(bash "$INIT" "$PROJ")"
grep -q 'Obsidian' <<<"$OUT1" || fail "未输出 Obsidian 检测提示"
for f in docs/index.md docs/log.md docs/note.md docs/sources.md \
         docs/AGENTS.md; do
  [[ -f "$PROJ/$f" ]] || fail "缺少 $f"
done
for d in wiki lessons plans views archive; do
  [[ -d "$PROJ/docs/$d" ]] || fail "缺少分区 $d"
done
[[ "$(grep -cF '<!-- project-kb:begin -->' "$PROJ/AGENTS.md")" -eq 1 ]] || fail "入口未写入或重复"
grep -qF 'docs/index.md' "$PROJ/AGENTS.md" || fail "入口未指向 index.md"

# 二次执行必须跳过已有文件，绝不覆盖
printf 'sentinel\n' >> "$PROJ/docs/index.md"
bash "$INIT" "$PROJ" >/dev/null || fail "二次执行应安全跳过"
grep -qx 'sentinel' "$PROJ/docs/index.md" || fail "二次执行覆盖了已有内容"
[[ "$(grep -cF '<!-- project-kb:begin -->' "$PROJ/AGENTS.md")" -eq 1 ]] || fail "二次执行重复追加入口"

# 已有 docs/（含无关文档与同名 index.md）：只补缺失，绝不覆盖；无入口文件时新建 AGENTS.md
PROJ2="$TMP/existing-docs"
mkdir -p "$PROJ2/docs"
printf 'my own index\n' > "$PROJ2/docs/index.md"
printf 'guide\n' > "$PROJ2/docs/guide.md"
bash "$INIT" "$PROJ2" >/dev/null
grep -qx 'my own index' "$PROJ2/docs/index.md" || fail "覆盖了用户已有的 docs/index.md"
grep -qx 'guide' "$PROJ2/docs/guide.md" || fail "动了无关文档"
[[ -f "$PROJ2/docs/note.md" ]] || fail "未补齐缺失文件"
grep -qF '<!-- project-kb:begin -->' "$PROJ2/AGENTS.md" || fail "新项目未生成入口"

# 只有 CLAUDE.md 的项目：入口仍写入 AGENTS.md，CLAUDE.md 保持不动
PROJ3="$TMP/claude-proj"
mkdir -p "$PROJ3"
printf '# Claude\n' > "$PROJ3/CLAUDE.md"
bash "$INIT" "$PROJ3" >/dev/null
grep -qF '<!-- project-kb:begin -->' "$PROJ3/AGENTS.md" || fail "未写入 AGENTS.md"
[[ "$(cat "$PROJ3/CLAUDE.md")" == '# Claude' ]] || fail "CLAUDE.md 不应被改动"

# ── install.sh（仅全局安装，不创建知识库）──
INSTALL="$(dirname "$SCRIPT_DIR")/install.sh"
[[ -f "$INSTALL" ]] || fail "缺少 install.sh"

# 全局：隔离 HOME，源目录安装；安装不得在任何项目铺库
HOME_FAKE="$TMP/home"
mkdir -p "$HOME_FAKE"
PROJ4="$TMP/bystander-proj"
mkdir -p "$PROJ4"
(cd "$PROJ4" && HOME="$HOME_FAKE" bash "$INSTALL" -s "$(dirname "$SCRIPT_DIR")") >/dev/null
UKB="$HOME_FAKE/.agents/skills/project-kb"
[[ -f "$UKB/SKILL.md" && -x "$UKB/scripts/init_kb.sh" ]] || fail "全局安装不完整"
[[ ! -e "$UKB/install.sh" && ! -e "$UKB/README.md" && ! -e "$UKB/SETUP.md" ]] || fail "安装目标不应包含 install.sh/README.md/SETUP.md"
[[ ! -e "$PROJ4/docs" && ! -e "$PROJ4/AGENTS.md" ]] || fail "全局安装不应创建知识库或入口"
if HOME="$HOME_FAKE" bash "$INSTALL" -s "$(dirname "$SCRIPT_DIR")" >/dev/null 2>&1; then
  fail "目标已存在时未拒绝"
fi
HOME="$HOME_FAKE" bash "$INSTALL" -s "$(dirname "$SCRIPT_DIR")" -f >/dev/null || fail "-f 覆盖失败"
if HOME="$HOME_FAKE" bash "$INSTALL" -l >/dev/null 2>&1; then
  fail "项目级 -l 已移除，应报未知参数"
fi

# 各项目自行决定建库：用安装后的技能铺库
bash "$UKB/scripts/init_kb.sh" "$PROJ4" >/dev/null
[[ -f "$PROJ4/docs/index.md" && -f "$PROJ4/docs/note.md" ]] || fail "安装后的技能无法初始化知识库"
grep -qF '<!-- project-kb:begin -->' "$PROJ4/AGENTS.md" || fail "建库未写入入口"

echo "PASS: project-kb init + install 自检通过"
