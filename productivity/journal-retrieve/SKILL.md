---
name: journal-retrieve
description: "Search, summarize, and retrieve journal entries from the personal-memory-assistant project. The user asks about past entries, and I use search.sh and summary.sh to find and present answers."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [journal, memory, personal-memory-assistant, retrieval, search]
    related_skills: [journal-record, project-continue]
---

# Journal Retrieve

## Overview

Answers questions about past journal entries by searching and summarizing the journal directory. The user asks naturally ("what did I do last week?", "find entries about Rust", "summarize my work meetings") and the assistant uses the project's search and summary scripts to find the relevant entries.

## When to Use

- User asks about past events, ideas, or notes in their journal
- User wants to find entries by keyword, tag, date, or person
- User wants a summary of a time period
- User asks "what did I do...", "find where I...", "remind me about...", "search for..."

**Don't use for:** Questions about things that aren't in the journal. If unsure, search first, then say "I didn't find anything about that in your journal."

## Project Location

```
~/projects/personal-memory-assistant/
Scripts: ~/projects/personal-memory-assistant/scripts/
Journal: ~/projects/personal-memory-assistant/journal/
```

## Trigger Phrases

Any question about past information that might be in the journal:

- "What did I do last week / last month?"
- "Find entries about [topic]"
- "Search for [keyword]"
- "Remind me what I discussed with [person]"
- "Summarize my [tag] entries"
- "Did I write about [topic]?"

## Disambiguation: Journal vs Web Search

The user's query may be ambiguous — "search for Rust" could mean their journal or the internet.

| User says | Likely intent |
|---|---|
| "Search for [X] entries" | Journal — "entries" is journal-specific |
| "Find where I [verb] [X]" | Journal — refers to past personal actions |
| "Search my journal for [X]" | Journal — explicit |
| "Search [X]" alone | **Ambiguous** — ask: "Search your journal or the web?" |
| "Search the web for [X]" | Web — explicit |
| "Look up [X]" alone | **Ambiguous** — ask to clarify |
| "Google [X]" | Web — explicit |
| "Find [X] online" | Web — explicit |

When ambiguous, ask: "Search your journal or the web?" before proceeding.

## Process

### Step 1: Understand the Query

From the user's question, determine:

| Aspect | What to look for | Script to use |
|--------|-----------------|---------------|
| **Keyword search** | Specific word or phrase | `search.sh "query"` |
| **Tag search** | A category or topic | `search.sh -t "tag"` |
| **Time period** | "Last week", "this month", etc. | `summary.sh -w` or `-m` |
| **Date range** | Specific dates mentioned | `summary.sh -f DATE -t DATE` |
| **Person** | Someone's name | `search.sh "Name"` |
| **Filename** | Partial filename | `search.sh -f "pattern"` |
| **Compact view** | Just counts, no snippets | `search.sh -c "query"` |

### Step 2: Run the Query

```bash
cd ~/projects/personal-memory-assistant && ./scripts/search.sh "query"
cd ~/projects/personal-memory-assistant && ./scripts/search.sh -t "tag"
cd ~/projects/personal-memory-assistant && ./scripts/summary.sh -w
cd ~/projects/personal-memory-assistant && ./scripts/summary.sh -f 2026-04-20 -t 2026-04-25
```

### Step 3: Interpret and Respond

Present the results to the user in a natural way:

- **If found:** Summarize what was found. "I found 3 entries from last week mentioning [topic]..." Then list them with dates and summaries.
- **If not found:** "I searched your journal for [query] and didn't find anything. Want to record it now?"
- **If ambiguous:** Ask clarifying questions.

### Step 4: Deep Dive (optional)

If the user wants details on a specific result, pipe from search to summary or search with a more specific query.

## Examples

**User:** "What did I do last week?"

**Assistant runs:**
```bash
cd ~/projects/personal-memory-assistant && ./scripts/summary.sh -w
```

**Response:** "Here's your week (Apr 21-27): 3 entries. Topics: work, learning, life. Highlights: met Alice about Q2 planning, started learning Rust, weekend hike at Twin Peaks."

---

**User:** "Find where I mentioned Alice"

**Assistant runs:**
```bash
cd ~/projects/personal-memory-assistant && ./scripts/search.sh "Alice"
```

**Response:** "I found Alice mentioned in 2 entries:
- Apr 28 — Q2 sprint planning: Alice to lead the search feature
- Apr 28 — Code review: reviewed Alice's search PR"

---

**User:** "Summarize my learning entries"

**Assistant runs:**
```bash
cd ~/projects/personal-memory-assistant && ./scripts/search.sh -t "learning"
```

**Response:** "Entries tagged 'learning': Rust (ownership model), Go (goroutines), Deep Work book notes. 3 entries total."

## Common Pitfalls

1. **Don't confuse tag search with content search** — `-t "rust"` only finds entries with "rust" in the Tags section; a plain search finds it anywhere
2. **Tag search supports partial matches** — `-t "project"` will match `project:personal-memory-assistant`
3. **Date range respects filename dates** — only journal entries dated within the range will appear
4. **If the query is too broad** (returns many results), use `-c` (compact) to get an overview first
5. **Always run the script** — don't guess what's in the journal. The scripts are fast and accurate

## Verification

- [ ] Correct script was chosen based on query type
- [ ] Script ran successfully and returned results
- [ ] Results were presented naturally to the user
- [ ] If no results, user was informed and offered to record
