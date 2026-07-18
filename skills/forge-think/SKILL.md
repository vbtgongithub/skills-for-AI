---
name: forge-think
description: Structured deep-reasoning scaffold for hard problems - tricky design decisions, algorithmic problems, ambiguous tradeoffs, "why is this happening" questions. Use when a problem needs careful thought rather than immediate action.
argument-hint: [the problem]
---

# FORGE think protocol

Problem: $ARGUMENTS

Work through these phases visibly. Do not touch files until phase 5 says to.

## 1. Decompose
Break the problem into independent subproblems. For each: what would a
solution look like, and what information decides it?

## 2. Ground
Gather the facts that decide the subproblems - read the actual code, check
the actual data, run the cheap experiment. Mark every claim in your
reasoning as: VERIFIED (checked here), READ (from code/docs), or ASSUMED.
Assumptions that would change the answer if wrong get tested, not stacked.

## 3. Solve
Solve subproblems in dependency order. Where a subproblem has competing
answers, keep both alive until a fact kills one - do not pick by momentum.

## 4. Adversarial self-check
Attack your own conclusion before presenting it:
- What single fact, if true, would make this wrong?
- What is the strongest argument for the alternative you rejected?
- Where did you rely on an ASSUMED claim?
- Does the conclusion survive the edge cases (empty, huge, concurrent,
  malformed, Windows-specific)?
Revise if the attack lands. Say so if it does - changed minds are the point.

## 5. Conclude
- Answer, stated plainly
- Confidence: HIGH (verified) / MEDIUM (solid inference) / LOW (best guess) -
  with the single biggest thing that would change it
- The runner-up alternative and when the user should prefer it instead
- Next action (implement via /forge-plan or /forge-implement, or a specific
  experiment to raise confidence)
