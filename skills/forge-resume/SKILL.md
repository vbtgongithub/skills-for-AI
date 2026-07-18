---
name: forge-resume
description: Rehydrates task state from .forge/ memory files after a context compaction, session restart, or when the user says resume, continue, or where were we. Reconstructs the contract, plan, progress, and decisions, then continues from the exact next action.
allowed-tools: Read, Grep, Glob, Bash
---

# FORGE resume protocol

Conversation memory may be gone or unreliable. The `.forge/` directory is
the source of truth. Rebuild from it; do not trust your recollection of
this session over what the files say.

## 1. Rehydrate (read in this order)
1. `.forge/contract.md` - the immutable objective, acceptance criteria,
   constraints, out-of-scope list. This defines what you are doing.
2. `.forge/plan.md` - the approved step decomposition.
3. `.forge/state.md` - step statuses, loop counters, and the recorded
   NEXT ACTION. This defines where you are.
4. `.forge/decisions.md` - decisions, deviations, refuted hypotheses. This
   prevents re-litigating settled questions and re-testing dead hypotheses.
5. `.forge/capabilities.md` - the project capability map (re-run
   /forge-recon only if it is missing or the toolchain changed).

If `.forge/` does not exist, say so and ask the user what to work on -
do not fabricate a remembered task.

## 2. Verify reality matches state
State files can lag reality. Cross-check before acting:
- `git status` and `git diff --stat` vs what state.md says was completed
- If they disagree, reality wins: update state.md to match the working
  tree, log the discrepancy in decisions.md, then proceed.

## 3. Report and continue
Output a resume summary (5-8 lines): objective, steps done / remaining,
loop counters used, last decision, and the NEXT ACTION. Then execute the
next action under the same rules that were in force (doctrine, drift
checks, checkpointing).

## Hard rule
After resuming, the first completed action must end with a fresh checkpoint
to state.md - resuming without re-checkpointing recreates the exact
fragility this system exists to remove.
