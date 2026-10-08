<#
  grok-after-turn.ps1 - after-turn reply pack: new session images/assets, git
  state, summary fields, and the turn's final `end` line.

  grok-after-turn.ps1 -Meta <grok-turn META json>            (preferred: cwd, session, start, log, inbound images)
  grok-after-turn.ps1 -Cwd <cwd> -SessionId <uuid> [-SinceIso <utc>] [-Log <ndjson>]
#>
param(
  [string]$Meta = '',
  [string]$Cwd = '',
  [string]$SessionId = '',
  [string]$SinceIso = '',
  [string]$Log = '',
  [string]$OutDir = ''
)
$ErrorActionPreference = 'SilentlyContinue'
$inboundHashes = @(); $turnPid = 0
if ($Meta -and (Test-Path -LiteralPath $Meta)) {
  $m = Get-Content -LiteralPath $Meta -Raw | ConvertFrom-Json
  if (-not $Cwd) { $Cwd = $m.cwd }
  if (-not $Log) { $Log = $m.log }
  if (-not $SinceIso -and $m.started_at) { $SinceIso = ([datetime]$m.started_at).ToUniversalTime().ToString('o') }
  $inboundHashes = @($m.image_sha256)
  $turnPid = [int]$m.pid
}
# The end line carries the session id (also for brand-new sessions).
$end = $null
if ($Log -and (Test-Path -LiteralPath $Log)) {
  $line = Get-Content -LiteralPath $Log | Where-Object { $_ -match '^\{"type":"(end|error|result)"' } | Select-Object -Last 1
  if ($line) { try { $end = $line | ConvertFrom-Json } catch {} }
}
if (-not $SessionId -and $end) { $SessionId = $(if ($end.sessionId) { $end.sessionId } else { $end.session_id }) }
if (-not $SessionId -and $Meta) { $SessionId = $m.session_id }
if (-not $Cwd -or -not $SessionId) { Write-Output 'ERROR|need -Meta, or -Cwd and -SessionId'; exit 2 }

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
# images/ and assets/ also hold what the USER sent (TUI pastes, --prompt-json image blocks
# land in assets/). Skip files matching this turn's inbound hashes so we don't echo them back.
$images = @(); $assets = @(); $skipped = 0
foreach ($sub in @('images','assets')) {
  $p = Join-Path $sessionDir $sub
  if (-not (Test-Path $p)) { continue }
  Get-ChildItem $p -File -Recurse | Where-Object { $_.LastWriteTimeUtc -ge $Since.ToUniversalTime() } | Sort-Object LastWriteTimeUtc -Descending | ForEach-Object {
    if ($inboundHashes.Count -and ($inboundHashes -contains (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)) { $skipped++; return }
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
# Turn state: a force-stopped turn has no end line.
$running = $false
if ($turnPid) { $running = [bool](Get-Process -Id $turnPid -ErrorAction SilentlyContinue) }
$state = if ($end) { $(if ($end.type -eq 'error') { 'error' } elseif ($end.stopReason) { $end.stopReason } else { $end.stop_reason }) } elseif ($running) { 'running' } elseif ($Log) { 'stopped(no end line)' } else { 'unknown' }
$text = $null
if ($Log -and (Test-Path -LiteralPath $Log)) {
  $text = ((Get-Content -LiteralPath $Log | Where-Object { $_ -match '^\{"type":"text"' } | ForEach-Object { try { ($_ | ConvertFrom-Json).data } catch {} }) -join '')
}
$manifest = [pscustomobject]@{ cwd=$Cwd; session_id=$SessionId; session_dir=$sessionDir; state=$state; text=$text; since=$Since.ToUniversalTime().ToString('o'); scanned_at=(Get-Date).ToUniversalTime().ToString('o'); images=$images; assets=$assets; inbound_skipped=$skipped; git=$git; summary=$summary; end=$end }
$out = Join-Path $OutDir ("after-turn-{0}.json" -f $SessionId)
$manifest | ConvertTo-Json -Depth 8 | Set-Content $out -Encoding utf8
Write-Output "WROTE $out"
Write-Output "SESSION=$SessionId"
Write-Output "STATE=$state"
Write-Output ("IMAGES={0} ASSETS={1} INBOUND_SKIPPED={2}" -f $images.Count, $assets.Count, $skipped)
if ($git) { Write-Output ("GIT={0}@{1}" -f $git.branch, $git.head) }
exit 0
