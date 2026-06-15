param(
  [string]$CleanRoot = 'F:\CodexClean',
  [switch]$IncludeStaleUserProfiles,
  [switch]$IncludeDocumentsCodex
)

$ErrorActionPreference = 'Stop'

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $CleanRoot "Backups\before-clean-$stamp"
New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null

function Add-PathIfExists {
  param(
    [System.Collections.Generic.List[string]]$List,
    [string]$Path
  )
  if ($Path -and (Test-Path -LiteralPath $Path)) {
    $full = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    if (-not $List.Contains($full)) {
      [void]$List.Add($full)
    }
  }
}

$paths = [System.Collections.Generic.List[string]]::new()
Add-PathIfExists $paths (Join-Path $env:USERPROFILE '.codex')
Add-PathIfExists $paths (Join-Path $env:APPDATA 'Codex')
Add-PathIfExists $paths (Join-Path $env:LOCALAPPDATA 'Codex')
Add-PathIfExists $paths (Join-Path $env:LOCALAPPDATA 'OpenAI\Codex')

if ($IncludeDocumentsCodex) {
  Add-PathIfExists $paths (Join-Path $env:USERPROFILE 'Documents\Codex')
}

if ($IncludeStaleUserProfiles) {
  $usersRoot = Join-Path $env:SystemDrive 'Users'
  $current = [System.IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\')
  Get-ChildItem -LiteralPath $usersRoot -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object {
      $name = $_.Name
      ($_.FullName.TrimEnd('\') -ne $current) -and
      ($name -notin @('All Users','Default','Default User','Public','desktop.ini'))
    } |
    ForEach-Object {
      Add-PathIfExists $paths (Join-Path $_.FullName '.codex')
      Add-PathIfExists $paths (Join-Path $_.FullName 'AppData\Roaming\Codex')
      Add-PathIfExists $paths (Join-Path $_.FullName 'AppData\Local\Codex')
      Add-PathIfExists $paths (Join-Path $_.FullName 'AppData\Local\OpenAI\Codex')
      if ($IncludeDocumentsCodex) {
        Add-PathIfExists $paths (Join-Path $_.FullName 'Documents\Codex')
      }
    }
}

Start-Transcript -Path (Join-Path $backupRoot 'backup.log') -Force | Out-Null
Write-Host "Backup root: $backupRoot"

foreach ($path in $paths) {
  $safe = ($path -replace '^[A-Za-z]:\\','' -replace '[\\/:*?"<>|]', '_')
  $dest = Join-Path $backupRoot $safe
  New-Item -ItemType Directory -Path (Split-Path -Parent $dest) -Force | Out-Null
  Write-Host "Copy: $path -> $dest"
  robocopy $path $dest /E /XJ /R:1 /W:1 /XD logs sessions runtimes "plugins\cache" "Local Storage" "Session Storage" /XF auth* *.db *.sqlite | Out-Host
}

Write-Host "Done. Backup root: $backupRoot"
Stop-Transcript | Out-Null
