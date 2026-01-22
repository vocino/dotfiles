<#
.SYNOPSIS
    Syncs secrets from dotenv files into Windows user environment variables.

.DESCRIPTION
    Reads all .env.* files from the secrets directory (ignored by git) and writes
    selected keys to the Windows user environment so GUI apps like Cursor can access them.

.PARAMETER SecretsDir
    Path to the secrets directory (default: ~/dotfiles/secrets)

.PARAMETER AllowList
    Keys to sync into the Windows user environment.

.EXAMPLE
    .\scripts\sync-secrets.ps1 -WhatIf
    Preview the changes without writing any env vars.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$false)]
    [string]$SecretsDir = (Join-Path $env:USERPROFILE "dotfiles\secrets"),

    [Parameter(Mandatory=$false)]
    [string[]]$AllowList = @(
        "CLOUDFLARE_ACCOUNT_ID",
        "CLOUDFLARE_API_TOKEN",
        "GITHUB_TOKEN"
    )
)

function Get-DotenvValues {
    param([string]$FilePath)

    $values = @{}
    foreach ($line in Get-Content -Path $FilePath) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith("#")) {
            continue
        }

        if ($trimmed.StartsWith("export ")) {
            $trimmed = $trimmed.Substring(7).Trim()
        }

        if ($trimmed -match '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
            $key = $matches[1]
            $value = $matches[2].Trim()
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            $values[$key] = $value
        }
    }
    return $values
}

if (-not (Test-Path $SecretsDir)) {
    Write-Error "Secrets directory not found: $SecretsDir"
    exit 1
}

# Read all .env.* files (excluding .example files)
$dotenvValues = @{}
Get-ChildItem -Path $SecretsDir -Filter ".env.*" -File | Where-Object {
    -not $_.Name.EndsWith(".example")
} | ForEach-Object {
    $fileValues = Get-DotenvValues -FilePath $_.FullName
    foreach ($key in $fileValues.Keys) {
        $dotenvValues[$key] = $fileValues[$key]
    }
}

foreach ($key in $AllowList) {
    if (-not $dotenvValues.ContainsKey($key)) {
        Write-Verbose "Key not found in dotenv: $key"
        continue
    }

    $value = $dotenvValues[$key]
    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Verbose "Skipping empty value for: $key"
        continue
    }

    if ($PSCmdlet.ShouldProcess("User env", "Set $key")) {
        [Environment]::SetEnvironmentVariable($key, $value, "User")
        Write-Host "Set user environment variable: $key" -ForegroundColor Green
    }
}

Write-Host "Done. Restart apps (including Cursor) to pick up changes." -ForegroundColor Yellow
