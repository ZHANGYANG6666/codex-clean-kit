param(
  [switch]$Execute
)

$ErrorActionPreference = 'Stop'

$cleanRoot = 'F:\CodexClean'
$home = Join-Path $cleanRoot 'Home'
$runtime = Join-Path $cleanRoot 'Runtime'
$projects = Join-Path $cleanRoot 'Projects'

function Ensure-Junction {
  param(
    [string]$Path,
    [string]$Target
  )

  if (-not $Execute) {
    Write-Host "DRY-RUN junction: $Path -> $Target"
    return
  }

  New-Item -ItemType Directory -Path $Target -Force | Out-Null
  $parent = Split-Path -Parent $Path
  New-Item -ItemType Directory -Path $parent -Force | Out-Null

  if (Test-Path -LiteralPath $Path) {
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -eq 'Junction') {
      Remove-Item -LiteralPath $Path -Force
    } else {
      $backup = "$Path.before-clean-rebuild-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
      Move-Item -LiteralPath $Path -Destination $backup -Force
    }
  }

  New-Item -ItemType Junction -Path $Path -Target $Target | Out-Null
}

Write-Host "Clean root: $cleanRoot"
Write-Host "Default mode is dry-run. Use -Execute to modify paths."

if ($Execute) {
  New-Item -ItemType Directory -Path $home,$runtime,$projects -Force | Out-Null
}

Ensure-Junction -Path "$env:USERPROFILE\.codex" -Target $home
Ensure-Junction -Path "$env:LOCALAPPDATA\OpenAI\Codex\runtimes" -Target $runtime

if ($Execute) {
  $config = Join-Path $home 'config.toml'
  if (-not (Test-Path -LiteralPath $config)) {
    @"
model_provider = "openai"
personality = "pragmatic"
sandbox_mode = "workspace-write"
model_reasoning_effort = "medium"
service_tier = "default"

[windows]
sandbox = "elevated"

[features]
goals = true
js_repl = false

[plugins."browser@openai-bundled"]
enabled = true

[plugins."chrome@openai-bundled"]
enabled = true

[plugins."computer-use@openai-bundled"]
enabled = true
"@ | Set-Content -LiteralPath $config -Encoding UTF8
  }
}

Write-Host "Done. Reopen Codex after this script."

