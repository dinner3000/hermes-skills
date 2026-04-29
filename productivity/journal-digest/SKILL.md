---
name: journal-digest
description: "Generate and deliver periodic (weekly) summaries from the personal-memory-assistant journal. Runs via Hermes cron job."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [journal, memory, personal-memory-assistant, digest, cron, summary]
    related_skills: [journal-record, journal-retrieve, summary]
---

# Journal Digest

## Overview

Generates weekly summaries of journal activity and saves them as journal entries. Runs automatically via a Hermes cron job — no manual intervention needed.

The digest uses `summary.sh -w --save` to create a structured summary entry covering the last 7 days, then commits and pushes to GitHub.

## When to Use

- User asks about automatic summaries or digests
- User wants to set up, modify, or check the digest cron job
- User asks "what does the weekly digest look like?"

## How It Works

A Hermes cron job runs every Sunday at 20:00 (8 PM) that:

1. Changes to the project directory
2. Runs `./scripts/summary.sh -w --save` to generate and save a weekly summary entry
3. Commits and pushes any new entries to GitHub
4. Reports back to the user what was generated

No delivery to external platforms (Telegram, email) — the summary is saved as a journal entry that the user can read at their convenience.

## Cron Setup

The cron job was configured with:

- **Schedule:** Every Sunday at 20:00
- **Command:** `cd ~/projects/personal-memory-assistant && ./scripts/summary.sh -w --save && git add -A && git commit -m "chore: weekly digest" && git push`
- **Skills loaded:** journal-digest, journal-record
- **Toolsets:** terminal, file

## Verification

- [ ] Cron job is active: `./scripts/cron.sh list` or `hermes cron list`
- [ ] There's a summary entry in `journal/YYYY/` from the last run
- [ ] The summary covers the correct week (last 7 days)
- [ ] Entries are pushed to GitHub after the digest runs
