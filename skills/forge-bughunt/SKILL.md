---
name: forge-bughunt
description: Hypothesis-driven debugging protocol. Use when a bug is reported, a test fails unexpectedly, or behavior diverges from expectations and the cause is not obvious.
argument-hint: [symptom or failing test]
---

# FORGE bughunt protocol

Symptom: $ARGUMENTS

## 1. Reproduce first
Get a deterministic reproduction (failing test, command, or input) BEFORE
theorizing. If you cannot reproduce it, that is the first problem to solve -
say so and work on reproduction, not on speculative fixes.

## 2. Hypothesis ledger
Maintain a visible ledger throughout. Every entry:

| # | Hypothesis | Test that would confirm/refute | Result |

Rules:
- One hypothesis tested at a time. No shotgun edits.
- A hypothesis without a discriminating test is not a hypothesis, it is a vibe.
- Refuted hypotheses stay in the ledger. They are progress, not failure.
- For hard bugs, dispatch the **bug-hunter** subagent to investigate a
  specific hypothesis in isolation (keeps large log/trace output out of the
  main context).

## 3. Isolate
Binary-search the failure surface: halve the input, disable half the code
path, check the last-known-good commit (`git log`, `git bisect` if warranted).
State each halving and its result.

## 4. Root cause, not symptom
The fix must address WHY the bug exists, not suppress where it appears.
Test: explain the causal chain from root cause to symptom in plain language.
If you cannot, you have not found the root cause.

## 5. Fix + regression + siblings
- Apply the minimal root-cause fix.
- Add a regression test that fails without the fix (run it both ways, show it).
- Sibling sweep: grep for the same bug class elsewhere in the codebase
  (same pattern, same copied code, same API misuse). Report what you find.

## Exit
Root cause (causal chain), fix diff summary, regression test evidence,
sibling sweep result, and the final hypothesis ledger.
