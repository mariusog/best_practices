# Best Practices

A reusable template for bootstrapping projects with AI-agent-friendly tooling, structured workflows, and quality gates.

## What's Inside

### Project Instructions (`CLAUDE.md`)

The main configuration file. Contains a **Project Tooling** table (swap commands per language), AI agent ground rules, code quality standards (SOLID, size limits, no magic numbers), testing standards, three-tier logging architecture, multi-agent coordination protocol, git conventions, and a **Skill Selection Guide** decision tree that maps tasks to the right skill.

### Agents (`.claude/agents/`)

| Agent | Role |
|-------|------|
| `lead-agent` | Architecture, cross-cutting changes, task design |
| `core-agent` | Algorithms, data structures, computation |
| `feature-agent` | Business logic, decision workflows |
| `qa-agent` | Testing, benchmarking, SOLID enforcement |

### Skills (`.claude/skills/`) — 26 total

| Category | Skills |
|----------|--------|
| Code quality | `tdd-cycle`, `code-review`, `refactor`, `lint` |
| Architecture | `project-architecture`, `data-pipeline`, `caching-strategies`, `error-handling`, `performance-optimization`, `improve-codebase-architecture` |
| Testing | `test-coverage`, `integration-testing`, `reproducibility` |
| Debugging | `debugging`, `debug-visualization`, `logging-observability` |
| Planning | `write-a-prd`, `prd-to-plan`, `prd-to-issues`, `grill-me` |
| Shipping | `security-scan`, `production-quality`, `pr-workflow`, `dependency-management`, `update-documentation`, `readme-standards` |

See the **Skill Selection Guide** in `CLAUDE.md` for when to use each skill.

### Templates (`templates/`)

| File | Purpose |
|------|---------|
| `pyproject.toml` | Python config (ruff, mypy, pytest) |
| `conftest.py` | Shared test fixtures and factories |
| `constants.py` | Named constants and tuning parameters |
| `.gitignore` | Multi-language gitignore |
| `TASKS.md` | Master task board (lead-agent owned) |
| `TASKS-agent.md` | Per-agent plan file template (one per agent) |
| `.claude/settings.json` | Claude Code hook configuration |
| `.claude/hooks/` | Pre-commit test gate and post-edit linter |
| `.github/workflows/ci.yml` | GitHub Actions CI pipeline |

### Bootstrap Script (`bootstrap.sh`)

Copies the full structure into a new project directory, creates `src/`, `tests/`, `logs/`, `docs/`, sets up language-specific config, and initializes git. Merges safely into existing directories without overwriting files.

## Quick Start

```bash
./bootstrap.sh /path/to/new-project --lang python
```

Supported languages: `python`, `typescript`, `go`, `rust`, `ruby`.

### Manual Setup

1. Copy `.claude/` and `CLAUDE.md` into your project root
2. Update the **Project Tooling** table in `CLAUDE.md` for your language
3. Copy the templates you need from `templates/`
4. Update the **File Ownership** table with your file paths

See the Bootstrapping section at the bottom of `CLAUDE.md` for full details.

## Design Principles

- **Language-neutral**: Principles are universal. The Tooling table is the only place to change for a new language.
- **AI-agent-friendly**: Token-efficient log formats (CSV over JSON lines), bounded command output, text-only visualization, three-tier log architecture (summary first, drill down on demand).
- **Reproducible**: All randomized code requires seeds. Benchmarks use fixed seed lists. Same seeds = same results.
- **Quality-gated**: Hooks block commits if tests fail. CI mirrors local checks. Every public method must have a test.
- **Multi-agent safe**: Task board, file ownership, conflict prevention protocol for parallel agent work.

## License

Unlicensed. Use freely.
