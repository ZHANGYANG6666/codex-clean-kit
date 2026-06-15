param(
  [switch]$Execute,
  [string]$CleanRoot = 'F:\CodexClean',
  [switch]$IncludeStaleUserProfiles,
  [switch]$IncludeDocumentsCodex,
  [switch]$RemoveAppPackage
)

$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $PSCommandPath

Write-Host "[1/4] Audit current Codex state"
& (Join-Path $scriptRoot '00_audit_current_codex.ps1') -CleanRoot $CleanRoot -IncludeStaleUserProfiles:$IncludeStaleUserProfiles -IncludeDocumentsCodex:$IncludeDocumentsCodex

Write-Host "[2/4] Backup current Codex data"
& (Join-Path $scriptRoot '01_backup_current_codex.ps1') -CleanRoot $CleanRoot -IncludeStaleUserProfiles:$IncludeStaleUserProfiles -IncludeDocumentsCodex:$IncludeDocumentsCodex

Write-Host "[3/4] Clean Codex data and optional app package"
& (Join-Path $scriptRoot '02_uninstall_clean_codex.ps1') -CleanRoot $CleanRoot -Execute:$Execute -IncludeStaleUserProfiles:$IncludeStaleUserProfiles -IncludeDocumentsCodex:$IncludeDocumentsCodex -RemoveAppPackage:$RemoveAppPackage

if ($Execute) {
  Write-Host "[4/4] Cleanup executed."
  Write-Host "Now reinstall Codex, then run:"
  Write-Host "powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\03_rebuild_clean_codex.ps1 -Execute"
  Write-Host "powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\04_verify_clean_codex.ps1"
} else {
  Write-Host "[4/4] Dry run complete. Re-run with -Execute to delete."
}
