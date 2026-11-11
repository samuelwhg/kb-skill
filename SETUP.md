# SETUP — project-kb 安装流程（全局）

本文件是安装流程的**唯一权威说明**。AI agent 受用户委托安装本技能时，必须读完本文件并严格按此执行，不要凭记忆拼命令。

## 前置要求

- `bash`、`git`、`curl`
- 默认仓库 `https://gitee.com/samuelhg/kb-skill.git`；fork 或私有仓库用 `-r URL`（或环境变量 `PROJECT_KB_REPO`）覆盖

## 安装命令

```bash
# 全局安装：所有项目可用
curl -fsSL https://gitee.com/samuelhg/kb-skill/raw/master/install.sh | bash

# 覆盖已有安装（-f 只覆盖技能本身）
curl -fsSL https://gitee.com/samuelhg/kb-skill/raw/master/install.sh | bash -s -- -f
```

本地 / 离线安装（先 clone，`-s` 跳过云端拉取）：

```bash
git clone https://gitee.com/samuelhg/kb-skill.git /tmp/kb-skill
bash /tmp/kb-skill/install.sh -s /tmp/kb-skill
```

## install.sh 做了什么

1. 定位源：`-s` 指定目录 > 脚本所在目录 > `git clone` 云端仓库。
2. 复制技能到 `~/.agents/skills/project-kb`，剔除 `.git`、`install.sh`、`README.md`、`SETUP.md`；目标已存在时须 `-f` 才覆盖。
3. **不创建任何知识库**——是否建库由各项目自行决定。

## 各项目创建知识库（可选）

在目标项目的会话里说「**创建知识库**」（或「初始化知识库」），或直接运行：

```bash
bash ~/.agents/skills/project-kb/scripts/init_kb.sh <项目根>
```

效果：在 `<项目根>/docs/` 铺骨架——`index.md`、`note.md`、`log.md`、`sources.md`、`CLAUDE.md`（维护契约）、`wiki/`、`lessons/`、`plans/`、`views/`、`archive/`；**已存在的文件一律跳过，绝不覆盖**（`docs/` 里原有的其他文档不受影响）；并在根 `CLAUDE.md`（优先）或 `AGENTS.md` 幂等追加 `<!-- project-kb:begin -->` 知识库入口，两者都没有则新建 `CLAUDE.md`。

## 验证

- `~/.agents/skills/project-kb` 存在且含 `SKILL.md`、`scripts/init_kb.sh`、`templates/`
- 建库后：`<项目>/docs/` 下可见 `index.md` 与 `note.md`；根 `CLAUDE.md` 或 `AGENTS.md` 含 `project-kb:begin` 标记
- 可选全量自检：`bash scripts/self_test.sh`（在技能源目录运行）

## 给 AI 的执行约定

1. 安装只有**全局**一种方式；不要提供或执行项目级安装。
2. 不要手工复制模板绕过脚本；占位符替换与入口追加都由脚本负责。
3. 不要覆盖任何已有文件；`docs/` 已有同名文件时脚本会跳过，属正常行为，如实汇报。
4. 安装完成后按「验证」检查，向用户汇报安装路径；是否建库听用户的，不主动铺库。
5. 建库后用户说「查笔记 / 查询 / 自检知识库」按根入口约定执行。
