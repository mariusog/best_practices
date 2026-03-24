---
name: open-source-audit
description: Use when preparing a repository for open-source release or public publication. Triggers on phrases like "open source this repo", "make this public", "prepare for public release", "audit before publishing", "check for secrets before open-sourcing". Also use when someone asks to check a repo for leaked credentials, hardcoded infrastructure details, or PII before sharing externally.
---

# Pre-Open-Source Security Audit

A systematic audit checklist for preparing a private repository for public/open-source release. Based on real lessons learned from auditing production repositories where sensitive data was found in surprising places -- cloud project IDs scattered across dozens of files, JWT tokens, personal emails, service URLs, and even cache directories preserving secrets that had been removed from source files.

## When to Use

- Before making a private repo public on GitHub/GitLab
- Before submitting code to a competition, paper, or external review
- Before sharing a repo with an external party
- Periodically as a hygiene check on repos that may eventually go public

## Audit Checklist

Work through each category systematically. Run the grep/find patterns, review results, and flag findings.

### 1. Cloud Provider IDs and Project References

Hardcoded cloud identifiers propagate everywhere -- configs, scripts, CI pipelines, Dockerfiles, Terraform files, and documentation. Expect to find them in many more files than you think.

```bash
# GCP
grep -rn "project[_-]id\|project[_-]number" --include="*.py" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.toml" --include="*.sh" --include="*.tf" .
grep -rn "gcloud\|googleapis\.com\|cloudresourcemanager" --include="*.py" --include="*.sh" --include="*.yaml" .

# AWS
grep -rn "arn:aws:" .
grep -rn "[0-9]\{12\}" --include="*.py" --include="*.yaml" --include="*.json" --include="*.tf" .

# Azure
grep -rn "subscription[_-]id\|tenant[_-]id" --include="*.py" --include="*.yaml" --include="*.json" --include="*.tf" .
```

### 2. API Tokens, Keys, and Secrets

```bash
# JWT tokens
grep -rn "eyJ[A-Za-z0-9_-]*\.\|Bearer [A-Za-z0-9_-]" .

# API keys
grep -rn "api[_-]key\|api[_-]token\|api[_-]secret\|apikey" -i .
grep -rn "sk-[A-Za-z0-9]\{20,\}\|pk-[A-Za-z0-9]\{20,\}" .
grep -rn "AKIA[0-9A-Z]\{16\}" .
grep -rn "ghp_[A-Za-z0-9]\{36\}\|github_pat_" .

# Generic secrets
grep -rn "password\s*=\|passwd\s*=\|secret\s*=" -i .
grep -rn "private[_-]key\|SECRET_KEY\|SIGNING_KEY" .
```

### 3. Personal Emails and PII

```bash
# All email addresses
grep -rn "[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]*\.\(com\|org\|net\|io\|no\|co\|edu\)" .

# Personal email providers
grep -rn "@gmail\.\|@hotmail\.\|@yahoo\.\|@outlook\.\|@live\.\|@icloud\.\|@proton" .

# Author tags
grep -rn "@author\|Created by\|Maintained by" .
```

### 4. Internal URLs and Service Endpoints

```bash
# Cloud service URLs
grep -rn "run\.app\|cloudfunctions\.net\|appspot\.com" .

# Internal/staging/sandbox
grep -rn "staging\.\|sandbox\.\|internal\.\|dev\.\|localhost" .

# IP addresses
grep -rn "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" .
```

### 5. Docker Registry and Container References

```bash
grep -rn "gcr\.io/\|docker\.io/\|\.azurecr\.io/\|\.ecr\.\|\.dkr\.ecr\.\|ghcr\.io/" .
grep -rn "docker pull\|docker push\|image:" --include="*.yaml" --include="*.yml" --include="Dockerfile*" --include="*.sh" .
```

### 6. Cloud Storage Bucket Names

```bash
grep -rn "gs://\|storage\.googleapis\.com" .
grep -rn "s3://\|s3\.amazonaws\.com\|\.s3\." .
grep -rn "blob\.core\.windows\.net\|azureblob://" .
```

### 7. Hardcoded Paths

```bash
grep -rn "/workspaces/\|/home/[a-z]" .
grep -rn "C:\\\\Users\\\\\|/Users/[A-Z]\|/home/[a-z][a-z]*/" .
```

### 8. Team Member Names in Code and Filenames

```bash
# Names in filenames
find . -type f \( -name "*.py" -o -name "*.sh" \) | sort

# Names in TODOs, comments, and config
grep -rn "TODO.*[A-Z][a-z]* [A-Z]\|FIXME.*[A-Z][a-z]* [A-Z]\|HACK.*[A-Z][a-z]* [A-Z]" .
grep -rn "owner\|maintainer\|contact\|team" --include="*.yaml" --include="*.yml" --include="*.json" .
```

### 9. Tracked Cache and Build Artifacts

Cache files can preserve secrets from code that has already been cleaned. If caches are tracked in git, they may contain values you thought you removed.

```bash
find . -name "__pycache__" -type d 2>/dev/null
find . -name ".ruff_cache" -o -name ".mypy_cache" -type d 2>/dev/null
find . -name "*.pyc" -o -name "*.so" -o -name "*.o" 2>/dev/null
find . -name "node_modules" -type d 2>/dev/null
```

### 10. Operational Logs and Run Data

Logs often contain infrastructure details, error messages with connection strings, and full stack traces revealing system architecture.

```bash
find . -name "*.log" 2>/dev/null
find . -path "*/logs/*" -name "*.csv" 2>/dev/null
find . -path "*/runs/*" -o -path "*/outputs/*" -o -path "*/results/*" 2>/dev/null
find . -name "*.ipynb" 2>/dev/null
```

### 11. Environment and Credential Files

```bash
find . -name ".env" -o -name ".env.*" -o -name "*.env" 2>/dev/null
find . -name "credentials*" -o -name "secrets*" -o -name "service-account*" 2>/dev/null
find . -name "*.pem" -o -name "*.key" -o -name "*.p12" -o -name "*.pfx" 2>/dev/null
find . -name "terraform.tfstate*" -o -name "*.tfvars" 2>/dev/null
```

### 12. .gitignore Verification

```bash
cat .gitignore

# Check for tracked files that SHOULD be ignored
git ls-files --cached | grep -E "\.env|\.key|\.pem|credentials|secrets|__pycache__|\.pyc|\.ruff_cache|\.mypy_cache|\.log|terraform\.tfstate"
```

If tracked files match sensitive patterns, they need to be removed from git history, not just the working tree.

### 13. Git History Check

The working tree may be clean, but git history remembers everything.

```bash
# Author identities
git log --format="%an <%ae>" | sort -u

# Sensitive terms in commit messages
git log --all --oneline | grep -i "secret\|password\|token\|key\|credential\|api.key"

# Deleted files still in history
git log --all --diff-filter=D --name-only --pretty=format: | sort -u | grep -E "\.env|credential|secret|\.key|\.pem"
```

If sensitive data is found in git history, rewrite history (e.g., `git filter-branch` or BFG Repo Cleaner) before making the repo public.

## How to Fix

### Replacement Strategies

| Found | Replace With |
|-------|-------------|
| Cloud project ID | Placeholder or environment variable (`$GCP_PROJECT_ID`) |
| Account number | Placeholder (`123456789012`) or `$AWS_ACCOUNT_ID` |
| API keys/tokens | Environment variable reference or `your-api-key-here` |
| Personal email | `team@example.com` or remove |
| Internal URL | `https://your-service.example.com` or `$SERVICE_URL` |
| Bucket name | `your-bucket-name` or `$BUCKET_NAME` |
| Registry URL | `your-registry/your-image` or `$DOCKER_REGISTRY` |
| Hardcoded path | Relative path or `$WORKSPACE_DIR` |
| Team member name | Remove or genericize |

### Environment Variable Pattern

Create a `.env.example` (committed) showing required variables without values:

```bash
GCP_PROJECT_ID=
AWS_ACCESS_KEY_ID=
API_TOKEN=
SERVICE_URL=
BUCKET_NAME=
```

### Cleaning Git History

```bash
# BFG Repo Cleaner (recommended)
bfg --replace-text passwords.txt repo.git

# git filter-repo
git filter-repo --invert-paths --path path/to/secret-file

# After rewriting, purge old refs
git reflog expire --expire=now --all && git gc --prune=now --aggressive
```

### Bulk Find-and-Replace

```bash
# Preview
grep -rn "actual-project-id" . --include="*.py" --include="*.yaml"

# Replace
find . \( -name "*.py" -o -name "*.yaml" -o -name "*.json" \) \
  -exec sed -i 's/actual-project-id/${GCP_PROJECT_ID}/g' {} +
```

## Scoring (0-100)

Start at 100. Deduct points for each finding by severity:

| Severity | Examples | Deduction per finding |
|----------|----------|-----------------------|
| Critical | Hardcoded secrets, API keys, JWT tokens | -20 |
| High | Cloud project IDs, personal emails, internal URLs | -10 |
| Medium | Tracked cache files, operational logs, hardcoded paths | -5 |
| Low | Missing gitignore patterns, git history leaks | -2 |

| Score | Interpretation |
|-------|---------------|
| 90-100 | Release-ready -- no critical findings, minimal high-severity issues |
| 70-89 | Needs cleanup -- some high-severity findings remain |
| 50-69 | Significant exposure -- multiple high or critical findings |
| 0-49 | Not safe to release -- critical secrets or credentials exposed |

## Completion

Report directly to the user (as a message, not written to a file):

```
## Open-Source Audit: <repo or description>

### Findings
- Critical: <count> (list files)
- High: <count> (list files)
- Medium: <count> (list files)
- Low: <count> (list files)

### Files Affected
- <total count> files contain sensitive data

### Actions Taken
- <list of replacements or removals performed>

### Summary
- Total findings: <count>
- Files affected: <count>
- **Score: X/100** (<deduction breakdown>)
```

## Gotchas

Real issues discovered during production repository audits:

1. **Cache files preserve removed secrets.** `__pycache__/` and `.ruff_cache/` still contained old values after source files were cleaned. Always delete caches and verify `.gitignore` covers them.

2. **Cloud IDs scatter across dozens of files.** Project IDs propagate into configs, CI pipelines, shell scripts, Dockerfiles, Terraform, and docs. Expect to find them in far more places than anticipated.

3. **Team member names hide in filenames.** Scripts or configs named after people (e.g., `johns_deploy.sh`) are easy to miss with content-only searches. Audit filenames with `find`.

4. **Notebook outputs leak infrastructure.** Jupyter notebooks store cell outputs inline. A cell that printed environment info has those values baked into the `.ipynb` JSON.

5. **Git log reveals real identities.** Even with clean code, `git log` shows author names and emails. Rewrite history or start fresh if contributor privacy matters.

6. **Docker registry URLs embed project IDs.** URLs like `gcr.io/my-project/my-image` contain identifiers and appear in Dockerfiles, CI, and Kubernetes manifests.

7. **Run/output data contains sensitive content.** Result directories may reference infrastructure, internal URLs, or sensitive data. Audit `runs/`, `outputs/`, `results/`.

8. **`.env` with nonstandard suffixes.** `.env.local`, `.env.production`, `.env.staging` -- ensure `.gitignore` covers `.env.*` not just `.env`.

9. **Hardcoded `/workspaces/` paths.** VS Code devcontainer and Codespaces paths get embedded in scripts and test fixtures.

10. **Logs contain stack traces with connection strings.** Error tracebacks reveal internal paths, database URIs, and service architecture.

11. **`git filter-branch` leaves old refs.** After rewriting history, run `git reflog expire` and `git gc` to fully purge.

## Output Format

```markdown
# Open-Source Audit Report

## Summary
- Files scanned: <count>
- Issues found: <count>
- Critical (must fix before release): <count>
- Warnings (should fix): <count>

## Critical Issues
| # | Category | File | Line | Finding | Suggested Fix |
|---|----------|------|------|---------|---------------|

## Warnings
| # | Category | File | Line | Finding | Suggested Fix |
|---|----------|------|------|---------|---------------|

## Git History Issues
- Author emails exposing real identities: <list>
- Deleted files with sensitive names still in history: <list>

## .gitignore Gaps
- Missing patterns: <list>

## Recommended Actions
1. ...
```
