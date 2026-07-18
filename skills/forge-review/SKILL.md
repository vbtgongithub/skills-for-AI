---
name: forge-review
description: Two-pass code review of current changes - structured self-review, then adversarial review by the code-reviewer subagent. Use after writing or modifying code, or when the user asks for a review.
---

# FORGE review protocol

## Current changes
!`git diff HEAD --stat`

## Pass 1 — Self-review
Run `git diff HEAD` and read the full diff as if someone else wrote it.
Check, in order:
1. Correctness: does it do what the plan/request says, including edge cases?
2. Error handling: every failure path handled or propagated with context?
3. Resource safety: files/connections/locks closed on ALL paths (incl. error)?
4. Concurrency: shared state, race windows, non-atomic check-then-act?
5. API misuse: return values checked, deprecated calls, wrong argument order?
6. Data flow: can null/empty/oversized/malformed data reach this code?
7. Consistency: naming, conventions, and patterns match the surrounding code?

Fix what you find. Then proceed.

## Pass 2 — Adversarial review
Invoke the **code-reviewer** subagent on the diff. Its context is clean; do
not pre-explain or defend the code to it.

## Triage
For every finding from both passes, assign severity:
- **Critical**: data loss, security hole, crash on common path -> fix now
- **High**: incorrect behavior, leak, unhandled likely error -> fix now
- **Medium**: fragile pattern, missing edge case test -> list for user
- **Low**: style, naming, minor cleanup -> list for user

Fixing Critical/High findings re-enters this protocol (changed code gets
re-reviewed). Cap at 2 re-entries, then report remaining state honestly.

## Exit
Findings table (severity, location, issue, action taken), followed by an
explicit statement: "Review clean at Critical/High" or what remains.
