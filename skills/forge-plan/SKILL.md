---
name: forge-plan
description: Deep planning protocol for a feature, refactor, or fix. Use before implementing anything non-trivial, when the user asks for a plan, or when scope is unclear.
argument-hint: [what to plan]
---

# FORGE plan protocol

Target: $ARGUMENTS

Produce a plan with EXACTLY these sections. Thin sections mean thin thinking.

## 1. Problem restatement
One paragraph, your own words. If your restatement differs from what the user
likely meant, flag the difference.

## 2. Unknowns
List what you don't know. Classify each: BLOCKING (ask the user now) or
NON-BLOCKING (state your assumption and proceed).

## 3. Invariants and edge cases
- Invariants: what must remain true after the change (APIs preserved, data
  integrity, backward compatibility, performance bounds).
- Edge cases: empty/null, boundaries, duplicates, concurrency, error paths,
  encoding/CRLF, path separators, permissions, large inputs.

## 4. Candidate approaches (minimum 2)
For each: sketch, pros, cons, failure modes, rough effort. Then pick one and
justify in 2-3 sentences. If only one approach is genuinely viable, prove it
by explaining why the obvious alternative fails.

## 5. Step decomposition
Numbered steps. Each step gets:
- What changes (files/modules)
- How it will be verified (specific test or command - "manually check" is
  not acceptable)

## 6. Risk map
Rank the 3 most likely points of failure in this plan and how you'll detect
each one early.

## 7. Acceptance criteria
Concrete, checkable statements. These become the definition of done for
/forge-verify.

Read the relevant code BEFORE writing sections 3-6. Plans written without
reading the code are fiction.
