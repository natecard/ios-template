#!/bin/zsh
# Safety settings: exit on error, treat unset variables as errors, fail on pipe errors
set -euo pipefail

# Find git repository root (where .git folder lives)
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

# TODO: Update TARGET_DIR to match your source directory (currently: ios-template)
# ${1:-default} means: use first script argument if provided, otherwise use 'ios-template'
# Example usage: ./lint.sh MyCustomDirectory
TARGET_DIR=${1:-ios-template}

echo "[lint] Using .swift-format and .swiftlint.yml in $repo_root"

echo "[lint] Formatting entire repository with swift-format (recursive)"
swift-format format --in-place --configuration .swift-format --recursive .

echo "[lint] SwiftLint: full repo (strict) using github-actions-logging reporter"
swiftlint lint --strict --config .swiftlint.yml --reporter github-actions-logging "$TARGET_DIR"

echo "[lint] Completed successfully (CI mode)."
# If we reach here, all linting passed (thanks to --strict and 'set -e')
