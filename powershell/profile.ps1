# PowerShell Profile for Windows 11 Pro
# This file is symlinked from ~/dotfiles/powershell/profile.ps1

# Set encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Load secrets from local dotenv files (ignored by git)
$DotfilesRoot = Join-Path $env:USERPROFILE "dotfiles"
$SecretsDir = Join-Path $DotfilesRoot "secrets"

function Import-Dotenv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Verbose "Dotenv file not found: $Path"
        return
    }

    foreach ($line in Get-Content -Path $Path) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith("#")) {
            continue
        }

        if ($trimmed -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
            $key = $matches[1]
            $value = $matches[2].Trim()
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            Set-Item -Path "Env:$key" -Value $value
        }
    }
}

# Load all .env.* files from secrets directory (excluding .example files)
if (Test-Path $SecretsDir) {
    Get-ChildItem -Path $SecretsDir -Filter ".env.*" -File | Where-Object {
        -not $_.Name.EndsWith(".example")
    } | ForEach-Object {
        Import-Dotenv -Path $_.FullName
    }
}

# Common aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String

# Git aliases (if Git is installed)
if (Get-Command git -ErrorAction SilentlyContinue) {
    function gst { git status }
    function gco { param([string]$branch) git checkout $branch }
    function gaa { git add --all }
    function gcm { param([string]$message) git commit -m $message }
    function gp { git push }
    function gl { git pull }
}

# npm/node aliases
if (Get-Command npm -ErrorAction SilentlyContinue) {
    function nr { param([string]$script) npm run $script }
    function ni { param([string[]]$packages) npm install $packages }
    function nid { param([string[]]$packages) npm install -D $packages }
    function nu { npm update }
}

# Navigate to dotfiles directory
function dotfiles {
    Set-Location ~/dotfiles
}

# Reload profile
function reload {
    . $PROFILE
}

# Open Cursor in current directory
function cursor {
    if (Get-Command cursor -ErrorAction SilentlyContinue) {
        cursor .
    } else {
        Write-Host "Cursor CLI not found. Install from https://cursor.sh" -ForegroundColor Yellow
    }
}

# Quick git status check (useful before Cursor agent operations)
function gstc {
    git status --short
}

# Show current directory path in title
function Set-Title {
    $host.ui.RawUI.WindowTitle = "PowerShell - $(Get-Location)"
}

# Custom prompt (simple version)
function prompt {
    $currentPath = (Get-Location).Path
    if ($currentPath -eq $env:USERPROFILE) {
        $currentPath = "~"
    }
    Write-Host "$currentPath" -NoNewline -ForegroundColor Cyan
    Write-Host " > " -NoNewline
    return " "
}

# Load prompt on startup
Set-Title
