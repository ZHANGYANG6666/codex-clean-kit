param(
  [string]$CleanRoot = 'F:\CodexClean'
)

$ErrorActionPreference = 'Continue'

$home = Join-Path $CleanRoot 'Home'
$runtime = Join-Path $CleanRoot 'Runtime'
$projects = Join-Path $CleanRoot 'Projects'
$homeLink = Join-Path $env:USERPROFILE '.codex'
$runtimeLink = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\runtimes'
$documentsCodex = Join-Path $env:USERPROFILE 'Documents\Codex'

function Check-Junction {
  param([string]$Path, [string]$ExpectedTarget)
  if (-not (Test-Path -LiteralPath $Path)) {
    return [pscustomobject]@{ Check = $Path; Status = 'FAIL'; Detail = 'missing' }
  }
  $item = Get-Item -LiteralPath $Path -Force
  if ($item.LinkType -ne 'Junction') {
    return [pscustomobject]@{ Check = $Path; Status = 'FAIL'; Detail = "not junction: $($item.LinkType)" }
  }
  $actual = ($item.Target -join ';')
  if ($actual -notlike "*$ExpectedTarget*") {
    return [pscustomobject]@{ Check = $Path; Status = 'WARN'; Detail = "target=$actual expected=$ExpectedTarget" }
  }
  [pscustomobject]@{ Check = $Path; Status = 'OK'; Detail = "target=$actual" }
}

$results = @()
$results += Check-Junction -Path $homeLink -ExpectedTarget $home
$results += Check-Junction -Path $runtimeLink -ExpectedTarget $runtime

foreach ($path in @($home,$runtime,$projects,$documentsCodex,(Join-Path $home 'config.toml'))) {
  $results += [pscustomobject]@{
    Check = $path
    Status = if (Test-Path -LiteralPath $path) { 'OK' } else { 'FAIL' }
    Detail = if (Test-Path -LiteralPath $path) { 'exists' } else { 'missing' }
  }
}

$pkg = Get-AppxPackage -Name 'OpenAI.Codex' -ErrorAction SilentlyContinue
$results += [pscustomobject]@{
  Check = 'OpenAI.Codex AppX'
  Status = if ($pkg) { 'OK' } else { 'WARN' }
  Detail = if ($pkg) { $pkg.PackageFullName } else { 'not installed or not visible to current user' }
}

$results | Format-Table -AutoSize

if ($results.Status -contains 'FAIL') {
  exit 1
}
