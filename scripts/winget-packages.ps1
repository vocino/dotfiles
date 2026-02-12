<#
.SYNOPSIS
    Manage WinGet packages for dotfiles.

.DESCRIPTION
    Import (install) or export WinGet packages from the curated packages list.

.PARAMETER Action
    "import" to install packages from packages.json, "export" to update packages.json from current system.

.EXAMPLE
    .\winget-packages.ps1 import
    Install all packages from the curated list

.EXAMPLE
    .\winget-packages.ps1 export
    Export currently installed packages to packages.json
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet("import", "export")]
    [string]$Action
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$PackagesFile = Join-Path $RepoRoot "winget\packages.json"

if ($Action -eq "import") {
    if (-not (Test-Path $PackagesFile)) {
        Write-Error "Packages file not found: $PackagesFile"
        return
    }

    Write-Host "Installing packages from $PackagesFile" -ForegroundColor Cyan
    Write-Host "Packages that are already installed will be skipped." -ForegroundColor Yellow
    Write-Host ""

    winget import -i $PackagesFile --accept-package-agreements --accept-source-agreements

    Write-Host ""
    Write-Host "Package import complete!" -ForegroundColor Green
}
elseif ($Action -eq "export") {
    Write-Host "Exporting installed packages to $PackagesFile" -ForegroundColor Cyan
    Write-Host "Review the file afterward to remove unwanted packages." -ForegroundColor Yellow
    Write-Host ""

    winget export -o $PackagesFile --accept-source-agreements

    Write-Host ""
    Write-Host "Export complete: $PackagesFile" -ForegroundColor Green
    Write-Host "Review the file and remove system/runtime packages you don't need." -ForegroundColor Yellow
}
