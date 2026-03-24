# Best Practices

A reusable template for bootstrapping projects with AI-agent-friendly tooling, structured workflows, and quality gates.

**Repo:** `https://github.com/mariusog/best_practices`

## Getting Started

### New project

Open Claude Code and paste:

```
Clone https://github.com/mariusog/best_practices and use it to bootstrap
a new project for me. Ask me about what I'm building, my preferred
language/stack, and where to put it -- then set everything up.
```

### Existing project

Open Claude Code in your project directory and paste:

```
Review the best_practices template at https://github.com/mariusog/best_practices
and help me integrate what's useful into this project. Look at the CLAUDE.md,
agents, skills, CI workflow, hooks, and gitignore. Ask me what I want to
adopt -- then adapt it to fit our existing structure and conventions.
```

The agents will prompt for any remaining project-specific details on first use.

## What's Inside

### Project Instructions (`CLAUDE.md`)

The main configuration file. Contains a **Project Tooling** table (swap commands per language), AI agent ground rules, code quality standards (SOLID, size limits, no magic numbers), testing standards, three-tier logging architecture, multi-agent coordination protocol, git conventions, and a **Skill Selection Guide** decision tree that maps tasks to the right skill.

### Agents (`.claude/agents/`)

Five agents designed to run as an autonomous parallel team:

| Agent | Role | Runs |
|-------|------|------|
| `lead-agent` | Coordination, architecture, strategic planning, quality gates | First — plans tasks, then launches others |
| `core-agent` | Algorithms, data structures, performance | In parallel after lead |
| `feature-agent` | Business logic, decision workflows | In parallel after lead |
| `qa-agent` | Testing, auditing, security enforcement | In parallel after lead (proactive review) |
| `researcher-agent` | Domain research, external references, technique evaluation | On demand |

**How to use the agents:**

For a single task, just ask Claude -- it will pick the right approach without needing agents.

For larger work that benefits from parallelism, start the lead-agent:

```
Run as the lead-agent. The goal is: [describe the work].
```

The lead-agent will diagnose the codebase, create tasks in `TASKS.md`, write per-agent plan files (`TASKS-core.md`, `TASKS-feature.md`, `TASKS-qa.md`), then spawn core/feature/qa as parallel worktree subagents. Each agent works in an isolated copy of the repo on its own branch. When agents complete, the lead reviews their results, merges passing branches, and iterates.

You can also invoke agents individually:

```
Run as the qa-agent. Audit src/handlers/ for test coverage gaps.
Run as the researcher-agent. What's the best approach for caching API responses?
```

**Coordination model**: Each agent works from its own plan file -- no shared-file contention. Agents that hit blockers mark them as `BLOCKED` in their plan file. The lead triages blockers, resolves them, and re-spawns agents as needed.

### Skills (`.claude/skills/`) — 28 total

| Category | Skills |
|----------|--------|
| Code quality | `tdd-cycle`, `code-review`, `refactor`, `lint` |
| Architecture | `project-architecture`, `data-pipeline`, `caching-strategies`, `error-handling`, `performance-optimization` |
| Testing | `test-coverage`, `integration-testing`, `browser-testing`, `reproducibility` |
| Debugging | `debugging`, `debug-visualization`, `logging-observability` |
| Planning | `write-a-prd`, `prd-to-plan`, `prd-to-issues`, `grill-me` |
| Shipping | `security-scan`, `open-source-audit`, `production-quality`, `pr-workflow`, `dependency-management`, `update-documentation`, `readme-standards` |
| Meta | `skill-creator` |

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
| `.devcontainer/` | Devcontainer (see below) |

### Devcontainer (`templates/.devcontainer/`)

A ready-to-use devcontainer config with Claude Code, GitHub CLI, and Node LTS pre-installed. The template defaults to Python 3.12 -- **adjust for your stack:**

- **Python project:** Works as-is. Change the Python version if needed.
- **TypeScript/Node project:** Remove the Python feature, keep Node. Add your package manager.
- **Go/Rust/other:** Replace the Python feature with the appropriate [devcontainer feature](https://containers.dev/features). Remove the Python-specific VS Code extensions.

The Node version is pinned to `"lts"` because the devcontainer feature defaults to Node 18 (EOL), which can cause compatibility issues with Claude Code and other modern tooling.

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
- **Multi-agent safe**: Per-agent plan files eliminate contention. File ownership prevents conflicts. Lead-agent orchestrates quality gates and merges.

## License

Unlicensed. Use freely.
