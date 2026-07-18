---
name: forge-skillgen
description: Creates a new project skill from a workflow that keeps repeating. Use when .forge/patterns.md shows a pattern at 3+ occurrences, or when the user asks to turn a workflow into a skill.
argument-hint: [workflow to encode, or blank to check patterns.md]
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Write, Bash
---

# FORGE skillgen protocol

Target: $ARGUMENTS

## 1. Qualify the candidate
If no explicit target given, read `.forge/patterns.md` and pick patterns
with count >= 3. A workflow qualifies for skill-hood only if ALL hold:
- Repeated with the same shape (same steps, varying parameters)
- Has a describable trigger condition ("Use when...")
- Longer than what fits in one sentence of instruction
- Not already covered by an existing skill (check `.forge/capabilities.md`)
If nothing qualifies, say so and stop. Skills have a per-session token cost;
a skill nobody needed is negative value.

## 2. Draft the skill (never write silently)
Present to the user before creating any file:
- Proposed name (lowercase-hyphen, <= 64 chars)
- Description written as a trigger condition with concrete phrases the user
  actually says - this drives auto-invocation accuracy
- Invocation mode: default both; `disable-model-invocation: true` if the
  workflow has side effects (deploy, commit, publish, delete)
- `allowed-tools`: minimum set the workflow needs
- Body outline: numbered steps, verification per step, exit criteria
- Scope: project (`.claude/skills/`) or user (`~/.claude/skills/`)

Wait for approval. This is deliberate - skills execute with your
permissions and deserve the same audit as any dependency.

## 3. Create and validate
- Write `.claude/skills/<name>/SKILL.md`: YAML frontmatter between ---
  markers, then the body. Keep body under 80 lines; move reference material
  to supporting files in the same directory.
- Parameterize with $ARGUMENTS where the repeated runs varied.
- Use !`command` dynamic injection only for cheap, safe, cross-platform
  commands (git status/diff class), never for anything with side effects.
- Validate: frontmatter parses as YAML, name matches directory, description
  under 1024 chars.
- Update `.forge/capabilities.md` (new AVAILABLE row + STAGE MAP if
  relevant) and mark the pattern as ENCODED in patterns.md.

## 4. Dry run
Walk one historical occurrence of the workflow through the new skill's
steps mentally. If any step is ambiguous when read cold, rewrite it -
the skill will be read by a session with zero memory of today.
