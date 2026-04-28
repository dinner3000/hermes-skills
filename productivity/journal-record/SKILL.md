---
name: journal-record
description: "Record a journal entry in the personal-memory-assistant project from natural language. The user tells me something to remember, I structure it and save it."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [journal, memory, personal-memory-assistant, recording]
    related_skills: [project-continue]
---

# Journal Record

## Overview

Saves user-supplied information as a structured journal entry in the personal-memory-assistant project. The user speaks naturally ("I had coffee with Alice today, we discussed the roadmap"), and the assistant extracts the key fields and writes a formatted entry via `new-entry.sh`.

## When to Use

- User says something they want to remember: "remember that...", "note this down...", "save this...", "I want to record..."
- User shares a fact, event, idea, meeting recap, or decision
- User asks you to "journal this" or "log this"

**Don't use for:** General conversation that isn't worth saving permanently. Use your judgment — not every exchange needs an entry.

## Project Location

```
~/projects/personal-memory-assistant/
```

## Trigger Phrases

Any natural language indicating the user wants to save something. Examples:

- "Remember that I..."
- "Note this down: ..."
- "Save this to my journal: ..."
- "I had a meeting with X about Y..."
- "Log this: ..."
- "Record that ..."

## Process

### Step 1: Extract Fields

From the user's message, infer:

| Field | Source | Notes |
|-------|--------|-------|
| **Title** | Main topic of the message | Keep concise (5-10 words). Use title case. |
| **Summary** | One-sentence takeaway | A concise "what happened" in ~10 words. |
| **Details** | Full context | The meat of the entry. Use bullet points for clarity. |
| **Tags** | Topics, categories, project names | Use the recommended categories from journal.yaml: work, life, health, finance, learning, social, ideas, projects, travel, decisions. Also use prefixes: person:name, project:name, location:name. |
| **People** | Any people mentioned | Extract names only. |

### Step 2: Save Entry

Run the script:

```bash
cd ~/projects/personal-memory-assistant && ./scripts/new-entry.sh -m "Title" -s "Summary" -d "Details line 1\nDetails line 2" -g "tag1, tag2" -p "Person1, Person2"
```

Flags to use:
- `-m "Title"` — always use message mode (no editor)
- `-s "Summary"` — one-line summary
- `-d "details"` — use `\n` for multi-line bullet points
- `-g "tags"` — comma-separated tags
- `-p "people"` — comma-separated people (only if people are mentioned)

### Step 3: Confirm

Tell the user what was saved:

```
Saved to journal: [date] — [title]
  Tags: [tags]
  File: journal/YYYY/MM-DD-title.md
```

## Examples

**User:** "Remember that Alice and I decided to push the deadline to next Friday."

**Assistant would extract:**
- Title: "Deadline pushed to next Friday"
- Summary: "Decided with Alice to extend the deadline"
- Details: "- Agreed with Alice to push the deadline to next Friday\n- New due date: next Friday"
- Tags: "work, person:alice, decisions"
- People: "Alice"

**User:** "Had a great idea for a new feature — a timeline view that shows journal entries alongside my GitHub commits."

**Assistant would extract:**
- Title: "Idea: timeline view with GitHub integration"
- Summary: "Brainstormed a feature combining journal entries and GitHub activity"
- Details: "- Timeline view idea: show journal entries alongside GitHub commits\n- Would give a unified view of what happened each day"
- Tags: "ideas, projects, productivity"

## Common Pitfalls

1. **Don't save mundane chitchat** — only save when the user explicitly indicates or the content is clearly worth keeping (decisions, events, ideas, people met, notable facts)
2. **Tags should be useful for future search** — include project:name for project-related entries so they're findable later
3. **Details should be informative** — don't just repeat the summary. Write substantive bullet points that the user would want to find months later
4. **If unsure about any field, ask** — don't guess on critical details like a person's name or a date
5. **Date is always today** — `new-entry.sh` handles this automatically

## Verification

- [ ] Entry file was created in journal/YYYY/
- [ ] All sections are populated (Tags, Summary, Details, People if applicable)
- [ ] Tags use the recommended categories from journal.yaml
- [ ] User was shown a confirmation with the file path
