---
name: forge-recon
description: Inventories the project's available capabilities - skills, agents, plugins, MCP servers, hooks, CLAUDE.md rules, package scripts - and writes .forge/capabilities.md so all subsequent work uses what exists instead of reinventing it. Use at the start of any pipeline or when entering an unfamiliar repo.
allowed-tools: Read, Grep, Glob, Bash, Write
---

# FORGE recon protocol

Build a capability map of this project. Check each source; absence is also
information.

## 1. Inventory (in this order)
1. **Project skills**: `.claude/skills/*/SKILL.md` - read each frontmatter
   name + description. Legacy `.claude/commands/*.md` too.
2. **Agents**: `.claude/agents/*.md` - name, description, tools per agent.
3. **Plugins**: `.claude-plugin/` directories and plugin entries in
   `.claude/settings.json`.
4. **MCP servers**: `.mcp.json` and `mcpServers` blocks in settings files -
   name and apparent purpose only, never dump credentials or env values.
5. **Hooks**: `hooks` blocks in `.claude/settings.json` /
   `settings.local.json` - these fire deterministically; the pipeline must
   not fight them.
6. **CLAUDE.md** (and its `@imports`): project rules, documented build/test/
   deploy commands, conventions.
7. **Toolchain**: package.json scripts, pyproject/Cargo/go.mod/csproj,
   Makefile/justfile targets, CI workflow files (what CI actually runs is
   the real definition of green).

## 2. Write `.forge/capabilities.md`
Create `.forge/` if missing. The file has three sections:
- **AVAILABLE**: table of capability -> type (skill/agent/plugin/MCP/script)
  -> when to use it.
- **STAGE MAP**: for each FORGE stage (plan/implement/review/security/
  verify), which discovered capability should be used INSTEAD of the generic
  approach. Example: repo has a `/db-migrate` skill -> implementation steps
  touching schema must use it; repo has `npm run test:e2e` -> verify runs it.
- **CONSTRAINTS**: rules from CLAUDE.md and hooks that bound what the
  pipeline may do.

## 3. Binding rule
From now on in this session: before performing any action generically,
check capabilities.md for an existing project-specific way to do it, and
prefer that. When a discovered skill and a FORGE skill overlap, the
project's own skill wins - note the override in capabilities.md.

Keep the whole file under 60 lines. It gets re-read often; it must be cheap.
Re-run recon only when .claude/ contents or the toolchain files change.
