# project-kb

在任意项目仓库内一键初始化 Markdown 知识库（`docs/kb/`）。结构固定、纯文本、跟项目 git 走。

## 包含什么

```
docs/kb/
├── index.md        查询路由入口（先读它，再读目标页）
├── note.md         收集箱：随手记，说「查笔记」由 agent 蒸馏入库
├── log.md          时间线（shell 追加）
├── sources.md      素材层登记
├── wiki/           知识页
├── lessons/        踩坑页（一坑一页）
├── plans/          计划页（带 status）
├── views/          Obsidian Bases 自动表（可选）
└── CLAUDE.md       维护契约：frontmatter、双链、页预算、权威页规则
```

安装同时会在项目根 `CLAUDE.md`（或 `AGENTS.md`）追加带标记的知识库入口，让后续会话自动先查库。

## 安装

要求：`bash`、`git`、`curl`。把下文 `<repo>` 换成仓库 clone 地址，`<raw>` 换成对应 raw 地址。

### 命令行安装

```bash
# 用户级：所有项目可用（~/.claude/skills/project-kb）
curl -fsSL <raw>/install.sh | bash -s -- -r <repo>

# 项目级：只对当前项目生效（<项目>/.claude/skills/project-kb）
curl -fsSL <raw>/install.sh | bash -s -- -r <repo> -l

# 指定项目根 / 覆盖已有安装
curl -fsSL <raw>/install.sh | bash -s -- -r <repo> -l -d /path/to/project -f
```

也可以先 clone 再本地安装：`bash install.sh -s /path/to/project-kb -l`。

### Agent 会话安装

在 Claude Code 里直接说：

> 把 `<repo>` 安装为 project-kb 技能，项目级（或用户级）

agent 会调用 `install.sh` 完成同样的安装。已安装后，在新项目里说 **「初始化知识库」** 即可铺库。

## 使用

| 你说 | 发生什么 |
|------|----------|
| 初始化知识库 | 创建 `docs/kb/` 骨架并登记入口 |
| 查笔记 | 蒸馏 `note.md` 收集箱，再基于库回答 |
| 自检知识库 | Lint：矛盾、过期计划、孤岛页、frontmatter |

日常只需把想法写进 `docs/kb/note.md`，其余簿记（`index.md`、`log.md`）由 agent 维护。

## 说明

- `docs/kb` 已存在时初始化脚本拒绝执行，不覆盖任何内容
- 检测到 Obsidian 会提示可把 `docs/kb` 作为 vault 打开；未检测到则 `views/*.base` 保留但不生效
- `.obsidian/` 不纳入 git；密钥/Token 严禁入库
- 自检：`bash scripts/self_test.sh`
