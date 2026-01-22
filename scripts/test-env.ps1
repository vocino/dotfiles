# Quick test script to check if environment variables are loaded
# Run this in Cursor's terminal: pwsh -File scripts\test-env.ps1

Write-Host "Testing Environment Variables" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$vars = @(
    "CLOUDFLARE_ACCOUNT_ID",
    "CLOUDFLARE_API_TOKEN",
    "GITHUB_TOKEN"
)

$found = 0
$missing = 0

foreach ($var in $vars) {
    $value = [Environment]::GetEnvironmentVariable($var, "Process")
    if ($value) {
        Write-Host "✓ $var" -ForegroundColor Green
        Write-Host "  Value: $($value.Substring(0, [Math]::Min(20, $value.Length)))..." -ForegroundColor Gray
        $found++
    } else {
        Write-Host "✗ $var (not set)" -ForegroundColor Red
        $missing++
    }
}

Write-Host ""
Write-Host "Summary: $found found, $missing missing" -ForegroundColor $(if ($missing -eq 0) { "Green" } else { "Yellow" })

if ($missing -gt 0) {
    Write-Host ""
    Write-Host "Note: If variables are missing, make sure:" -ForegroundColor Yellow
    Write-Host "  1. You have created secrets/.env.* files" -ForegroundColor Yellow
    Write-Host "  2. The PowerShell profile has loaded them (check with: Get-Content `$PROFILE)" -ForegroundColor Yellow
    Write-Host "  3. For GUI apps, run: .\scripts\sync-secrets.ps1" -ForegroundColor Yellow
}
