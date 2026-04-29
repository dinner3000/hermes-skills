---
name: journal-relate
description: "Find entries related to a given journal entry by shared tags, people, and keywords. Uses related.sh as backend."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [journal, memory, personal-memory-assistant, cross-reference, related]
    related_skills: [journal-record, journal-retrieve]
---

# Journal Relate

## Overview

Finds related journal entries by cross-referencing tags, people, and keywords. The user asks "what's related to this entry?" and the assistant uses `related.sh` to find connections.

## When to Use

- User asks "what's related to [entry]?"
- User asks "find me entries similar to [entry]"
- User wants to discover connections between past entries
- User asks "what else did I write about [topic] that's connected?"

## Trigger Phrases

- "What's related to [entry title]?"
- "Find similar entries to [title]"
- "Find connections to [title]"

## Process

### Step 1: Identify the Entry

Determine which entry the user is asking about. They can reference it by:
- Filename fragment: "what's related to learning-rust?"
- Title: "what's related to Q2 sprint planning?"
- Date: "what's related to the Apr 28 entry about sprint planning?"

### Step 2: Run related.sh

```bash
cd ~/projects/personal-memory-assistant && ./scripts/related.sh "query"
```

Use `-t` for detailed breakdown showing which tags/people/keywords match.

### Step 3: Present Results

Summarize the connections naturally:

"I found 3 entries related to [title]:
- [entry1] — shares the [tag] tag
- [entry2] — also mentions [person]
- [entry3] — shares keywords: [kw1], [kw2]"

## Example

**User:** "What's related to my weekend hike entry?"

**Assistant runs:**
```bash
cd ~/projects/personal-memory-assistant && ./scripts/related.sh "weekend-hike"
```

**Response:** "I found 3 related entries:
1. Morning run 10K — shared tag: health
2. Budget review — shared tag: life
3. First day at new co-working space — shared tag: life"

## Verification

- [ ] related.sh ran and returned results
- [ ] Results were presented with the relationship reason (tag/person/keyword)
- [ ] If no results, user was informed
