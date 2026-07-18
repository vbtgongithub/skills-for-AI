---
name: forge-implement
description: Disciplined implementation loop against an approved plan. Use when executing a plan or making any multi-step code change.
argument-hint: [plan step or task]
---

# FORGE implement protocol

Target: $ARGUMENTS

## Per-step loop (repeat for every plan step)
1. **Declare** the step: what changes, what verification will prove it.
2. **Test first** where feasible: write or identify the test that fails
   before the change and must pass after. If test-first is impractical,
   state the alternative verification before writing code.
3. **Implement** the smallest diff that completes the step.
4. **Run** the verification. Show the actual output, not a summary of it.
5. **Checkpoint**: green -> next step. Red -> apply the anti-thrash rule
   below. Never proceed past a red step "to fix later."

## Anti-thrash rule
Two consecutive failures of the same class on the same step means the mental
model is wrong, not the syntax. Stop editing. Re-read the failing code path
end to end, write down the corrected hypothesis, THEN edit. If a third
failure occurs, switch to /forge-bughunt.

## Hard rules
- No changes outside the current step's declared scope. Note out-of-scope
  problems in a "Found while working" list instead of fixing them silently.
- Every error path you introduce must be handled or explicitly propagated
  with context. Empty catch blocks are forbidden.
- New code follows the file's existing conventions, not your preferences.
- If a step reveals the plan is wrong, stop and revise the plan explicitly -
  do not quietly improvise a different design.

- If `.forge/state.md` exists, checkpoint it after every step (statuses,
  counters, NEXT ACTION) and append notable decisions to decisions.md -
  even when running outside the /forge pipeline.

## Exit
End with: steps completed, verification evidence per step, "Found while
working" list, and any deviation from the plan with justification.
