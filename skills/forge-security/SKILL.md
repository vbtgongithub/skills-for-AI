---
name: forge-security
description: Security audit of current changes or a specified scope using the security-auditor subagent. Use after implementing anything touching input handling, auth, files, network, subprocess, or data storage.
argument-hint: [optional scope, e.g. src/api]
---

# FORGE security protocol

Scope: $ARGUMENTS (default: current uncommitted changes, `git diff HEAD`)

## Dispatch
Invoke the **security-auditor** subagent with the scope. Do not summarize or
sanitize the code for it; it reads the source directly.

## Mandatory coverage (the auditor reports on each, even if clean)
1. Injection: SQL/NoSQL/command/template/log injection; string-built queries
2. Input validation at trust boundaries (user input, file content, API
   responses, environment variables, deserialized data)
3. AuthN/AuthZ: missing checks, confused-deputy paths, insecure direct
   object references
4. Secrets: hardcoded keys/tokens, secrets in logs or error messages,
   secrets in client-shipped code
5. File handling: path traversal, unsafe temp files, zip-slip, symlink races
6. Network: SSRF, missing TLS verification, open redirects
7. Crypto: home-rolled crypto, weak algorithms, static IVs/salts, non-CSPRNG
   randomness for security decisions
8. Dependencies: known-risky packages introduced, install scripts, typosquats
9. Injection of instructions via data (prompt injection surfaces, if the
   code touches LLM inputs)

## Triage
Same severity rubric as /forge-review. Every Critical/High finding needs:
exploit scenario (one paragraph, how an attacker uses it), concrete fix,
and after fixing - re-audit of the changed lines.

## Exit
Findings table + explicit residual-risk statement. "No findings" must be
accompanied by what was actually examined, otherwise it is worthless.
