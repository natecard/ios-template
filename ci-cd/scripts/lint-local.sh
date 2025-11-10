#!/bin/zsh
# Safety settings: exit on error, treat unset variables as errors, fail on pipe errors
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

# Source directory (override with first arg). Default aligns with project.
# ${1:-default} means: use first script argument if provided, otherwise use 'ios-template'
# Example usage: ./lint-local.sh ios-template
TARGET_DIR=${1:-ios-template}

echo "[lint-local] Using .swift-format and .swiftlint.yml in $repo_root"

echo "[lint-local] swift-format: format changed files vs HEAD (fallback recursive)"
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  changed=$(git diff --name-only --diff-filter=ACM HEAD | grep '\.swift$' || true)
else
  changed=$(git ls-files '*.swift' || true)
fi
if [ -n "$changed" ]; then
  swift-format format --in-place --configuration .swift-format -- $changed
else
  swift-format format --in-place --configuration .swift-format --recursive .
fi

echo "[lint-local] SwiftLint: lint (strict) at $TARGET_DIR with Xcode reporter"
swiftlint lint --strict --config .swiftlint.yml --reporter xcode "$TARGET_DIR"

echo "[lint-local] Completed successfully."
