---
type: wiki
tags: [schema, guide]
updated: {{DATE}}
---

# Schema — 本库维护契约（LLM 必读）

> 项目根 `AGENTS.md` 已登记本库入口；本文件是维护细节的唯一权威。纯 Query 无需读本文件。

## 1. 库结构（固定约定）

```
docs/
├── AGENTS.md        本文件（Schema）
├── index.md         Query 唯一路由入口；Ingest 后必更新
├── log.md           时间线——shell 追加（勿全文读），超 60 行归档
├── archive/         log 归档（log-YYYYQn.md），查询默认不读
├── sources.md       素材层登记（repo 只读指针）
├── note.md          收集箱（蒸馏后清理）
└── wiki/ lessons/ plans/ views/   知识页 / 坑页 / 计划页（带 status）/ Bases 自动表格（勿手写）
```

## 2. 页面规范

1. **YAML frontmatter**：必含 `type`(wiki|lesson|plan)、`tags`、`sources`（`repo/<路径>`、`git:<sha>`）、`updated`(YYYY-MM-DD)；plan 另必含 `status`。合规即自动进 Bases 表。
2. **双链**：库内页间一律 `[[wikilinks]]`（可 `[[页|别名]]`、`[[页#章节]]`）；缺页概念勿强行建页。跨项目引用用纯文本「页名」(项目名)，勿写跨库 wikilink。
3. **命名**：中文文件名，一页一主题；lesson 固定四段（现象/根因/规避/来源事件）。
4. **一事实一权威页**：每个事实只在权威页落一处，他页只留一句结论 + `[[页#节]]` 指针；来源写「来源: 路径 §章节」，勿搬运原文。
5. **单页预算与语义精分**：wiki/plan **≤4.3KB 且 ≤90 行**；高低频查询意图混在一页即拆子页，未超预算也拆；勿为拆而拆造孤页。
6. **写作**：结论先行、表格优先、不杜撰。
7. **省 token**：index 摘要 ≤20 字只放判别关键词；log 单条 ≤80 字（细节归页面/git sha）；能用指针的不复制。

## 3. 三类操作（用户触发词）

**「查笔记」= Ingest + Query 复合**：先蒸馏 `note.md` 未处理条目、补记会话新坑/决策，再基于库回答；无待蒸馏条目 = 纯 Query。

- **Ingest**：读素材（note.md 增量 / repo diff / git log）→ 写/更新页（冲突时旧页标注 `> ⚠️ 已由 <新资料> 修正`，不静默覆盖）→ 刷 `index.md` → **log 用 shell 追加** `printf '%s\n' '- [日期] ingest | 说明' >> docs/log.md`（勿全文读再改）→ 清理 `note.md` 已落地条目。主 log 超 60 行时把 30 天前条目压缩移入 `archive/`，尾部留一行指针。
- **Query 最小读集**：只读 `index.md` → 目标页 →（需验证时）按「来源:」回仓库查。纯查询不读本文件、`sources.md`、`log.md`。
- **Lint**（「自检知识库」）：查跨页矛盾、过期 active plan、孤岛页、frontmatter 不合规、缺页概念、超预算/高低频混页；页数动态统计勿硬编码；结果记 log（shell 追加）。

## 4. 与仓库的对应关系

- 素材层（repo 代码/git/其他文档）**只读**；冲突裁决以 repo 为准，修本库页面。本库是知识投影，非源码镜像。本库就在 `docs/` 内：`docs/` 下非本库的文件仍属素材层，只读。
- Claude memory 目录 = **过渡存储**：蒸馏进本库后即清退（删文件 + `MEMORY.md` 对应行），防双源漂移。
- 版本管理走项目自身 git；若用 Obsidian 打开，`docs/.obsidian/` 不入库。

## 5. 红线

- 素材层只读；可写的只有本库各页与库根 `note.md`。
- 密钥/Token 严禁入库（`.env` 真实值等）。
