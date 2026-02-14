# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a personal dotfiles repository for Windows 11 Pro development environments. It uses **symbolic links** to manage configuration files - configs live in this repo and are symlinked to their system locations, enabling version control while maintaining automatic bidirectional sync.

## Core Architecture

### Installation System
- **Main script**: `scripts/install.ps1` - Creates symlinks from system paths to repo files
- **Symlink mappings**: Defined in `$SymlinkMappings` hashtable (lines 44-130 of install.ps1)
- **Selective installation**: Use `-Only` parameter to install specific configs (vscode, cursor, claude, powershell, git-bash, git, npm, windows-terminal, winget, wsl)
- **Auto-skipping**: git-bash and wsl configs are automatically skipped if directories/files don't exist

### Secrets Management
- **Location**: `secrets/` directory (git-ignored)
- **Format**: Service-based `.env.*` files (e.g., `.env.cloudflare`, `.env.github`)
- **Loading**: Automatically sourced by both PowerShell (`powershell/profile.ps1`) and Git Bash (`git-bash/.bashrc`) on shell startup
- **Sync to Windows env**: Use `scripts/sync-secrets.ps1` to write allowlisted secrets to Windows user environment variables (required for GUI apps like Cursor and MCP servers)
- **Allowlist**: Edit `$AllowList` array in `sync-secrets.ps1` to control which secrets sync to Windows env
- **MCP tokens**: `GITHUB_MCP_TOKEN` and other MCP-specific tokens must be synced to Windows env for Cursor's MCP servers to access them

### Primary Shell Configuration
- **Cursor's default terminal**: Git Bash (configured in `cursor/settings.json`)
- **Git Bash profile**: `git-bash/.bashrc` - Used by Cursor's integrated terminal
- **PowerShell profile**: `powershell/profile.ps1` - Used when running PowerShell elsewhere (Windows Terminal, standalone)
- Both profiles load secrets and define identical git shortcuts (gst, gco, gaa, gcm, gp, gl)

### MCP Server Configuration
- **File**: `cursor/mcp.json` (symlinked to `%USERPROFILE%\.cursor\mcp.json`)
- **Current servers**: openai-docs (HTTP), fetch (stdio/npx), filesystem (stdio/npx), Cloudflare (HTTP), github (HTTP)
- **Environment variables**: MCP config uses `${VAR_NAME}` syntax for secrets (e.g., `${GITHUB_MCP_TOKEN}`)
- **Setup**: Run `.\scripts\sync-secrets.ps1` to sync tokens to Windows user environment, then restart Cursor

### Claude Code Configuration
- **File**: `claude/settings.json` (symlinked to `%USERPROFILE%\.claude\settings.json`)
- **Purpose**: Global user settings (model, plugins, permissions)
- **Permissions**: Generous allow rules for autonomous hobby dev; destructive commands and secrets access denied
- **Note**: `claude/` (tracked config) is distinct from `.claude/` (git-ignored project-local state)

## Key Commands

### Installation
```powershell
# Full install (all configs)
.\scripts\install.ps1

# Selective install
.\scripts\install.ps1 -Only cursor,git

# Force mode (no prompts)
.\scripts\install.ps1 -Force
```

### Secrets Management
```powershell
# Preview what secrets will be synced to Windows env
.\scripts\sync-secrets.ps1 -WhatIf

# Sync secrets to Windows user environment (requires app restart to take effect)
.\scripts\sync-secrets.ps1

# View loaded secrets in PowerShell
Get-ChildItem Env: | Where-Object { $_.Name -like "*CLOUDFLARE*" -or $_.Name -like "*GITHUB*" }
```

### Verification
```powershell
# Check if files are symlinks
(Get-Item $env:USERPROFILE\.gitconfig).LinkType -eq 'SymbolicLink'
(Get-Item $env:APPDATA\Cursor\User\settings.json).LinkType -eq 'SymbolicLink'

# View symlink targets
Get-Item $env:USERPROFILE\.gitconfig | Select-Object LinkType, Target
```

## Important Constraints

1. **Symlinks, not copies**: Always maintain symlink architecture. Files should live in repo, not be duplicated to system paths.

2. **Windows paths**: Use PowerShell environment variables (`$env:APPDATA`, `$env:USERPROFILE`, `$env:LOCALAPPDATA`) and double backslashes in JSON files.

3. **Adding new configs**: When adding new configuration files:
   - Place config file in appropriate directory (e.g., `cursor/`, `git/`)
   - Update `$SymlinkMappings` in `scripts/install.ps1`
   - Update README.md (Structure section, What Gets Configured, Key Paths Reference)
   - If config contains secrets, document in secrets section

4. **Secrets security**:
   - Never commit `.env.*` files (except `.example` templates)
   - Verify `.gitignore` excludes `secrets/*` with exception for `!secrets/.env.*.example`
   - Keep tokens in `secrets/.env.*` files, not hardcoded in configs

5. **Optional configs**: git-bash and wsl configs are optional and auto-skipped if missing. Other configs (vscode, cursor, claude, powershell, git, npm, windows-terminal, winget) are expected to exist.

## Configuration Locations

| Component | Repo Path | System Symlink Target |
|-----------|-----------|----------------------|
| Cursor settings | `cursor/settings.json` | `%APPDATA%\Cursor\User\settings.json` |
| Cursor keybindings | `cursor/keybindings.json` | `%APPDATA%\Cursor\User\keybindings.json` |
| Cursor MCP | `cursor/mcp.json` | `%USERPROFILE%\.cursor\mcp.json` |
| Cursor CLI config | `cursor/cli-config.json` | `%USERPROFILE%\.cursor\cli-config.json` |
| Claude Code settings | `claude/settings.json` | `%USERPROFILE%\.claude\settings.json` |
| VS Code settings | `vscode/settings.json` | `%APPDATA%\Code\User\settings.json` |
| VS Code keybindings | `vscode/keybindings.json` | `%APPDATA%\Code\User\keybindings.json` |
| VS Code snippets | `vscode/snippets` | `%APPDATA%\Code\User\snippets` |
| PowerShell profile | `powershell/profile.ps1` | `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| Git Bash rc | `git-bash/.bashrc` | `%USERPROFILE%\.bashrc` |
| Git config | `git/.gitconfig` | `%USERPROFILE%\.gitconfig` |
| npm config | `npm/.npmrc` | `%USERPROFILE%\.npmrc` |
| Windows Terminal | `windows-terminal/settings.json` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| WinGet settings | `winget/settings.json` | `%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json` |

## Theming

All applications use [Dracula Theme](https://draculatheme.com) where available. Maintain this consistency when adding new application configs.
