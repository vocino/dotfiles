# Dotfiles

Personal development environment configuration for Windows 11 Pro.

This repository uses symlinks to keep configuration files in version control while maintaining their expected locations in your system. Changes made to configs in this repo automatically reflect in your system, and vice versa.

## Prerequisites

Before installing, ensure your PowerShell execution policy allows scripts:

```powershell
# Check current policy
Get-ExecutionPolicy

# If needed, allow local scripts to run (requires Administrator)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Note**: The installer may require Administrator privileges for certain paths (like Windows Terminal settings). You'll be prompted if elevation is needed.

## Structure

```
dotfiles/
├── cursor/              # Cursor IDE configuration
│   ├── mcp.json         # MCP server definitions
│   ├── settings.json    # Cursor settings
│   ├── keybindings.json # Custom keyboard shortcuts
│   ├── cli-config.json  # Cursor CLI configuration (agent modes, permissions)
│   ├── snippets/        # Custom code snippets (if used)
│   └── rules/           # Global cursor rules
├── powershell/          # PowerShell profile and modules
│   └── profile.ps1
├── git/                 # Git configuration
│   ├── .gitconfig
│   └── .gitignore_global
├── npm/                 # npm configuration
│   └── .npmrc           # Global npm config (registry, auth, proxy)
├── windows-terminal/    # Windows Terminal settings
│   └── settings.json
├── wsl/                 # WSL-specific configs (if used)
│   └── .bashrc
├── scripts/             # Installation and utility scripts
│   └── install.ps1      # Main bootstrap script
└── .cursorrules         # Rules for editing THIS repo
```

## Quick Start

```powershell
# Clone the repo
git clone https://github.com/vocino/dotfiles.git ~/dotfiles

# Run the installer
cd ~/dotfiles
.\scripts\install.ps1
```

The installer will:
1. Create symbolic links from system paths to files in this repo
2. Ask for confirmation before overwriting existing files (unless using `-Force`)

## What Gets Configured

- **Cursor IDE**: Settings, MCP servers, keybindings, CLI config, snippets, global rules
- **PowerShell**: Custom profile with aliases and functions
- **Git**: Global config, aliases, ignore patterns
- **npm**: Global npm configuration (registry, auth, proxy settings)

## Theming

All applications are configured to use the [Dracula Theme](https://github.com/dracula/dracula-theme) where available. Dracula is a dark theme available for 400+ applications, providing a consistent, accessible color scheme across the entire development environment.

Installation instructions for Dracula themes can be found at [draculatheme.com](https://draculatheme.com). Each application's theme repository includes specific installation steps.

## Installation Options

```powershell
# Full install (all configs)
.\scripts\install.ps1

# Selective install (only specific configs)
.\scripts\install.ps1 -Only cursor,git

# Force mode (overwrites existing files without prompting)
.\scripts\install.ps1 -Force
```

**Selective Install**: Use `-Only` to install specific configs. Available options: `cursor`, `powershell`, `git`, `npm`, `windows-terminal`, `wsl`.

## Updating

After making changes to config files in this repo:

```powershell
# Symlinks automatically reflect changes - no reinstall needed!
# The repo files are already linked, so edits appear immediately

# However, if you need to re-link (e.g., after structure changes):
.\scripts\install.ps1 -Force
```

Since configs are symlinked, edits in either location (repo or system) are immediately reflected in both. No reinstall needed for content changes.

## Adding New Configs

1. Add the config file to the appropriate directory
2. Update `scripts/install.ps1` with the symlink mapping
3. Document in this README

## Verification

After installation, verify symlinks were created correctly:

```powershell
# Check if files are symlinks (returns True if symlink, False if regular file)
(Get-Item $env:USERPROFILE\.gitconfig).LinkType -eq 'SymbolicLink'
(Get-Item $env:APPDATA\Cursor\User\settings.json).LinkType -eq 'SymbolicLink'

# View symlink targets
Get-Item $env:USERPROFILE\.gitconfig | Select-Object LinkType, Target
```

**Quick Checklist**:
- [ ] Symlinks created (check with commands above)
- [ ] Cursor IDE settings load correctly
- [ ] PowerShell profile loads on new session (`pwsh`)
- [ ] Git config is active (`git config --list --show-origin`)
- [ ] Windows Terminal uses new settings (if installed)

## Design Decisions

**Why Symlinks?**
- Single source of truth: configs live in this repo
- Automatic sync: changes in repo or system reflect immediately
- Easy updates: edit once, works everywhere
- Version controlled: all config changes are tracked in git

**What Happens to Existing Files?**
- If a file already exists and isn't a symlink, you'll be prompted (unless using `-Force`)
- You can always restore previous versions from git history if needed

**Administrator Requirements**
- Some paths (like Windows Terminal) require admin privileges to create symlinks
- The installer will request elevation only when needed
- Most user profile paths don't require admin

## Windows-Specific Notes

- Configs are symlinked, not copied (enables automatic synchronization)
- Some system paths require Administrator privileges (installer handles this)
- Paths use PowerShell environment variables: `$env:APPDATA`, `$env:USERPROFILE`, `$env:LOCALAPPDATA`

## Key Paths Reference

| Config | Windows Path |
|--------|--------------|
| Cursor Settings | `%APPDATA%\Cursor\User\settings.json` |
| Cursor Keybindings | `%APPDATA%\Cursor\User\keybindings.json` |
| Cursor MCP | `%USERPROFILE%\.cursor\mcp.json` |
| Cursor CLI Config | `%USERPROFILE%\.cursor\cli-config.json` |
| Cursor Snippets | `%APPDATA%\Cursor\User\snippets\` |
| PowerShell Profile | `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| Git Config | `%USERPROFILE%\.gitconfig` |
| npm Config | `%USERPROFILE%\.npmrc` |
| Windows Terminal | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |

**Note**: These paths are where symlinks are created. The actual config files remain in this repository.
