$ErrorActionPreference = 'Stop'

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = "F:\CodexClean\Backups\before-clean-$stamp"
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

$items = @(
  "$env:USERPROFILE\.codex",
  "$env:APPDATA\Codex",
  "$env:LOCALAPPDATA\Codex",
  "$env:LOCALAPPDATA\OpenAI\Codex",
  "$env:USERPROFILE\Documents\Codex",
  "C:\Users\寮犻槼\.codex",
  "C:\Users\寮犻槼\AppData\Local\OpenAI\Codex",
  "C:\Users\寮犻槼\Documents\Codex"
)

Start-Transcript -Path (Join-Path $backupRoot 'backup.log') -Force | Out-Null
Write-Host "Backup root: $backupRoot"

foreach ($item in $items) {
  if (Test-Path -LiteralPath $item) {
    $safe = ($item -replace '^[A-Za-z]:\\','' -replace '[\\/:*?"<>|]', '_')
    $dest = Join-Path $backupRoot $safe
    New-Item -ItemType Directory -Path (Split-Path -Parent $dest) -Force | Out-Null
    Write-Host "Copy: $item -> $dest"
    Copy-Item -LiteralPath $item -Destination $dest -Recurse -Force -ErrorAction Continue
  }
}

Write-Host "Done. Backup root: $backupRoot"
Stop-Transcript | Out-Null

