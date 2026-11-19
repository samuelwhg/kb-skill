---
name: project-kb
description: 在任意项目仓库内初始化一套 Markdown 知识库（docs/：wiki/lessons/plans/views + index/log/note/sources + 维护契约）。触发于用户说「创建知识库」「初始化知识库」「给项目建知识库」「建个 KB」「setup project knowledge base」「scaffold docs」。不做查询、不迁移旧库；用户指的是 Obsidian 库或 LLM Wiki 桌面应用时不要用本技能。
---

# project-kb — 仓库内知识库初始化

技能全局安装（`~/.agents/skills/project-kb`），**各项目自行决定是否建库**。触发后在目标项目根的 `docs/` 铺知识库骨架，并在项目根 `AGENTS.md` 追加知识库入口约定。模板来自本技能目录，**已存在的文件一律跳过，绝不覆盖**。

## 何时触发

- 「创建知识库」「初始化知识库」「给这个项目建知识库」「建个 KB」「铺一下知识库」
- 「setup / scaffold project knowledge base」「create docs」
- 新项目启动，用户希望沿用现有的 KB 结构（wiki/lessons/plans + note.md 收集箱）

**不要触发**：用户说的是仓库外 Obsidian 库、LLM Wiki 桌面应用、或只是询问已有知识库内容。

## 执行

1. 确认项目根。用户未指定时用当前工作目录；若当前目录不是项目根（例如在子目录），向上找到最近的 `.git` 或 `AGENTS.md` 所在目录，向用户确认一句。
2. 运行（脚本幂等：已存在的文件一律跳过，绝不覆盖）：

```bash
bash ~/.agents/skills/project-kb/scripts/init_kb.sh "<项目根>"
```

3. 把脚本输出的创建/跳过清单转述给用户，并提醒：
   - 新想法先写 `docs/note.md`，之后说「查笔记」由 Claude 蒸馏入库
   - 维护契约在 `docs/AGENTS.md`；根 `AGENTS.md` 只留入口指针
   - 如果项目使用 Obsidian，可直接把 `docs/` 作为 vault 打开；`.obsidian/` 不纳入 git

## 约束

- 不要手工复制模板来绕过脚本；脚本负责占位符替换与根 `AGENTS.md` 的幂等追加。
- 不覆盖已有文件；用户要重建时，让其先自行删除或改名对应文件，并说明会丢失现有内容。
- 不写入密钥、Token；只创建文档骨架。

## 自检

修改模板或脚本后运行：

```bash
bash ~/.agents/skills/project-kb/scripts/self_test.sh
```
