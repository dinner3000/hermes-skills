#!/usr/bin/env bash
#
# install.sh — Install custom Hermes skills on a new machine
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/dinner3000/hermes-skills/main/install.sh | bash
#   # Or locally:
#   ./install.sh
#
# What it does:
#   1. Clones (or updates) the hermes-skills repo to ~/projects/hermes-skills/
#   2. Symlinks every skill from the repo into ~/.hermes/skills/<category>/
#   3. Verifies the links work
#

set -euo pipefail

REPO_URL="https://github.com/dinner3000/hermes-skills.git"
SKILLS_DIR="${HOME}/projects/hermes-skills"
HERMES_SKILLS="${HOME}/.hermes/skills"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}═══ Hermes Custom Skills Installer ═══${NC}"
echo ""

# ── Step 1: Check prerequisites ──
echo -e "${YELLOW}[1/5]${NC} Checking prerequisites..."

if ! command -v git &>/dev/null; then
  echo -e "${RED}Error: git is not installed.${NC}"
  echo "Install it with: sudo apt install git"
  exit 1
fi

if [ ! -d "${HERMES_SKILLS}" ]; then
  echo -e "${YELLOW}Warning: ${HERMES_SKILLS} does not exist.${NC}"
  echo "Hermes may not be installed yet. Skills will be symlinked once it is."
  mkdir -p "${HERMES_SKILLS}"
fi

echo "  git: ✔"
echo ""

# ── Step 2: Clone or update repo ──
echo -e "${YELLOW}[2/5]${NC} Fetching skills repo..."

if [ -d "${SKILLS_DIR}/.git" ]; then
  echo "  Repo exists at ${SKILLS_DIR}. Pulling latest..."
  cd "${SKILLS_DIR}"
  git pull --ff-only 2>&1 | sed 's/^/  /'
else
  echo "  Cloning to ${SKILLS_DIR}..."
  mkdir -p "${SKILLS_DIR}"
  git clone "${REPO_URL}" "${SKILLS_DIR}" 2>&1 | sed 's/^/  /'
fi

echo ""

# ── Step 3: Create symlinks ──
echo -e "${YELLOW}[3/5]${NC} Symlinking skills into ${HERMES_SKILLS}..."

LINK_COUNT=0
SKIP_COUNT=0

find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -type d | while read -r skill_dir; do
  # Compute relative path: e.g., "productivity/project-bootstrapper"
  rel_path="${skill_dir#${SKILLS_DIR}/}"
  category=$(dirname "$rel_path")
  skill_name=$(basename "$rel_path")

  target_dir="${HERMES_SKILLS}/${rel_path}"

  if [ -L "$target_dir" ]; then
    # Already a symlink — check if it points to the right place
    current_target=$(readlink "$target_dir")
    if [ "$current_target" = "$skill_dir" ]; then
      echo -e "  ${GREEN}✔${NC} ${rel_path} already linked correctly"
      continue
    else
      echo -e "  ${YELLOW}⟳${NC} ${rel_path} relinking (was → ${current_target})"
      rm "$target_dir"
      ln -s "$skill_dir" "$target_dir"
    fi
  elif [ -d "$target_dir" ] && [ ! -L "$target_dir" ]; then
    # Real directory exists — could be leftover from skill_manage create
    echo -e "  ${YELLOW}⚠${NC} ${rel_path} is a real directory, not symlink. Backing up."
    mv "$target_dir" "${target_dir}.bak.$(date +%s)"
    ln -s "$skill_dir" "$target_dir"
    echo -e "  ${GREEN}✔${NC} ${rel_path} backed up and symlinked"
  else
    # Doesn't exist — create parent and symlink
    mkdir -p "$(dirname "$target_dir")"
    ln -s "$skill_dir" "$target_dir"
    echo -e "  ${GREEN}✔${NC} ${rel_path} linked"
  fi
done

echo ""

# ── Step 4: Verify ──
echo -e "${YELLOW}[4/5]${NC} Verifying installation..."

VERIFY_FAIL=0
find "${SKILLS_DIR}" -mindepth 2 -maxdepth 2 -type d | while read -r skill_dir; do
  rel_path="${skill_dir#${SKILLS_DIR}/}"
  target_dir="${HERMES_SKILLS}/${rel_path}"
  skill_file="${target_dir}/SKILL.md"

  if [ ! -L "$target_dir" ]; then
    echo -e "  ${RED}✘${NC} ${rel_path} — not a symlink"
    VERIFY_FAIL=1
  elif [ ! -f "$skill_file" ]; then
    echo -e "  ${RED}✘${NC} ${rel_path} — SKILL.md not found"
    VERIFY_FAIL=1
  else
    echo -e "  ${GREEN}✔${NC} ${rel_path} — OK"
  fi
done

if [ "$VERIFY_FAIL" -eq 1 ]; then
  echo ""
  echo -e "${RED}Some skills failed verification. Check the errors above.${NC}"
fi

echo ""

# ── Step 5: Done ──
echo -e "${YELLOW}[5/5]${NC} Summary"
echo ""
echo "  Repo:       ${SKILLS_DIR}"
echo "  Symlinked:  ${HERMES_SKILLS}/<category>/<skill>/ → ${SKILLS_DIR}/<category>/<skill>/"
echo "  Remote:     ${REPO_URL}"
echo ""

echo -e "${GREEN}═══ Installation complete ═══${NC}"
echo ""
echo "Skills are now available to Hermes. Start a new session to load them:"
echo ""
echo "  hermes --continue"
echo ""
echo "Or load a specific skill in-session:"
echo ""
echo "  /skill project-bootstrapper"
echo ""
