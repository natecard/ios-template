#!/bin/zsh
# Ensure we are running under zsh even if invoked via 'sh script' (which ignores shebang)
if [ -z "${ZSH_VERSION:-}" ]; then
  exec /bin/zsh "$0" "$@"
fi
# Safety: exit immediately on errors, unset vars, and pipeline failures.
set -euo pipefail

# Find the git repository root directory
# '2>/dev/null' redirects errors to nowhere (silent failure)
# '|| pwd' means: if git command fails, use current directory instead
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

echo "[format] Verifying required tools..."
# 'comma,nd -v' checks if a command exists (like 'which' but more portable)
# '>/dev/null 2>&1' hides all output (both stdout and stderr)
# '|| { ... }' executes if the command fails (tool not found)
# '>&2' redirects echo to stderr (standard for error messages)
command -v swift-format >/dev/null 2>&1 || {
  echo "swift-format is required. Install via: brew install swift-format" >&2
  exit 1
}
command -v swiftlint >/dev/null 2>&1 || {
  echo "SwiftLint is required. Install via: brew install swiftlint" >&2
  exit 1
}

# Default scope formats the entire repo. Pass --staged to only format staged Swift files.
SCOPE="all"
# "${1:-}" means: use argument $1 if provided, otherwise empty string (prevents unset variable error)
if [[ ${1:-} == "--staged" ]]; then
  SCOPE="staged"
fi

# TODO: Update TARGET_DIR to match your source directory (currently: ios-template)
# This is where Swift sources primarily live (used by SwiftLint scanning)
# '${VAR:-default}' syntax: use environment variable VAR if set, otherwise use 'default'
TARGET_DIR=${TARGET_DIR:-ios-template}

if [[ $SCOPE == "staged" ]]; then
  echo "[format] Formatting staged Swift files..."
  # Create an empty array to hold Swift file paths
  swift_files=()
  # Read git staged files one at a time (null-delimited for safety with spaces in filenames)
  # 'IFS=' prevents word splitting, '-d ''' sets delimiter to null byte
  # The process substitution <(...) feeds git output to the while loop
  while IFS= read -r -d '' f; do
    # [[ ]] is zsh/bash conditional syntax (more powerful than [ ])
    # '==' does pattern matching; '*.swift' matches any file ending in .swift
    # '+=' appends to the array
    [[ $f == *.swift ]] && swift_files+=("$f")
  done < <(git diff --cached --name-only --diff-filter=ACMR -z)
  # --cached = staged files, --diff-filter=ACMR = Added/Copied/Modified/Renamed (exclude Deleted)
  # -z = null-delimited output (safe for filenames with spaces/special chars)

  # (( )) is arithmetic context; ${#array[@]} gets array length
  if ((${#swift_files[@]} == 0)); then
    echo "[format] No staged Swift files to format."
    exit 0
  fi

  # TODO: Update path to .swift-format config if you moved it
  # '--' separates options from file arguments (prevents filenames starting with '-' from being treated as options)
  # '"${array[@]}"' expands array elements as separate quoted arguments (preserves spaces in filenames)
  swift-format format --in-place --configuration .swift-format -- "${swift_files[@]}"

  # Run SwiftLint fix on each file individually
  # '|| true' means: if swiftlint fails, don't exit the script (continue anyway)
  for f in "${swift_files[@]}"; do
    swiftlint --fix --config .swiftlint.yml --quiet "$f" || true
  done
  echo "[format] Staged Swift files formatted."
else
  echo "[format] Formatting entire repository (swift-format recursive + SwiftLint fix)..."
  # TODO: Update path to .swift-format config if you moved it
  # Recursively format all Swift files in the repository
  swift-format format --in-place --configuration .swift-format --recursive .

  # Run SwiftLint fix across the project sources
  # --fix applies auto-fixable violations, --quiet suppresses non-error output
  swiftlint --fix --config .swiftlint.yml --quiet "$TARGET_DIR" || true
  echo "[format] Completed full-repo formatting."
fi

exit 0
