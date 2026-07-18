---
name: forge
description: Full autonomous engineering pipeline - recon, plan, critique, drift-audited execution loop, review, security, verify - with file-based memory that survives compaction and restarts. Heavyweight; user-invoked only.
disable-model-invocation: true
argument-hint: [task description]
---

# FORGE pipeline

Task: $ARGUMENTS

If `.forge/state.md` exists with an unfinished task, run /forge-resume
instead of starting fresh - confirm with the user which task wins.

## Stage 0 - RECON + MEMORY INIT
1. Run /forge-recon (skip if `.forge/capabilities.md` is current). All
   later stages MUST prefer capabilities it maps over generic approaches.
2. Create `.forge/` and initialize memory files (see Memory protocol below).

## Stage 1 - PLAN
Execute /forge-plan. Write the outputs to disk:
- `.forge/contract.md`: objective, acceptance criteria, constraints, and an
  explicit OUT-OF-SCOPE list. Everything else is judged against this file.
- `.forge/plan.md`: the numbered steps with per-step verification.

## Stage 2 - CRITIQUE + FREEZE
Invoke the **plan-critic** subagent. Revise once if it returns blockers.
Present plan to the user; pause for confirmation if anything is destructive
or ambiguous. On approval, mark contract.md `STATUS: FROZEN` at the top.
The contract never changes after this point - if it must, that is a new
negotiation with the user, not an edit.

## Stage 3 - AUTONOMOUS EXECUTION LOOP
For each step in plan.md, run this loop without further user input:
1. **Read state**: `.forge/state.md` (current step, counters). Files beat
   your recollection of this conversation.
2. **Execute** the step per /forge-implement discipline (test-first,
   smallest diff, run and show output, anti-thrash).
3. **Checkpoint** (mandatory, before anything else):
   - Rewrite state.md: step statuses, loop counters, NEXT ACTION.
   - Append to decisions.md: any decision, deviation, or refuted
     hypothesis from this step, with one-line rationale.
4. **Drift check**: invoke the **drift-auditor** subagent.
   - ON_TRACK -> next step.
   - CORRECT -> apply exactly the redirection given, log it in
     decisions.md, re-run the drift check once after correcting.
   - HALT -> stop the loop, report to the user with state.
5. **Budget**: max 3 total loop-backs across the whole pipeline (track in
   state.md as "Loop n/3"). Exceeded -> HALT and report options; no thrash.

## Stage 4 - REVIEW
Run /forge-review. Fix Critical/High via the Stage 3 loop (each fix gets a
checkpoint + drift check). Record findings summary in decisions.md.

## Stage 5 - SECURITY
Run /forge-security. Same fix/checkpoint/drift discipline.

## Stage 6 - VERIFY
Run /forge-verify. RED -> /forge-bughunt on failures, fix via the loop,
re-verify. Record the final evidence block in state.md.

## Stage 7 - PATTERN LOG
Append one line to `.forge/patterns.md` describing this workflow's shape
(e.g. "flask-endpoint: route + validation + test + audit | count: n").
Increment the count if the shape already exists. Any pattern at count >= 3
and not marked ENCODED -> tell the user /forge-skillgen can encode it.

## Memory protocol (applies to every stage)
- `.forge/` is the database; conversation context is a cache that can be
  compacted away at any moment. Never let the only copy of task state live
  in conversation.
- Single writer: only this main session writes `.forge/` files. Subagents
  read them (dispatch prompts must name the files) but never write.
- Checkpoint after every step, after every stage, and before any risky or
  slow operation. state.md must always contain a NEXT ACTION such that a
  fresh session reading only `.forge/` could continue correctly.
- decisions.md and patterns.md are append-only. contract.md is frozen.
  state.md is rewritten whole (keep it under 40 lines).

## Final report
1. What changed (files + one line each)  2. What was NOT changed
3. Evidence table (build/tests/lint/review/security/drift verdicts)
4. Remaining Medium/Low findings  5. Assumptions  6. Pattern-log status
Then mark state.md `STATUS: COMPLETE`.
