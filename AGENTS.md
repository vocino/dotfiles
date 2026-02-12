# AGENTS.md

## Purpose
- This repository manages personal Windows 11 Pro dotfiles via symlinks.
- Treat this as infrastructure/configuration code, not an app/service codebase.
- Changes should be safe, reversible, and compatible with local-first workflows.

## Operating Philosophy

### Core Direction
- Local-first, privacy-focused, encryption-mandatory, Windows-native development.
- Prefer native Windows tools and workflows over Linux/WSL alternatives.
- Keep setup reproducible from a fresh Windows install.

### Security and Privacy Posture
- BitLocker is mandatory on system and project drives (keys stored externally, e.g. 1Password).
- Minimize telemetry and cloud sync surface area.
- Prefer local configuration control over vendor defaults.
- Never commit credentials, tokens, private keys, or machine-local secrets.

### Tooling Preferences
- PowerShell 7 is the primary shell.
- Cursor is primary editor; VS Code remains a fallback.
- WinGet is preferred package manager for system apps.
- Keep Dracula theme consistency where practical.

## Current Repository Shape
- Installer: `scripts/install.ps1`.
- Secrets sync: `scripts/sync-secrets.ps1`.
- Env smoke test: `scripts/test-env.ps1`.
- Config directories: `cursor/`, `powershell/`, `git-bash/`, `git/`, `npm/`, `windows-terminal/`.
- Optional directories: `git-bash/`, `wsl/` (installer skips when missing).

## Non-Negotiable Rules
- Preserve symlink architecture; do not replace with copy-based workflows.
- Keep Windows compatibility first.
- Never commit secrets/tokens.
- Keep docs aligned with behavior (`README.md` and installer mappings).
- Do not add WSL-dependent behavior unless explicitly requested.

## Build / Lint / Test Commands
- There is no traditional build pipeline.
- Use install + validation commands as build/test equivalents.

### Core Commands
```powershell
# Install all mappings
.\scripts\install.ps1

# Install selected mappings only
.\scripts\install.ps1 -Only cursor,git

# Install without prompts
.\scripts\install.ps1 -Force
```

### Lint / Static Checks
```powershell
# Lint scripts if PSScriptAnalyzer is available
pwsh -NoProfile -Command "Invoke-ScriptAnalyzer -Path .\scripts,.\powershell -Recurse"

# Optional: install analyzer
pwsh -NoProfile -Command "Install-Module PSScriptAnalyzer -Scope CurrentUser"
```

### Test / Verification
```powershell
# Environment-variable smoke test
pwsh -NoProfile -File .\scripts\test-env.ps1

# Dry-run secret sync
.\scripts\sync-secrets.ps1 -WhatIf

# Apply secret sync
.\scripts\sync-secrets.ps1
```

### Running a Single Test
- No committed Pester test files currently exist (`*.Tests.ps1`).
- Single-test equivalent today:
```powershell
pwsh -NoProfile -File .\scripts\test-env.ps1
```
- If Pester tests are added later:
```powershell
pwsh -NoProfile -Command "Invoke-Pester -Path .\tests\install.Tests.ps1"
pwsh -NoProfile -Command "Invoke-Pester -Path .\tests\install.Tests.ps1 -FullNameFilter '*New-Symlink*'"
```

### Symlink Verification
```powershell
# Verify symlink status
(Get-Item $env:USERPROFILE\.gitconfig).LinkType -eq 'SymbolicLink'
(Get-Item $env:APPDATA\Cursor\User\settings.json).LinkType -eq 'SymbolicLink'

# Inspect target
Get-Item $env:USERPROFILE\.gitconfig | Select-Object LinkType, Target
```

## Code Style Guidelines

### General
- Keep diffs small, targeted, and reversible.
- Prefer clarity over cleverness.
- Preserve each file's existing formatting style.
- Avoid broad reformatting unrelated to the change.
- Use descriptive names; avoid single-letter names except trivial loop counters.

### PowerShell (`scripts/*.ps1`, `powershell/profile.ps1`)
- Use `[CmdletBinding()]` when advanced script behavior is needed.
- Use explicit typed `param(...)` blocks (`[string]`, `[string[]]`, `[switch]`).
- Prefer Verb-Noun function names (e.g., `Import-Dotenv`).
- Prefer `Join-Path` for path composition.
- Validate paths with `Test-Path` before write/delete operations.
- Use `$ErrorActionPreference = "Stop"` where failures should halt execution.
- Wrap risky operations in `try/catch` and emit actionable errors.
- Return simple status values (`$true/$false`) from helpers when useful.
- Keep comments for non-obvious behavior only.

### Bash (`git-bash/.bashrc`, `.bash_profile`)
- Quote variable expansions and paths (`"$var"`).
- Guard interactive-only setup (`[[ $- != *i* ]] && return`).
- Use `command -v` checks before command-dependent functions/aliases.
- Keep Bash and PowerShell helper semantics aligned when practical.

### JSON (`cursor/*.json`, `windows-terminal/settings.json`)
- Preserve existing indentation/key-order style.
- Use escaped Windows paths (`C:\\...`) where required.
- Keep comments only in JSONC-capable files.
- Avoid unrelated key reordering/reformatting.

### Markdown / Docs
- Keep instructions task-oriented and copy-pasteable.
- Update `README.md` when setup behavior, mappings, or paths change.
- Keep examples current with repository reality.

### Imports / Dependencies
- No conventional import graph exists in this repository.
- Avoid introducing new required PowerShell module dependencies unless justified.
- If adding dependencies, document installation/usage in `README.md`.

### Types and Naming
- Prefer explicit parameter typing in PowerShell.
- Validate required inputs early and fail fast.
- Use uppercase snake case for environment variable names (`GITHUB_MCP_TOKEN`).
- Keep abbreviations minimal and use established names (`RepoRoot`, `SecretsDir`).

### Error Handling and Logging
- Fail loudly for unrecoverable setup issues.
- Use `Write-Warning` for non-fatal skips/fallbacks.
- Use `Write-Host` for concise progress updates.
- Include path/operation/fix context in error text.

## Security and Secrets
- Never hardcode credentials in tracked files.
- Keep real secrets in `secrets/.env.*` (git-ignored).
- Track only `.example` templates for secret files.
- Use `scripts/sync-secrets.ps1` allowlist for GUI-exposed environment variables.
- Restart GUI apps (Cursor, etc.) after syncing env vars.

## Cursor / Copilot Rules
- Cursor rules file exists: `.cursorrules`.
- No `.cursor/rules/` directory found.
- No `.github/copilot-instructions.md` file found.

### Effective Guidance from `.cursorrules`
- Maintain Windows 11 Pro compatibility.
- Use symlinks, not copies.
- Keep config files organized and maintainable.
- Preserve existing behavior unless intentionally changing it.
- When adding configs, update installer mappings and README docs.
- Validate installer/symlink behavior after changes.

## Change Checklist for Agents
- If adding/changing config files:
  - Update `scripts/install.ps1` symlink mappings.
  - Update `README.md` structure/config/path docs.
  - Verify symlink creation and target correctness.
- If changing secrets flow:
  - Preserve `.gitignore` protections.
  - Update allowlist/docs as needed.
- If changing shell behavior:
  - Keep PowerShell and Git Bash workflows reasonably aligned.

## Agent Execution Defaults
- Read first, then edit.
- Avoid destructive git commands.
- Never commit secrets or machine-local artifacts.
- Keep formatting churn low and focused on touched sections.
- Provide verification steps with every non-trivial change.
