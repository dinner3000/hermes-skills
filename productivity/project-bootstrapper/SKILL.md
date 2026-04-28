---
name: project-bootstrapper
description: "User has an idea and wants to turn it into a structured, git-tracked, best-practice project with docs, config, scripts, and optional GitHub remote."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [project, scaffold, git, github, documentation, best-practices]
    related_skills: [writing-plans]
---

# Project Bootstrapper

## Overview

Takes a raw idea (project concept, tool, system, app) and scaffolds a complete, best-practice project structure — docs, config, scripts, git, GitHub — in a single pass. The output is a working repo with professional-grade documentation that the user can start building on immediately.

This skill captures the exact process used to create the Personal Memory Assistant project.

## When to Use

- User says: "I want to start a new project for..." or "Turn this idea into a managed project"
- User has a concept that needs structure, docs, version control, and remote backup
- Any project that will span multiple sessions and needs proper tracking

**Don't use for:** Simple one-file scripts, temporary experiments, or projects that already have a structure.

## Project Location Convention

**Default:** `~/projects/<project-name>/` (e.g., "personal-memory-assistant" → `~/projects/personal-memory-assistant/`)

The user can specify a different path, otherwise always use this convention. This makes project discovery predictable for `project-continue`.

## Process

### Phase 1: Understand & Design

1. **Clarify the project idea** — what problem does it solve? Who is it for? What's the MVP?
2. **Design the architecture** — propose a two-layer model (what the tool/system does + how it's documented)
3. **Propose the folder structure** — show the user before building

### Phase 2: Scaffold — Core Docs

Create these files under the project root directory (default: `~/projects/<project-name>/`):

| File | Content |
|---|---|
| `README.md` | What, why, quick start, links to other docs |
| `docs/PRD.md` | Problem statement, user stories, success criteria, out-of-scope |
| `docs/ARCHITECTURE.md` | Context, goals/non-goals, system design, data flow, alternatives |
| `docs/TECH-STACK.md` | Each technology choice with rationale, alternatives table |
| `docs/ROADMAP.md` | Phased development plan (numbered phases with checkboxes) |
| `docs/CHANGELOG.md` | Keep a Changelog format — initial entry about project creation |
| `docs/VALIDATION.md` | Test scenarios with ID, steps, expected result, result column |
| `docs/decisions/001-<title>.md` | First ADR (most foundational decision about the project) |

### Phase 3: Scaffold — Config & Scripts

| File | Content |
|---|---|
| `config/.env.example` | Template env vars with comments |
| `config/<project>.yaml` | Project-specific configuration (format rules, defaults) |
| `scripts/<action>.sh` | Helper scripts: new-entry, search, digest, backup (as applicable) |
| `.gitignore` | Ignore patterns for the project type |
| `LICENSE` | MIT by default (ask if user wants something else) |

### Phase 4: First Content Entry

Create an initial content entry that documents the project creation itself. For a journal-based project:

```
journal/YYYY/MM-DD-project-created.md
```

### Phase 5: Git + GitHub

```bash
cd ~/projects/<project-name>

# Init
git init
git branch -m main
git config user.email "..."    # Use global or local
git config user.name "..."

# First commit
git add -A
git commit -m "feat: initial project scaffold"

# GitHub (gh must be installed and authenticated)
# Try SSH first, fall back to HTTPS with gh token
git remote add origin git@github.com:<user>/<project>.git
git push -u origin main 2>&1 || \
  git remote set-url origin "https://$(gh auth token)@github.com/<user>/<project>.git" && \
  git push -u origin main && \
  git remote set-url origin https://github.com/<user>/<project>.git && \
  git config credential.helper '!f() { echo "username=token"; echo "password=$(gh auth token)"; }; f'
```

### Phase 6: Save to Memory (consistent format)

Record in Hermes memory using this exact format so the `project-continue` skill can find it later:

```
Project "PROJECT-NAME" at ~/projects/PROJECT-NAME/. GitHub: https://github.com/USER/REPO. Key facts: <one-liner>.
```

Example:
```
Project "personal-memory-assistant" at ~/projects/personal-memory-assistant/. GitHub: https://github.com/dinner3000/personal-memory-assistant. Key facts: personal life/work memory assistant using Hermes + markdown journal.
```

Always use this format. The `project-continue` skill relies on the `Project "..." at ...` pattern to discover projects.

## Best Practice Doc Principles

### PRD
- Not a dry requirements list. Write user stories ("As a user, I can...")
- Include success criteria (measurable)
- Include out-of-scope for v1
- Include future considerations

### ARCHITECTURE
- Use ASCII diagrams for data flow
- Include goals AND non-goals (equally important)
- Show alternatives considered and why they were rejected
- Document the data flow: recording path and retrieval path

### TECH-STACK
- Alternatives comparison table (Option A | Verdict | Reason)
- Dependency graph (what requires what)
- Future tech considerations

### ROADMAP
- Numbered phases with checkboxes
- Start with what's already done (✅)
- Scope realistically: Foundation → Automation → Advanced

### CHANGELOG
- Keep a Changelog format (keepachangelog.com)
- Reverse chronological
- Semantic versioning (start at 0.1.0)

### VALIDATION
- Numbered test scenarios (T-REC-01, T-RET-01, T-DUR-01, T-EDG-01)
- Each: Scenario, Steps, Expected Result, Result column
- Test summary table at the end

### ADRs
- Named: `NNN-title-with-hyphens.md`
- Sections: Context, Decision, Consequences (positive, negative, neutral)

## Common Pitfalls

1. **Mirroring the user's words literally** — they said "requirements, analysis, architecture..." — don't name files that way. Use proper doc names (PRD, ARCHITECTURE, etc.)
2. **Separate "progress.md" and "tasks.md"** — replace with CHANGELOG.md + ROADMAP.md (industry standard)
3. **Forgetting git user config** — check `git config user.email` exists before first commit
4. **SSH vs HTTPS** — try SSH first for `git push`, fall back to HTTPS with `gh auth token` if SSH connection fails
5. **gh not installed** — ask user to install it with `sudo apt install gh && gh auth login`; cannot sudo automatically
6. **First journal entry** — always create an entry for the project creation itself; it's the first real test of the system

## Verification Checklist

- [ ] User approved the structure before building
- [ ] All 7 core docs created (README, PRD, ARCHITECTURE, TECH-STACK, ROADMAP, CHANGELOG, VALIDATION)
- [ ] First ADR created
- [ ] Config files created
- [ ] Scripts created and `chmod +x`
- [ ] `.gitignore` and `LICENSE` created
- [ ] First content entry created
- [ ] `git init`, `git add -A`, `git commit -m`
- [ ] Branch renamed to `main`
- [ ] GitHub repo created and pushed
- [ ] Credential helper configured for future pushes
- [ ] Project path saved to Hermes memory
- [ ] User told them exactly where everything is
