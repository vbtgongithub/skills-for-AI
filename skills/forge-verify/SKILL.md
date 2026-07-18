---
name: forge-verify
description: Evidence gate. Detects the project's build/test/lint commands, runs them, and reports pass/fail with real output. Use before declaring any task done, before commits, and whenever the user asks if something works.
---

# FORGE verify protocol

## 1. Detect the toolchain
Identify the project type and its real commands. Priority order:
1. Commands documented in CLAUDE.md or README (always prefer these)
2. `package.json` scripts (build/test/lint/typecheck)
3. `pyproject.toml` / `pytest.ini` / `requirements.txt` -> pytest, ruff/flake8, mypy
4. `Cargo.toml` -> cargo build / cargo test / cargo clippy
5. `go.mod` -> go build ./... / go test ./... / go vet ./...
6. `*.csproj` / `*.sln` -> dotnet build / dotnet test

For large test suites, dispatch the **verifier** subagent so full output
stays out of the main context and only failures come back.

## 2. Run the gates (all that exist)
- Build/compile
- Type check
- Test suite (full; if genuinely too slow, run affected tests AND say the
  full suite was not run)
- Lint

Show real command output for failures. For passes, show the summary line
(e.g. "42 passed in 3.1s"), never a paraphrase.

## 3. Evidence block (required output)

FORGE VERIFY
  build:     PASS | FAIL | N/A
  typecheck: PASS | FAIL | N/A
  tests:     PASS (n passed) | FAIL (n failed: names) | N/A
  lint:      PASS | FAIL (n issues) | N/A
  verdict:   GREEN | RED

## Hard rules
- RED verdict = the task is NOT done. Say exactly that. Route failures to
  /forge-bughunt.
- Never mark a gate PASS without having run it in this session.
- No test suite exists? Verdict caps at "GREEN (unverified by tests)" and
  recommend the minimum test worth adding.
- Windows: prefer the project's own scripts; when giving the user commands,
  give PowerShell-compatible forms.
