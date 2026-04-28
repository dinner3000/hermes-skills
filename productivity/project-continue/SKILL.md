---
name: project-continue
description: "Use when the user wants to continue working on any project that was bootstrapped with project-bootstrapper. Finds the project from memory, loads its state from docs, and presents a summary with next-step proposal."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [project, continuation, resume, workflow]
    related_skills: [project-bootstrapper]
---

# Project Continue — Generic Session Continuation

## Overview

This skill is the counterpart to `project-bootstrapper`. Whenever you start a new session and want to pick up work on an existing bootstrapped project, this skill discovers the project, loads its current state, and presents a coherent summary — no context lost.

## Trigger

User says anything about continuing, resuming, or picking up a project that was bootstrapped with `project-bootstrapper`.

Examples:
- "Continue the [name] project"
- "Let's pick up where we left off on [name]"
- "Resume work on [name]"
- "What's the status of [name]?"

## How It Discovers the Project

**Convention:** Projects bootstrapped by `project-bootstrapper` live at `~/projects/<project-name>/`.

Three methods, tried in order:

### Method 1: Memory Lookup

Scan Hermes memory for entries matching the pattern:

```
Project "PROJECT-NAME" at ~/projects/PROJECT-NAME/
```

The `project-bootstrapper` skill saves projects in this exact format during Phase 6.

Look for the project name the user mentioned. Extract the path from the `at ` part.

### Method 2: Convention Fallback

If not found in memory, check the convention path:

```bash
ls ~/projects/<project-name>/README.md
```

If the file exists, the project lives there.

### Method 3: Ask the User

If both fail, ask: "I don't have that project recorded. Where is it located?"

## Steps — Execute in order, every time

### Step 1: Discover Project

Extract project name from user message. Search memory for `Project "..." at ...`. Fall back to convention or ask.

### Step 2: Read CHANGELOG.md

```bash
cat ~/projects/<project-name>/docs/CHANGELOG.md | head -40
```

Latest entries tell us what was done last.

### Step 3: Read ROADMAP.md

```bash
cat ~/projects/<project-name>/docs/ROADMAP.md
```

Identifies current phase and remaining tasks.

### Step 4: Read the latest ADR

```bash
ls -t ~/projects/<project-name>/docs/decisions/ 2>/dev/null | head -1
cat ~/projects/<project-name>/docs/decisions/<latest> 2>/dev/null
```

Latest design thinking.

### Step 5: Search past sessions

Use `session_search` with the project name as query to catch recent context not yet documented.

### Step 6: Present state summary

Format your response like this:

```
━━━ [Project Name] — Status ━━━

Phase: [current phase name]
Last worked on: [what was done, from CHANGELOG]
Last decision: [latest ADR title]

Completed:
  - [X] item 1

Next up:
  - [ ] item 1  ← recommended next
  - [ ] item 2

Want to start with [recommended next]?
```

If the project has a journal/ directory, also mention recent entries.

### Step 7: Execute

Once the user picks a task, work on it. After each meaningful change:

1. Update `docs/CHANGELOG.md` — append a new entry under `## [Unreleased]`
2. If a major decision was made, create a new ADR: `docs/decisions/NNN-title.md`
3. Update `docs/ROADMAP.md` — check off completed items
4. Commit and push:

```bash
cd ~/projects/<project-name>
git add -A
git commit -m "type: description of what was done"
git push
```

## Common Pitfalls

1. **Don't assume a single project** — user may have multiple bootstrapped projects. Match by name from their message.
2. **ADRs directory might be empty** — only the first ADR is created at bootstrap. Handle gracefully.
3. **Don't skip session_search** — user may have shared context not in any doc file.
4. **Always update CHANGELOG before ending** — otherwise next session loses context.
5. **Push after every session** — so GitHub has the latest state.

## Verification

- [ ] Project discovered from memory (or user told us the path)
- [ ] CHANGELOG read
- [ ] ROADMAP read
- [ ] Latest ADR read (if any)
- [ ] session_search done
- [ ] State summary presented to user
- [ ] User picked a task
- [ ] CHANGELOG updated after work
- [ ] Committed and pushed
