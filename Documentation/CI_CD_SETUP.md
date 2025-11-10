# CI/CD Setup Guide

This template includes a complete CI/CD pipeline using GitHub Actions for automated testing, formatting, and releases.

## What's Included

### Configuration Files

- **`.swiftlint.yml`**: SwiftLint rules configured for the template structure
- **`.swift-format`**: Swift format configuration (120 char line length, 4-space indentation)
- **`scripts/lint.sh`**: Run SwiftLint locally
- **`scripts/format.sh`**: Auto-format code locally
- **`scripts/setup-git-hooks.sh`**: Install pre-commit hooks

### GitHub Actions Workflows

1. **CI Workflow** (`.github/workflows/ci.yml`)
   - Runs on push/PR to main/develop
   - SwiftLint check
   - Swift format check
   - Build and test for iOS and macOS

2. **Format Workflow** (`.github/workflows/format.yml`)
   - Auto-formats code on develop branch
   - Can be triggered manually
   - Commits formatted code automatically

3. **Release Workflow** (`.github/workflows/release.yml`)
   - Triggered on version tags (e.g., `v1.0.0`)
   - Runs full validation
   - Creates GitHub releases

## Quick Start

### 1. Local Setup

```bash
# Install dependencies (macOS)
brew install swiftlint swift-format

# Set up git hooks (optional but recommended)
ci-cd/scripts/setup-git-hooks.sh

# Run linter
ci-cd/scripts/lint.sh

# Format code
ci-cd/scripts/format.sh
```

### 2. Configure for Your Project

Update `.github/workflows/ci.yml` and `.github/workflows/release.yml`:

```yaml
scheme: ['YourAppScheme']  # Replace with your Xcode scheme name
```

### 3. Enable GitHub Actions

1. Push to GitHub
2. Go to repository Settings → Actions → General
3. Enable "Allow all actions and reusable workflows"
4. Workflows will run automatically on push/PR

## Workflows Explained

### CI Workflow

**When it runs:**
- Every push to `main` or `develop`
- Every pull request targeting `main` or `develop`

**What it does:**
1. **Lint Job**: Runs SwiftLint to check code style
2. **Format Job**: Verifies code formatting compliance
3. **Build Job**: Builds and tests on iOS Simulator and macOS

**Matrix strategy:** Tests across multiple destinations to ensure compatibility.

### Format Workflow

**When it runs:**
- Automatically on push to `develop`
- Manually via "Actions" tab → "Format Code" → "Run workflow"

**What it does:**
1. Runs `swift-format` on all Swift files
2. Commits changes if formatting was needed
3. Uses `[skip ci]` in commit message to avoid triggering CI

**Why auto-format develop?** Keeps the development branch clean while allowing flexibility in feature branches.

### Release Workflow

**When it runs:**
- When you push a tag starting with `v` (e.g., `v1.0.0`)

**What it does:**
1. Validates code with linter and formatter
2. Archives builds for iOS and macOS
3. Creates GitHub release with artifacts

**Creating a release:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Configuration Details

### SwiftLint Rules

The template uses relaxed rules suitable for SwiftUI:

```yaml
function_body_length:
  warning: 275  # SwiftUI views can be longer
  error: 350

file_length:
  warning: 800
  error: 2000

cyclomatic_complexity:
  warning: 15
  error: 25
```

**Disabled rules:**
- `trailing_whitespace`
- `line_length`
- `force_unwrapping` (use judiciously)
- `multiple_closures_with_trailing_closure` (common in SwiftUI)

**Enabled opt-in rules:**
- `explicit_init`
- `empty_count`
- `unneeded_parentheses_in_closure_argument`
- `file_name_no_space`

### Swift Format Configuration

```json
{
  "lineLength": 120,
  "indentation": { "spaces": 4 },
  "multiElementCollectionTrailingCommas": true,
  "lineBreakBeforeEachArgument": true
}
```

## Customization

### Adjusting Lint Rules

Edit `.swiftlint.yml` to modify rules:

```yaml
# Disable a rule
disabled_rules:
  - identifier_name

# Adjust thresholds
type_body_length:
  warning: 300
  error: 400

# Add custom rules
custom_rules:
  my_rule:
    name: "My Custom Rule"
    regex: "badPattern"
    message: "Don't use badPattern"
```

### Adding More CI Jobs

Edit `.github/workflows/ci.yml`:

```yaml
jobs:
  security-audit:
    name: Security Audit
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Run Security Checks
        run: |
          # Add your security scanning tools
```

### Custom Format Rules

Edit `.swift-format`:

```json
{
  "lineLength": 100,  // Shorter lines
  "indentation": { "spaces": 2 },  // 2-space indent
  "respectsExistingLineBreaks": false  // More aggressive formatting
}
```

## Local Development Workflow

### Pre-commit Hook (Recommended)

```bash
./scripts/setup-git-hooks.sh
```

This installs a git hook that:
- Runs SwiftLint on changed files
- Prevents commits with lint errors
- Runs fast (only checks changed files)

### Manual Checks

```bash
# Before committing
ci-cd/scripts/lint.sh

# Format code
ci-cd/scripts/format.sh

# Check formatting without changing files
swift-format lint --recursive ios-template/ --strict
```

### Integration with Xcode

**Add build phase for linting:**

1. Open Xcode project
2. Select target → Build Phases
3. Add "Run Script Phase"
4. Script:
   ```bash
   if which swiftlint >/dev/null; then
     swiftlint
   fi
   ```

**Add build phase for formatting:**

1. Add another "Run Script Phase"
2. Script:
   ```bash
   if which swift-format >/dev/null; then
     swift-format lint --recursive Sources/ --strict
   fi
   ```

## Troubleshooting

### "swiftlint: command not found"

```bash
brew install swiftlint
```

### "swift-format: command not found"

```bash
brew install swift-format
```

### CI Fails on Format Check

Run locally and commit:
```bash
ci-cd/scripts/format.sh
git add .
git commit -m "style: format code"
```

### CI Fails on Xcode Version

Update `.github/workflows/ci.yml`:
```yaml
- name: Select Xcode
  run: sudo xcode-select -s /Applications/Xcode_16.0.app
```

### Want Different Rules for Tests

Add to `.swiftlint.yml`:
```yaml
excluded:
  - Tests  # Exclude test files
```

Or create `.swiftlint.yml` in Tests directory with custom rules.

## Best Practices

### 1. Branch Strategy

- `main`: Production-ready code, protected
- `develop`: Latest development, auto-formatted
- `feature/*`: Feature branches, manual formatting before PR

### 2. Pull Request Workflow

1. Create feature branch from `develop`
2. Make changes
3. Run `ci-cd/scripts/format.sh` before committing
4. Push and create PR to `develop`
5. CI runs automatically
6. Fix any lint/format issues
7. Merge after approval

### 3. Release Process

1. Merge `develop` into `main`
2. Tag with version: `git tag v1.0.0`
3. Push tag: `git push origin v1.0.0`
4. Release workflow creates GitHub release
5. Download artifacts from release page

### 4. Keep CI Fast

- Use caching for dependencies
- Run only necessary jobs
- Use matrix builds strategically
- Skip CI when needed: `[skip ci]` in commit message

## Advanced Configuration

### Add Code Coverage

Edit `.github/workflows/ci.yml`:

```yaml
- name: Run Tests with Coverage
  run: |
    xcodebuild test \
      -scheme ${{ matrix.scheme }} \
      -destination "${{ matrix.destination }}" \
      -enableCodeCoverage YES \
      -resultBundlePath ./TestResults.xcresult

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./TestResults.xcresult
```

### Add Danger for PR Reviews

Create `Dangerfile`:

```ruby
# Ensure PR has description
fail "Please provide a summary" if github.pr_body.length < 5

# Warn on large PRs
warn "Big PR" if git.lines_of_code > 500

# Check for changelog
has_changelog = git.modified_files.include?("CHANGELOG.md")
warn("Please update CHANGELOG.md") unless has_changelog
```

Add to `.github/workflows/ci.yml`:

```yaml
- name: Run Danger
  run: bundle exec danger
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Performance Testing

```yaml
performance-test:
  name: Performance Tests
  runs-on: macos-14
  steps:
    - uses: actions/checkout@v4
    - name: Run Performance Tests
      run: |
        xcodebuild test \
          -scheme YourAppScheme \
          -testPlan PerformanceTests \
          -destination "platform=iOS Simulator,name=iPhone 15 Pro"
```

## Migration from Existing Project

If you're adding this to an existing project:

1. **Copy configuration files:**
   ```bash
   cp template-repo/.swiftlint.yml your-project/
   cp template-repo/.swift-format your-project/
   cp -r template-repo/scripts your-project/
   cp -r template-repo/.github your-project/
   ```

2. **Update SwiftLint paths:**
   Edit `.swiftlint.yml` to match your project structure

3. **Fix existing issues:**
   ```bash
   ci-cd/scripts/format.sh  # Auto-fix formatting
   ci-cd/scripts/lint.sh    # See remaining issues
   ```

4. **Update workflows:**
   Replace `YourAppScheme` with your actual scheme name

5. **Test locally first:**
   ```bash
   brew install swiftlint swift-format
   ci-cd/scripts/lint.sh
   ci-cd/scripts/format.sh
   ```

6. **Commit and push:**
   ```bash
   git add .
   git commit -m "ci: add CI/CD pipeline"
   git push
   ```

## Resources

- [SwiftLint Documentation](https://github.com/realm/SwiftLint)
- [swift-format Guide](https://github.com/apple/swift-format)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-swift)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
