---
name: project-kb
description: 在任意项目仓库内自动初始化一套 Markdown 知识库（docs/kb/：wiki/lessons/plans/views + index/log/note/sources + 维护契约）。触发于用户说「初始化知识库」「给项目建知识库」「建个 KB」「setup project knowledge base」「scaffold docs/kb」。不做查询、不迁移旧库；用户指的是 Obsidian 库或 LLM Wiki 桌面应用时不要用本技能。
---

# project-kb — 仓库内知识库初始化

在目标项目根创建 `docs/kb/`，并在项目根的 `CLAUDE.md`（或 `AGENTS.md`）追加一段知识库入口约定。模板来自本技能目录，**已存在 `docs/kb` 时脚本直接拒绝，绝不覆盖**。

## 何时触发

- 「初始化知识库」「给这个项目建知识库」「建个 KB」「铺一下知识库」
- 「setup / scaffold project knowledge base」「create docs/kb」
- 新项目启动，用户希望沿用现有的 KB 结构（wiki/lessons/plans + note.md 收集箱）

**不要触发**：用户说的是仓库外 Obsidian 库、LLM Wiki 桌面应用、或只是询问已有知识库内容。

## 执行

1. 确认项目根。用户未指定时用当前工作目录；若当前目录不是项目根（例如在子目录），向上找到最近的 `.git` 或 `CLAUDE.md` 所在目录，向用户确认一句。
2. 运行（脚本幂等，重复执行只会在已建库时安全退出）：

```bash
bash ~/.agents/skills/project-kb/scripts/init_kb.sh "<项目根>"
```

3. 把脚本输出的创建清单转述给用户，并提醒：
   - 新想法先写 `docs/kb/note.md`，之后说「查笔记」由 Claude 蒸馏入库
   - 维护契约在 `docs/kb/CLAUDE.md`；根 `CLAUDE.md` 只留入口指针
   - 如果项目使用 Obsidian，可直接把 `docs/kb/` 作为 vault 打开；`.obsidian/` 不纳入 git

## 约束

- 不要手工复制模板来绕过脚本；脚本负责占位符替换与根 `CLAUDE.md` 的幂等追加。
- 不覆盖已有 `docs/kb`；用户要重建时，让其先自行删除或改名，并说明会丢失现有内容。
- 不写入密钥、Token；只创建文档骨架。

## 自检

修改模板或脚本后运行：

```bash
bash ~/.agents/skills/project-kb/scripts/self_test.sh
```
