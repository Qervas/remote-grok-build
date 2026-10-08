<#
  grok-after-turn.ps1 - after-turn reply pack: new session images/assets, git
  state, summary fields, and (optionally) the final line of a grok-turn log.
#>
param(
  [Parameter(Mandatory=$true)][string]$Cwd,
  [Parameter(Mandatory=$true)][string]$SessionId,
  [string]$SinceIso = '',
  [string]$Log = '',
  [string]$OutDir = ''
)
$ErrorActionPreference = 'SilentlyContinue'
if (-not $OutDir) { $OutDir = Join-Path $env:USERPROFILE '.grok-bridge\bridge-out' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
if ($SinceIso) { $Since = [datetime]::Parse($SinceIso, $null, [System.Globalization.DateTimeStyles]::RoundtripKind) } else { $Since = [datetime]::UtcNow.AddMinutes(-30) }
$root = Join-Path $env:USERPROFILE '.grok\sessions'
$sessionDir = Join-Path $root ("{0}\{1}" -f [uri]::EscapeDataString($Cwd), $SessionId)
if (-not (Test-Path $sessionDir)) {
  # Worktree or relocated sessions live under another encoded cwd; find by id.
  $hit = Get-ChildItem $root -Directory | ForEach-Object { Join-Path $_.FullName $SessionId } | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($hit) { $sessionDir = $hit }
}
$images = @(); $assets = @()
foreach ($sub in @('images','assets')) {
  $p = Join-Path $sessionDir $sub
  if (-not (Test-Path $p)) { continue }
  Get-ChildItem $p -File -Recurse | Where-Object { $_.LastWriteTimeUtc -ge $Since.ToUniversalTime() } | Sort-Object LastWriteTimeUtc -Descending | ForEach-Object {
    $o = [pscustomobject]@{ path=$_.FullName; name=$_.Name; length=$_.Length; mtime=$_.LastWriteTimeUtc.ToString('o') }
    if ($sub -eq 'images') { $images += $o } else { $assets += $o }
  }
}
$git = $null
if (Test-Path -LiteralPath $Cwd) {
  Push-Location -LiteralPath $Cwd
  try {
    $inRepo = ((git rev-parse --is-inside-work-tree 2>$null) -eq 'true')
    if ($inRepo) { $git = [pscustomobject]@{
      branch = (git rev-parse --abbrev-ref HEAD 2>$null)
      head = (git rev-parse --short HEAD 2>$null)
      status = ((git status --porcelain 2>$null | Out-String).Trim())
      diffstat = ((git diff HEAD --stat 2>$null | Out-String).Trim())
    } }
  } finally { Pop-Location }
}
$summary = $null
$sp = Join-Path $sessionDir 'summary.json'
if (Test-Path $sp) {
  try {
    $s = Get-Content $sp -Raw | ConvertFrom-Json
    $summary = [pscustomobject]@{
      title = $(if ($s.generated_title) { $s.generated_title } else { $s.session_summary })
      last_turn_summary = $s.last_turn_summary; last_recap = $s.last_recap
      model = $s.current_model_id; effort = $s.reasoning_effort; msgs = $s.num_chat_messages
      updated = $(if ($s.last_active_at) { $s.last_active_at } else { $s.updated_at })
    }
  } catch {}
}
$end = $null
if ($Log -and (Test-Path -LiteralPath $Log)) {
  $last = Get-Content -LiteralPath $Log -Tail 1
  try { $end = $last | ConvertFrom-Json } catch {}
}
$manifest = [pscustomobject]@{ cwd=$Cwd; session_id=$SessionId; session_dir=$sessionDir; since=$Since.ToUniversalTime().ToString('o'); scanned_at=(Get-Date).ToUniversalTime().ToString('o'); images=$images; assets=$assets; git=$git; summary=$summary; end=$end }
$out = Join-Path $OutDir ("after-turn-{0}.json" -f $SessionId)
$manifest | ConvertTo-Json -Depth 8 | Set-Content $out -Encoding utf8
Write-Output "WROTE $out"
Write-Output ("IMAGES={0} ASSETS={1}" -f $images.Count, $assets.Count)
if ($git) { Write-Output ("GIT={0}@{1}" -f $git.branch, $git.head) }
if ($end) { Write-Output ("END={0}" -f $(if ($end.stopReason) { $end.stopReason } else { $end.stop_reason })) }
exit 0
