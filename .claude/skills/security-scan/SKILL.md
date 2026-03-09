---
name: security-scan
description: Run security scans for code vulnerabilities and dependency audits. Use when the user asks to check for security issues, run security scans, or audit dependencies.
---

# Security Scan Skill

Scan for security vulnerabilities in code and dependencies.

## Scope

This skill scans the entire project for security issues.
It is not limited to changed files since vulnerabilities can exist anywhere.

## Step 1: Static Analysis

Use the **Security scan** command from the CLAUDE.md Tooling table.

### Common Issues to Fix (all languages)

**Hardcoded Passwords/Secrets**
- Move to environment variables or config files
- Use `.env` files (excluded via `.gitignore`)

**Unsafe Deserialization**
- Avoid deserializing untrusted data with unsafe methods
- Prefer JSON for data exchange

**Command Injection**
- Never pass user input directly to shell commands
- Use parameterized/safe command execution

**SQL Injection**
- Use parameterized queries, never string formatting

**Unsafe Config Loading**
- Use safe parsing modes (e.g., `yaml.safe_load`, not `yaml.load`)

### Language-Specific Tools

| Language | Static Analysis | Dependency Audit |
|----------|----------------|-----------------|
| Python | `bandit -r . -ll` | `pip-audit` |
| TypeScript/JS | `npm audit` | `npm audit` |
| Go | `gosec ./...` | `govulncheck ./...` |
| Rust | `cargo clippy` | `cargo audit` |

### Handling Warnings
- Fix the code properly
- Do NOT suppress with ignore comments unless absolutely necessary
- If a false positive, document why in a comment

## Step 2: Dependency Audit

Check for known vulnerabilities in dependencies. Update vulnerable packages if patched versions exist. If no patch available, document the risk.

## Step 3: Additional Checks

### Check for Hardcoded Secrets
Search for: API keys, tokens, passwords, private keys, connection strings.

### Check .gitignore
Ensure sensitive files are excluded:
- `.env`, `.env.*`
- `*.pem`, `*.key`
- `credentials.*`, `secrets.*`

## Step 4: Verify Clean

Re-run all scans to confirm issues are resolved.

## Completion

Report:
- Number of warnings found and fixed
- Number of vulnerable dependencies found and updated
- Any remaining issues that need attention
