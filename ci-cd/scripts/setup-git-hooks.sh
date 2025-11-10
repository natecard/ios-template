#!/bin/zsh
# Configure local git hooks & install pre-commit automation.
# Idempotent: safe to re-run any time.
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

HOOKS_DIR=".githooks"
SRC_PRECOMMIT="ci-cd/pre-commit"
DEST_PRECOMMIT="$HOOKS_DIR/pre-commit"

echo "[setup-git-hooks] Repo root: $repo_root"

# Ensure hook source exists
if [ ! -f "$SRC_PRECOMMIT" ]; then
	echo "[setup-git-hooks] ERROR: Expected pre-commit script at $SRC_PRECOMMIT not found." >&2
	exit 1
fi

echo "[setup-git-hooks] Creating hooks directory ($HOOKS_DIR)..."
mkdir -p "$HOOKS_DIR"

# Decide copy vs symlink (default: symlink for easy updates). Allow override MODE=copy.
MODE=${MODE:-symlink}
relink=false
if [ "$MODE" = "copy" ]; then
	if [ ! -f "$DEST_PRECOMMIT" ] || ! diff -q "$SRC_PRECOMMIT" "$DEST_PRECOMMIT" >/dev/null 2>&1; then
		echo "[setup-git-hooks] Copying pre-commit hook (mode=copy)..."
		cp "$SRC_PRECOMMIT" "$DEST_PRECOMMIT"
		relink=true
	fi
else
	# symlink path relative for readability
	link_target="../$SRC_PRECOMMIT"
	# If existing is wrong type or points elsewhere, replace it
	if [ ! -L "$DEST_PRECOMMIT" ] || [ "$(readlink "$DEST_PRECOMMIT" 2>/dev/null || true)" != "$link_target" ]; then
		echo "[setup-git-hooks] Symlinking pre-commit -> $link_target"
		rm -f "$DEST_PRECOMMIT" 2>/dev/null || true
		ln -s "$link_target" "$DEST_PRECOMMIT"
		relink=true
	fi
fi

# Make all relevant scripts executable
chmod +x "$SRC_PRECOMMIT"
chmod +x "$DEST_PRECOMMIT" 2>/dev/null || true
chmod +x ci-cd/scripts/format.sh || true
chmod +x ci-cd/scripts/lint.sh || true
chmod +x ci-cd/scripts/lint-local.sh || true
chmod +x ci-cd/scripts/setup-git-hooks.sh || true

# Configure git to use custom hooks directory
current_hooks_path="$(git config --get core.hooksPath || echo '')"
if [ "$current_hooks_path" != "$HOOKS_DIR" ]; then
	git config core.hooksPath "$HOOKS_DIR"
	echo "[setup-git-hooks] Set core.hooksPath to $HOOKS_DIR"
else
	echo "[setup-git-hooks] core.hooksPath already set to $HOOKS_DIR"
fi

# Quick verification message
echo "[setup-git-hooks] Installed pre-commit hook ($MODE)."
[ "$relink" = true ] && echo "[setup-git-hooks] Hook link/copied fresh." || echo "[setup-git-hooks] Hook already up-to-date."

cat <<'EON'
[setup-git-hooks] Done.
Usage:
	- Commit normally: git commit -m "..." (hook auto-runs swift-format + SwiftLint on staged Swift files)
	- Bypass hook   : git commit --no-verify
	- Force full fmt: PRECOMMIT_FORMAT_SCOPE=all git commit -m "..."
	- Override Xcode: HOOK_DEVELOPER_DIR=/Applications/Xcode-beta.app git commit -m "..."

Optional local scripts:
	- ci-cd/scripts/lint-local.sh  (incremental formatting + Xcode-style lint)
	- ci-cd/scripts/lint.sh        (CI full repository strict lint)

Re-run this setup after pulling updates to keep hooks in sync.
EON
