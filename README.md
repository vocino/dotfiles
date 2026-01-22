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
│   ├── install.ps1      # Main bootstrap script
│   └── sync-secrets.ps1 # Sync secrets to Windows user environment
├── secrets/             # Local secrets (git-ignored)
│   ├── .env.cloudflare.example  # Cloudflare API template
│   ├── .env.github.example      # GitHub token template
│   └── .env.*           # Your actual secrets (not in git)
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
- **PowerShell**: Custom profile with aliases, functions, and automatic secrets loading
- **Git**: Global config, aliases, ignore patterns
- **npm**: Global npm configuration (registry, auth, proxy settings)
- **Secrets Management**: Service-organized dotenv files with automatic shell loading and Windows user env sync

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

## Secrets (.env)

This repository includes a secure secrets management system that keeps tokens and API keys out of version control while making them available to your development tools and applications.

### Organization

Secrets are organized by service using separate `.env.*` files in the `secrets/` directory:

- **Service-based organization**: Each service gets its own file (e.g., `.env.cloudflare`, `.env.github`, `.env.aws`)
- **Related credentials together**: All credentials for a service are kept in one place
- **Easy to manage**: Add or remove services without affecting others
- **Git-ignored**: All `.env.*` files (except `.example` templates) are ignored by git

### Setup

1. **Copy example files** to create your local secret files:
   ```powershell
   Copy-Item secrets\.env.cloudflare.example secrets\.env.cloudflare
   Copy-Item secrets\.env.github.example secrets\.env.github
   ```

2. **Add your actual values** to the `.env.*` files:
   ```powershell
   # Edit with your preferred editor
   code secrets\.env.cloudflare
   # or
   notepad secrets\.env.cloudflare
   ```

3. **Format**: Each file uses standard dotenv format:
   ```
   CLOUDFLARE_ACCOUNT_ID=your_actual_account_id
   CLOUDFLARE_API_TOKEN=your_actual_token
   ```

### How Secrets Are Loaded

#### PowerShell Shell Sessions

The PowerShell profile automatically loads all `.env.*` files from `secrets/` on every shell startup. This means:

- **CLI tools** (git, npm, wrangler, etc.) launched from PowerShell have access
- **Terminal-based workflows** automatically get the environment variables
- **No manual loading required** - it happens automatically

#### GUI Applications (Cursor, VS Code, etc.)

GUI applications need secrets in the Windows user environment variables. Use the sync script:

```powershell
# Preview what will be synced (dry run)
.\scripts\sync-secrets.ps1 -WhatIf

# Actually sync secrets to Windows user environment
.\scripts\sync-secrets.ps1
```

**Important**: After syncing, **restart the application** (e.g., Cursor) to pick up the new environment variables.

### Using Secrets in Cursor

Cursor can access secrets in several ways:

1. **Environment Variables** (recommended for GUI):
   - Run `.\scripts\sync-secrets.ps1` to sync secrets to Windows user env
   - Restart Cursor
   - Cursor's terminal, agents, and code can now access `$env:CLOUDFLARE_API_TOKEN`, etc.

2. **Terminal Commands in Cursor**:
   - If you launch Cursor from PowerShell (e.g., `cursor .`), it inherits the shell's environment
   - The PowerShell profile loads secrets automatically

3. **Agent Operations**:
   - When Cursor agents run terminal commands, they use the environment variables
   - Commands like `curl` with API tokens work seamlessly

**Example**: Using Cloudflare API token in Cursor:
```powershell
# In Cursor's terminal or agent commands:
curl "https://api.cloudflare.com/client/v4/accounts/$env:CLOUDFLARE_ACCOUNT_ID/tokens/verify" `
  -H "Authorization: Bearer $env:CLOUDFLARE_API_TOKEN"
```

### Adding New Services

To add secrets for a new service:

1. **Create an example file**:
   ```powershell
   # Create secrets\.env.newservice.example
   @"
   # NewService API Configuration
   NEWSERVICE_API_KEY=your_api_key_here
   NEWSERVICE_SECRET=your_secret_here
   "@ | Out-File -FilePath secrets\.env.newservice.example -Encoding utf8
   ```

2. **Copy and fill in values**:
   ```powershell
   Copy-Item secrets\.env.newservice.example secrets\.env.newservice
   # Edit secrets\.env.newservice with your actual values
   ```

3. **Add to sync allowlist** (if you want it synced to Windows user env):
   ```powershell
   # Edit scripts\sync-secrets.ps1
   # Add "NEWSERVICE_API_KEY", "NEWSERVICE_SECRET" to the $AllowList array
   ```

4. **The PowerShell profile automatically loads it** - no changes needed!

### Managing Secrets

- **Update a secret**: Edit the appropriate `.env.*` file, then run `.\scripts\sync-secrets.ps1` if it's synced to user env
- **Add a new service**: Create `.env.servicename` file - it's automatically loaded
- **Remove a service**: Delete the `.env.*` file and remove from sync allowlist if needed
- **View loaded secrets**: In PowerShell, run `Get-ChildItem Env: | Where-Object { $_.Name -like "*CLOUDFLARE*" -or $_.Name -like "*GITHUB*" }`

### Security Notes

- ✅ All `.env.*` files are git-ignored (never committed)
- ✅ Only `.example` template files are tracked in git
- ✅ Secrets are stored locally on your machine
- ✅ Sync script only writes to Windows user environment (not system-wide)
- ⚠️ Keep your `secrets/` directory secure and don't share it
- ⚠️ Rotate tokens if they're ever exposed or shared

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
| Secrets Directory | `%USERPROFILE%\dotfiles\secrets\` |
| Secrets Examples | `%USERPROFILE%\dotfiles\secrets\.env.*.example` |

**Note**: These paths are where symlinks are created. The actual config files remain in this repository.
