# FORGE

A model-agnostic rigor harness for Claude Code. It upgrades any main model's
output quality by enforcing the disciplines strong models apply implicitly:
plan before code, adversarial review as a separate clean-context pass, and
evidence-gated completion. Works today on Opus 4.8, keeps working on
whatever ships next. Zero dependencies, plain markdown + JSON, auditable in
ten minutes.

## What it is NOT
A prompt harness does not change a model's raw benchmark scores. It changes
the failure modes that actually cost you time: unverified "done" claims,
thrash loops on the same wrong guess, missed edge cases, symptom-patching
instead of root-causing, and security issues nobody looked for. Those are
process failures, and process is exactly what this encodes.

## Architecture

Three layers, mapped to Claude Code's extension model:

1. **Doctrine** (`forge-doctrine.md`, imported by CLAUDE.md via
   `@forge-doctrine.md`) - always-on rules: evidence gate, anti-thrash,
   diff discipline, security defaults, Windows conventions. Loaded every
   session, applies to everything, including work where you never type a
   FORGE command.

2. **Skills** (`.claude/skills/forge-*`) - workflows, loaded on demand:

   | Command          | What it enforces                                      |
   |------------------|-------------------------------------------------------|
   | `/forge <task>`  | Full autonomous pipeline: recon -> plan -> critique -> drift-audited execution loop -> review -> security -> verify (max 3 loop-backs) |
   | `/forge-recon`   | Inventories project skills/agents/plugins/MCP/hooks/scripts into .forge/capabilities.md; pipeline prefers what exists |
   | `/forge-resume`  | Rehydrates task state from .forge/ after compaction or restart; cross-checks git reality; continues at NEXT ACTION |
   | `/forge-skillgen`| Turns workflows repeated 3+ times (tracked in .forge/patterns.md) into new project skills, with your approval |
   | `/forge-plan`    | Spec, unknowns, edge cases, 2+ approaches, risk map, checkable acceptance criteria |
   | `/forge-think`   | Deep reasoning: decompose, ground claims (verified/read/assumed), adversarial self-check, confidence |
   | `/forge-implement` | Per-step: declare -> test-first -> smallest diff -> run -> show output; anti-thrash rule |
   | `/forge-review`  | Self-review pass + clean-context adversarial review, severity triage |
   | `/forge-security`| Attacker-mindset audit across 9 mandatory categories |
   | `/forge-bughunt` | Reproduce first, hypothesis ledger, root cause + regression test + sibling sweep |
   | `/forge-verify`  | Auto-detects toolchain, runs build/typecheck/tests/lint, emits evidence block; RED = not done |

   All skills except `/forge` can also be auto-invoked by Claude when the
   context matches their description. `/forge` is user-invoked only
   (`disable-model-invocation: true`) because the full pipeline is expensive.

3. **Agents** (`.claude/agents/`) - clean-context specialists the skills
   dispatch. Reviewers and auditors are deliberately read-only:

   | Agent            | Tools                          | Role |
   |------------------|--------------------------------|------|
   | plan-critic      | Read, Grep, Glob               | Attacks plans before code exists |
   | code-reviewer    | Read, Grep, Glob, Bash         | Adversarial diff review, file:line findings |
   | security-auditor | Read, Grep, Glob, Bash         | Data-flow tracing, exploit scenarios |
   | bug-hunter       | Read, Grep, Glob, Bash         | Isolated diagnosis; returns causal chain, not vibes |
   | test-engineer    | Read, Write, Edit, Bash, Grep, Glob | Boundary/error-path tests; mutation spot-check |
   | verifier         | Bash, Read, Grep, Glob         | Runs gates in isolation, returns only evidence + failures |
   | drift-auditor    | Read, Grep, Glob, Bash         | After each loop step: trajectory vs frozen contract -> ON_TRACK / CORRECT / HALT |

   The clean-context part matters: the reviewer never sees your session's
   self-justifications, and the verifier's 5,000 lines of test output never
   touch your main context window.

## Memory: context loss is designed out

Every multi-step task externalizes its state to a `.forge/` directory in
the repo. Conversation context is treated as a cache; these files are the
database:

| File            | Role |
|-----------------|------|
| contract.md     | Frozen objective, acceptance criteria, out-of-scope list - the drift reference frame |
| plan.md         | Approved step decomposition |
| state.md        | Step statuses, loop counters, NEXT ACTION - rewritten at every checkpoint, always resumable cold |
| decisions.md    | Append-only: decisions, deviations, refuted hypotheses (never re-litigated after resume) |
| patterns.md     | Workflow frequency log feeding /forge-skillgen |
| capabilities.md | Recon output: what this repo already provides |

Checkpoints happen after every step, so compaction, a crashed session, or a
hit context limit costs at most one step of progress. `/forge-resume`
rebuilds everything from disk, cross-checks against `git status` (reality
wins over stale state), and continues. Subagents read these files but never
write - single-writer keeps state uncorrupted even with parallel dispatches.
The optional SessionStart/PreCompact hooks in settings.example.json add
deterministic reminders at exactly the moments memory is at risk.

## Autonomy with a leash

Claude Code subagents cannot spawn subagents, so the main session drives
the loop and dispatches specialists. Stage 3 of `/forge` runs plan steps
autonomously - no user input per step - but every iteration ends with a
checkpoint and a **drift-auditor** pass that compares the actual trajectory
(git diff included) against the frozen contract, not against the previous
step. Verdicts: ON_TRACK continues; CORRECT applies the smallest
redirection and logs it; HALT stops and reports when drift is structural or
budgets are blown. Locally-reasonable steps that sum to the wrong
destination is the classic autonomous failure mode; auditing against the
frozen contract is what catches it.

## Self-extension

`/forge` logs each completed workflow's shape to patterns.md. At 3+
occurrences of the same shape, it suggests `/forge-skillgen`, which drafts
a proper SKILL.md (trigger-condition description, minimal allowed-tools,
side-effectful workflows locked to manual invocation) and asks for approval
before writing anything - skills run with your permissions and get the same
audit as any dependency.

## Install (Windows)

```powershell
# user scope - every project on the machine
.\install.ps1

# or a single repo
.\install.ps1 -Scope project -Path C:\path\to\repo
```

Then add one line to the corresponding CLAUDE.md
(`%USERPROFILE%\.claude\CLAUDE.md` or `<repo>\.claude\CLAUDE.md`):

```
@forge-doctrine.md
```

The installer never overwrites CLAUDE.md or settings.json, and skips
existing FORGE files unless `-Force`. Restart running sessions to pick up
new agents. Manual install works too: copy `skills/` and `agents/` into the
`.claude` directory of your choice.

Per-repo layering: install user-scope for the doctrine + agents everywhere,
then commit a project-scope copy of any skill you customize into a repo's
`.claude/skills/` - project scope wins on name collision.

## Optional hooks

`settings.example.json` contains two echo-only reminders (post-edit
"verification pending", stop-time evidence check). They are deterministic
nudges, not enforcement, and deliberately not installed by default - review
and merge into `settings.json` yourself if wanted. A stricter option once
you trust the flow: a PreToolUse hook on `Bash` matching `git commit` that
exits 2 unless a marker file from a green `/forge-verify` run exists.

## Usage patterns

- Feature work: `/forge implement rate limiting on the API` and let the
  pipeline run. Confirm the plan when it pauses.
- Quick change: work normally - the doctrine still applies - then
  `/forge-review` and `/forge-verify` before calling it done.
- Mystery bug: `/forge-bughunt tests pass locally, fail in CI on Windows`.
- After compaction/restart mid-task: `/forge-resume`.
- New/unfamiliar repo: `/forge-recon` once, then work normally.
- Design decision: `/forge-think should PhishGuard score URLs client-side
  or via the Flask API`.

## Cost tuning

Subagent dispatches multiply tokens (each runs in its own context; expect
several times a plain session on a full `/forge` run). Levers:

- Reviewers/auditors run `model: inherit` for max quality. Downshift any
  agent by editing its frontmatter (`model: sonnet`) - verifier is the
  first safe candidate since it only runs commands.
- Skip the pipeline for small tasks; the doctrine plus `/forge-verify`
  carries most of the value at a fraction of the cost.
- `/forge-review` and `/forge-security` on a diff are cheap relative to the
  bugs they catch; `/forge` end-to-end is the expensive one.

## Extending

Add a new specialist as `.claude/agents/<name>.md` (frontmatter: name,
description, tools, model; body = system prompt). Add a workflow as
`.claude/skills/<name>/SKILL.md`. Write descriptions as trigger conditions
("Use when...") - that text is what drives auto-invocation. Keep skill
bodies under ~80 lines; loaded skills stay in context and cost tokens every
turn.
