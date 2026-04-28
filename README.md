# Hermes Skills — Personal Collection

My custom Hermes Agent skills, separated from built-in skills and tracked in their own repo.

## How it works

Skills live here and are symlinked into `~/.hermes/skills/<category>/` so Hermes can find them.

```
~/projects/hermes-skills/          ← this repo (git-tracked)
└── productivity/
    ├── project-bootstrapper/      ← turn any idea into a managed project
    └── project-continue/          ← resume any bootstrapped project

~/.hermes/skills/<category>/...    ← symlinks pointing here
```

## Adding a new skill

I'll create new custom skills here automatically going forward.

## Updating a skill

Edit the SKILL.md here, commit, push. The symlink means Hermes picks up changes immediately.
