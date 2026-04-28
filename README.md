# Hermes Skills — Personal Collection

My custom Hermes Agent skills, separated from built-in skills and tracked in their own repo.

## Quick Install (new machine)

One command:

```bash
curl -fsSL https://raw.githubusercontent.com/dinner3000/hermes-skills/main/install.sh | bash
```

Or clone and run manually:

```bash
git clone https://github.com/dinner3000/hermes-skills.git ~/projects/hermes-skills
cd ~/projects/hermes-skills
chmod +x install.sh
./install.sh
```

## What it does

The install script:

1. Clones (or updates) this repo to `~/projects/hermes-skills/`
2. Symlinks every skill into `~/.hermes/skills/<category>/` so Hermes finds them
3. Verifies all symlinks are correct

## How it works

```
~/projects/hermes-skills/          ← this repo (git-tracked)
└── productivity/
    ├── project-bootstrapper/      ← turn any idea into a managed project
    └── project-continue/          ← resume any bootstrapped project

~/.hermes/skills/<category>/...    ← symlinks pointing to this repo
```

Skills are actual files in this repo. The `~/.hermes/skills/` directory only holds symlinks. This means:

- **Edit here** — SKILL.md files live here, edit freely
- **`git commit + push`** — saves your changes
- **`git pull` on another machine** — updates the skills there
- **Hermes picks up changes immediately** — symlinks resolve at read time

## Skills included

| Skill | Description |
|---|---|
| `project-bootstrapper` | Turn any idea into a structured, git-tracked, best-practice project with docs, GitHub |
| `project-continue` | Resume any bootstrapped project in a new session — reads CHANGELOG, ROADMAP, ADRs |

## Adding a new skill

New skills are created by Hermes during a session. After creation, they're moved to this repo and symlinked back. Just commit and push to save them.

## Updating a skill

Edit the `SKILL.md` file in the relevant category folder, commit, and push:

```bash
git add -A
git commit -m "update: description of change"
git push
```

On another machine, `git pull` updates the symlinked files.

## Manual setup (without the install script)

```bash
# 1. Clone the repo
git clone https://github.com/dinner3000/hermes-skills.git ~/projects/hermes-skills

# 2. Symlink each skill so Hermes can find it
for skill_dir in ~/projects/hermes-skills/*/*/; do
  rel_path="${skill_dir#$HOME/projects/hermes-skills/}"
  target="$HOME/.hermes/skills/$rel_path"
  mkdir -p "$(dirname "$target")"
  ln -sf "$skill_dir" "$target"
done

# 3. Verify
ls -la ~/.hermes/skills/*/project-*
```
