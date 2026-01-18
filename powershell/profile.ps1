# PowerShell Profile for Windows 11 Pro
# This file is symlinked from ~/dotfiles/powershell/profile.ps1

# Set encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

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
