param(
  [string]$CleanRoot = 'F:\CodexClean',
  [switch]$IncludeStaleUserProfiles,
  [switch]$IncludeDocumentsCodex
)

$ErrorActionPreference = 'Continue'

function Show-Path {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path) {
    $item = Get-Item -LiteralPath $Path -Force
    $target = $null
    if ($item.LinkType) { $target = $item.Target }
    $size = $null
    if ($item.PSIsContainer -and -not $item.LinkType) {
      $size = (Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    } elseif (-not $item.PSIsContainer) {
      $size = $item.Length
    }
    [pscustomobject]@{
      Path = $Path
      Exists = $true
      LinkType = $item.LinkType
      Target = ($target -join ';')
      SizeGB = if ($size) { [math]::Round($size / 1GB, 3) } else { $null }
    }
  } else {
    [pscustomobject]@{ Path = $Path; Exists = $false; LinkType = $null; Target = $null; SizeGB = $null }
  }
}

$paths = @(
  (Join-Path $env:USERPROFILE '.codex'),
  (Join-Path $env:APPDATA 'Codex'),
  (Join-Path $env:LOCALAPPDATA 'Codex'),
  (Join-Path $env:LOCALAPPDATA 'OpenAI\Codex'),
  (Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\runtimes'),
  (Join-Path $env:USERPROFILE 'Documents\Codex'),
  $CleanRoot
)

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
      $paths += (Join-Path $_.FullName '.codex')
      $paths += (Join-Path $_.FullName 'AppData\Local\OpenAI\Codex')
      if ($IncludeDocumentsCodex) {
        $paths += (Join-Path $_.FullName 'Documents\Codex')
      }
    }
}

Write-Host "Codex processes:"
Get-Process Codex,codex -ErrorAction SilentlyContinue | Select-Object Id,ProcessName,CPU,WorkingSet64,Path | Format-Table -AutoSize

Write-Host "Codex AppX packages:"
Get-AppxPackage -Name 'OpenAI.Codex' -ErrorAction SilentlyContinue | Select-Object Name,PackageFullName,Status,InstallLocation | Format-List

Write-Host "Codex paths:"
$paths | Select-Object -Unique | ForEach-Object { Show-Path $_ } | Format-Table -AutoSize
