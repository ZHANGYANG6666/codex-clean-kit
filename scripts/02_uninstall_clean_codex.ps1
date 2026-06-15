param(
  [switch]$Execute,
  [string]$CleanRoot = 'F:\CodexClean',
  [switch]$IncludeStaleUserProfiles,
  [switch]$IncludeDocumentsCodex,
  [switch]$RemoveAppPackage
)

$ErrorActionPreference = 'Stop'

function Add-Candidate {
  param(
    [System.Collections.Generic.List[object]]$List,
    [string]$Path,
    [string]$Reason
  )
  if ($Path -and (Test-Path -LiteralPath $Path)) {
    $full = [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
    if (-not ($List | Where-Object { $_.Path -eq $full })) {
      [void]$List.Add([pscustomobject]@{ Path = $full; Reason = $Reason })
    }
  }
}

function Remove-PathSafe {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return }
  if ($Execute) {
    Write-Host "REMOVE: $Path"
    Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Continue
  } else {
    Write-Host "DRY-RUN remove: $Path"
  }
}

Write-Host "Codex clean uninstall"
Write-Host "Default mode is dry-run. Add -Execute to delete."

Get-Process Codex,codex -ErrorAction SilentlyContinue | ForEach-Object {
  if ($Execute) {
    Write-Host "STOP: $($_.ProcessName) $($_.Id)"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
  } else {
    Write-Host "DRY-RUN stop process: $($_.ProcessName) $($_.Id)"
  }
}

$candidates = [System.Collections.Generic.List[object]]::new()
Add-Candidate $candidates (Join-Path $env:USERPROFILE '.codex') 'current user codex home'
Add-Candidate $candidates (Join-Path $env:APPDATA 'Codex') 'current user roaming codex'
Add-Candidate $candidates (Join-Path $env:LOCALAPPDATA 'Codex') 'current user local codex'
Add-Candidate $candidates (Join-Path $env:LOCALAPPDATA 'OpenAI\Codex') 'current user OpenAI Codex'

if ($IncludeDocumentsCodex) {
  Add-Candidate $candidates (Join-Path $env:USERPROFILE 'Documents\Codex') 'current user Documents Codex'
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
      Add-Candidate $candidates (Join-Path $_.FullName '.codex') 'stale user codex home'
      Add-Candidate $candidates (Join-Path $_.FullName 'AppData\Roaming\Codex') 'stale user roaming codex'
      Add-Candidate $candidates (Join-Path $_.FullName 'AppData\Local\Codex') 'stale user local codex'
      Add-Candidate $candidates (Join-Path $_.FullName 'AppData\Local\OpenAI\Codex') 'stale user OpenAI Codex'
      if ($IncludeDocumentsCodex) {
        Add-Candidate $candidates (Join-Path $_.FullName 'Documents\Codex') 'stale user Documents Codex'
      }
    }
}

Write-Host "Candidates:"
$candidates | Format-Table Path,Reason -AutoSize | Out-Host

foreach ($candidate in $candidates) {
  Remove-PathSafe -Path $candidate.Path
}

if ($RemoveAppPackage) {
  $packages = Get-AppxPackage -Name 'OpenAI.Codex' -ErrorAction SilentlyContinue
  foreach ($package in $packages) {
    if ($Execute) {
      Write-Host "REMOVE APPX: $($package.PackageFullName)"
      Remove-AppxPackage -Package $package.PackageFullName -ErrorAction Continue
    } else {
      Write-Host "DRY-RUN remove app package: $($package.PackageFullName)"
    }
  }
}

if (-not $Execute) {
  Write-Host "Dry run complete. Re-run with -Execute after backup."
} else {
  Write-Host "Cleanup complete. Reinstall Codex, then run 03_rebuild_clean_codex.ps1 -Execute."
}
