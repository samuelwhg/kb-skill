# project-kb

在任意项目仓库内初始化 Markdown 知识库，直接铺在 `docs/` 下。**全局安装一次，各项目自行决定是否创建知识库**。结构固定、纯文本、跟项目 git 走。

## 给 AI 的说明（安装入口）

复制下面整段发给任意 AI agent（Claude Code、Cursor 等）即可，无需先下载仓库：

```text
请为我安装 project-kb 技能（仓库：https://gitee.com/samuelhg/kb-skill）：
1. 先在线读取 SETUP.md——安装流程的唯一权威说明：
   https://gitee.com/samuelhg/kb-skill/raw/master/SETUP.md
2. 严格按 SETUP.md 执行，不要凭记忆拼命令、不要手工复制模板；
3. 按 SETUP.md 的「验证」检查结果，再向我汇报。
```

## 安装（全局）

```bash
curl -fsSL https://gitee.com/samuelhg/kb-skill/raw/master/install.sh | bash
```

装到 `~/.agents/skills/project-kb`，所有项目可用；**安装不创建知识库**。选项、离线安装与验证见 [SETUP.md](SETUP.md)。

## 关键词

| 关键词 | 作用 |
|--------|------|
| **创建知识库** / 初始化知识库 / 建个 KB | 在当前项目 `docs/` 铺骨架并登记根入口；已有文件跳过不覆盖 |
| **查询**（或直接提问） | 先读 `docs/index.md` 路由到目标页，再基于库回答 |
| **查笔记** | 蒸馏 `docs/note.md` 收集箱入库，再基于库回答 |
| **自检知识库** | Lint：跨页矛盾、过期计划、孤岛页、frontmatter |

「创建」由本技能完成；「查询 / 查笔记 / 自检」由建库时写入根 `AGENTS.md` 的入口约定驱动，建库后的任意会话都生效。日常只需把想法写进 `docs/note.md`，其余簿记（`index.md`、`log.md`）由 agent 维护。

## 结构

```
docs/
├── index.md        查询路由入口
├── note.md         唯一交互面（人↔agent、项目↔项目）：随手记 + 跨项目留言，「查笔记」蒸馏
├── log.md          时间线（shell 追加）
├── sources.md      素材层登记
├── wiki/           知识页
├── lessons/        踩坑页（一坑一页）
├── plans/          计划页（带 status）
├── views/          Obsidian Bases 自动表（可选）
├── archive/        log 归档
└── AGENTS.md       维护契约：frontmatter、双链、页预算、权威页规则
```

## 说明

- `docs/` 已有文件（含同名 `index.md`）一律跳过，不覆盖任何内容
- GitHub 镜像：<https://github.com/samuelwhg/kb-skill>；origin 配了双推送地址，`git push` 同时更新 Gitee 与 GitHub
- 用 Obsidian 时可直接把 `docs` 作为 vault；`.obsidian/` 不纳入 git；密钥/Token 严禁入库
- 自检：`bash scripts/self_test.sh`
