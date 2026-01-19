<#
.SYNOPSIS
    Installs dotfiles by creating symbolic links from system paths to files in this repository.

.DESCRIPTION
    This script creates symbolic links from system configuration paths to files in the dotfiles
    repository. It supports selective installation and can be run multiple times safely.

.PARAMETER Only
    Install only specific configurations. Options: cursor, powershell, git, npm, windows-terminal, wsl

.PARAMETER Force
    Overwrite existing files without prompting.

.EXAMPLE
    .\install.ps1
    Install all configurations

.EXAMPLE
    .\install.ps1 -Only cursor,git
    Install only Cursor and Git configurations

.EXAMPLE
    .\install.ps1 -Force
    Install all configurations, overwriting existing files without prompting
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$Only,

    [Parameter(Mandatory=$false)]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Get the script directory (dotfiles root)
$ScriptRoot = Split-Path -Parent $PSScriptRoot
$RepoRoot = $ScriptRoot

# Define symlink mappings
$SymlinkMappings = @{
    "cursor" = @(
        @{
            Source = Join-Path $RepoRoot "cursor\settings.json"
            Target = "$env:APPDATA\Cursor\User\settings.json"
            Type = "File"
        },
        @{
            Source = Join-Path $RepoRoot "cursor\keybindings.json"
            Target = "$env:APPDATA\Cursor\User\keybindings.json"
            Type = "File"
        },
        @{
            Source = Join-Path $RepoRoot "cursor\mcp.json"
            Target = "$env:USERPROFILE\.cursor\mcp.json"
            Type = "File"
        },
        @{
            Source = Join-Path $RepoRoot "cursor\cli-config.json"
            Target = "$env:USERPROFILE\.cursor\cli-config.json"
            Type = "File"
        },
        @{
            Source = Join-Path $RepoRoot "cursor\snippets"
            Target = "$env:APPDATA\Cursor\User\snippets"
            Type = "Directory"
        }
    )
    "powershell" = @(
        @{
            Source = Join-Path $RepoRoot "powershell\profile.ps1"
            Target = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
            Type = "File"
        }
    )
    "git" = @(
        @{
            Source = Join-Path $RepoRoot "git\.gitconfig"
            Target = "$env:USERPROFILE\.gitconfig"
            Type = "File"
        },
        @{
            Source = Join-Path $RepoRoot "git\.gitignore_global"
            Target = "$env:USERPROFILE\.gitignore_global"
            Type = "File"
        }
    )
    "npm" = @(
        @{
            Source = Join-Path $RepoRoot "npm\.npmrc"
            Target = "$env:USERPROFILE\.npmrc"
            Type = "File"
        }
    )
    "windows-terminal" = @(
        @{
            Source = Join-Path $RepoRoot "windows-terminal\settings.json"
            Target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            Type = "File"
            RequiresAdmin = $true
        }
    )
    "wsl" = @(
        @{
            Source = Join-Path $RepoRoot "wsl\.bashrc"
            Target = "$env:USERPROFILE\.bashrc"
            Type = "File"
        }
    )
}

# Function to check if path is a symlink
function Test-Symlink {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $false
    }

    $item = Get-Item $Path -Force
    return ($item.LinkType -eq "SymbolicLink")
}

# Function to create symlink
function New-Symlink {
    param(
        [string]$Source,
        [string]$Target,
        [string]$Type
    )

    # Check if source exists
    if (-not (Test-Path $Source)) {
        Write-Warning "Source does not exist: $Source (skipping)"
        return $false
    }

    # Get parent directory of target
    $TargetParent = Split-Path -Parent $Target
    if (-not (Test-Path $TargetParent)) {
        Write-Host "Creating directory: $TargetParent" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $TargetParent -Force | Out-Null
    }

    # Check if target already exists
    if (Test-Path $Target) {
        if (Test-Symlink -Path $Target) {
            $currentTarget = (Get-Item $Target).Target
            if ($currentTarget -eq $Source) {
                Write-Host "Symlink already exists: $Target -> $Source" -ForegroundColor Green
                return $true
            } else {
                Write-Warning "Symlink points to different location: $Target -> $currentTarget (expected: $Source)"
                if (-not $Force) {
                    $response = Read-Host "Overwrite? (y/N)"
                    if ($response -ne "y" -and $response -ne "Y") {
                        return $false
                    }
                }
                Remove-Item $Target -Force
            }
        } else {
            Write-Warning "File already exists at target: $Target"
            if (-not $Force) {
                $response = Read-Host "Overwrite? (y/N)"
                if ($response -ne "y" -and $response -ne "Y") {
                    return $false
                }
            }
            Remove-Item $Target -Force
        }
    }

    # Create symlink
    try {
        if ($Type -eq "Directory") {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        } else {
            $absoluteSource = Resolve-Path $Source
            New-Item -ItemType SymbolicLink -Path $Target -Target $absoluteSource -Force | Out-Null
        }
        Write-Host "Created symlink: $Target -> $Source" -ForegroundColor Green
        return $true
    } catch {
        Write-Error "Failed to create symlink: $_"
        return $false
    }
}

# Main installation logic
Write-Host "Dotfiles Installer" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host ""

# Determine which configs to install
$configsToInstall = if ($Only) {
    $Only
} else {
    $SymlinkMappings.Keys
}

# Filter out WSL if directory or config files don't exist
if ("wsl" -in $configsToInstall) {
    $wslPath = Join-Path $RepoRoot "wsl"
    if (-not (Test-Path $wslPath)) {
        Write-Host "WSL directory not found, skipping WSL configs" -ForegroundColor Yellow
        $configsToInstall = $configsToInstall | Where-Object { $_ -ne "wsl" }
    } else {
        # Check if any WSL config files actually exist
        $wslMappings = $SymlinkMappings["wsl"]
        $hasWslConfigs = $wslMappings | Where-Object { Test-Path $_.Source }
        if (-not $hasWslConfigs) {
            Write-Host "WSL directory exists but no config files found, skipping WSL configs" -ForegroundColor Yellow
            $configsToInstall = $configsToInstall | Where-Object { $_ -ne "wsl" }
        }
    }
}

$successCount = 0
$failureCount = 0

foreach ($config in $configsToInstall) {
    if (-not $SymlinkMappings.ContainsKey($config)) {
        Write-Warning "Unknown configuration: $config (skipping)"
        continue
    }

    Write-Host "Installing $config configuration..." -ForegroundColor Yellow

    $mappings = $SymlinkMappings[$config]
    $requiresAdmin = $mappings | Where-Object { $_.RequiresAdmin -eq $true }

    if ($requiresAdmin) {
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if (-not $isAdmin) {
            Write-Warning "Administrator privileges may be required for $config configuration"
        }
    }

    foreach ($mapping in $mappings) {
        if (New-Symlink -Source $mapping.Source -Target $mapping.Target -Type $mapping.Type) {
            $successCount++
        } else {
            $failureCount++
        }
    }

    Write-Host ""
}

Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "  Success: $successCount" -ForegroundColor Green
Write-Host "  Failed:  $failureCount" -ForegroundColor $(if ($failureCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($failureCount -eq 0) {
    Write-Host "All symlinks created successfully!" -ForegroundColor Green
    Write-Host "You may need to restart your applications for changes to take effect." -ForegroundColor Yellow
} else {
    Write-Host "Some symlinks failed to create. Check the errors above." -ForegroundColor Red
}
