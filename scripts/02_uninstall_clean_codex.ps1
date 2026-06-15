param(
  [switch]$Execute
)

$ErrorActionPreference = 'Stop'

function Remove-PathSafe {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  if ($Execute) {
    Write-Host "REMOVE: $Path"
    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Continue
  } else {
    Write-Host "DRY-RUN remove: $Path"
  }
}

Write-Host "This script removes Codex local/user data paths. Default mode is dry-run."
Write-Host "Use -Execute only after running 01_backup_current_codex.ps1."

Get-Process Codex,codex -ErrorAction SilentlyContinue | ForEach-Object {
  if ($Execute) {
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
  } else {
    Write-Host "DRY-RUN stop process: $($_.ProcessName) $($_.Id)"
  }
}

$paths = @(
  "$env:USERPROFILE\.codex",
  "$env:APPDATA\Codex",
  "$env:LOCALAPPDATA\Codex",
  "$env:LOCALAPPDATA\OpenAI\Codex",
  "$env:USERPROFILE\Documents\Codex\2026-05-22\c-1-c-users-documents-codex\.codex",
  "C:\Users\寮犻槼\.codex",
  "C:\Users\寮犻槼\AppData\Local\OpenAI\Codex",
  "C:\Users\寮犻槼\Documents\Codex"
)

foreach ($path in $paths) {
  Remove-PathSafe -Path $path
}

Write-Host "Windows app package uninstall is not automatic in this script."
Write-Host "Uninstall Codex from Settings > Apps, then reinstall it before running 03_rebuild_clean_codex.ps1."

