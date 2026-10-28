<#
  grok-mission-control.ps1 - LIVE / STALE / RUNNING / idle inventory of local
  Grok Build sessions (grok >= 1.0.50 layout). Read-only.
#>
param(
  [int]$IdlePerFolder = 3,
  [int]$MaxIdleFolders = 12,
  [string]$OutJson = "",
  # The skill's "Verified against" grok version; pass the value from your skill copy.
  [string]$VerifiedVersion = "1.0.72",
  # Also ask the update server for the latest release (read-only; never installs).
  [switch]$CheckLatest
)
$ErrorActionPreference = 'SilentlyContinue'
$grok = Join-Path $env:USERPROFILE '.grok'

$version = $null
try { $version = ((& grok --version) 2>$null | Select-Object -First 1) } catch {}
function Get-Semver([string]$t) { if ($t -match '(\d+)\.(\d+)\.(\d+)') { return [version]("{0}.{1}.{2}" -f $Matches[1], $Matches[2], $Matches[3]) } return $null }
$installed = Get-Semver $version
$verified = Get-Semver $VerifiedVersion
$drift = if (-not $installed -or -not $verified) { 'unknown' } elseif ($installed -gt $verified) { 'newer' } elseif ($installed -lt $verified) { 'older' } else { 'none' }
$latest = $null
if ($CheckLatest) {
  try { $u = (& grok update --check --json 2>$null | Out-String) | ConvertFrom-Json; $latest = $u.latestVersion } catch {}
}

# Open TUIs. Check the pid is still a grok process; after a self-update the running
# image is renamed grok.exe.old, so flag those as running an old binary.
$active = @{}
$asPath = Join-Path $grok 'active_sessions.json'
if (Test-Path $asPath) {
  foreach ($a in @(Get-Content $asPath -Raw | ConvertFrom-Json)) {
    $alive = $false; $old = $false
    $p = Get-Process -Id $a.pid -ErrorAction SilentlyContinue
    if ($p -and $p.ProcessName -match '^grok') {
      $alive = $true
      $old = ($p.ProcessName -like '*.old') -or ("$($p.Path)" -like '*.old')
    }
    $active[$a.session_id] = [pscustomobject]@{ cwd=$a.cwd; pid=$a.pid; alive=$alive; old_binary=$old; opened_at=$a.opened_at }
  }
}

# Headless turns in flight (ours or anyone's): grok.exe with a single-turn flag.
$running = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -match '^grok(-[\d.]+)?\.exe$' -and ('' + $_.CommandLine) -match '(^|\s)(-p|--single|--prompt-file|--prompt-json)(\s|=|$)' } | ForEach-Object {
  $cmd = '' + $_.CommandLine
  $sid = if ($cmd -match '(?:-r|--resume)[ =]"?([0-9a-fA-F-]{36})') { $Matches[1] } else { '' }
  $rcwd = if ($cmd -match '--cwd[ =](?:"([^"]+)"|(\S+))') { if ($Matches[1]) { $Matches[1] } else { $Matches[2] } } else { '' }
  [pscustomobject]@{ pid=$_.ProcessId; session_id=$sid; cwd=$rcwd; started=$_.CreationDate }
})

function Get-Summary($sessionDir) {
  $p = Join-Path $sessionDir 'summary.json'
  if (-not (Test-Path $p)) { return $null }
  try { return (Get-Content $p -Raw | ConvertFrom-Json) } catch { return $null }
}
$folderMap = @{}
Get-ChildItem (Join-Path $grok 'sessions') -Directory | ForEach-Object {
  $cwd = [uri]::UnescapeDataString($_.Name)
  $sessions = @()
  Get-ChildItem $_.FullName -Directory | ForEach-Object {
    if ($_.Name -notmatch '^[0-9a-f-]{20,}$') { return }
    $s = Get-Summary $_.FullName
    if (-not $s) { return }
    $id = if ($s.info.id) { $s.info.id } else { $_.Name }
    $updated = $null
    foreach ($k in 'last_active_at','updated_at') { if (-not $updated -and $s.$k) { try { $updated = [datetime]$s.$k } catch {} } }
    if (-not $updated) { $updated = $_.LastWriteTime.ToUniversalTime() }
    $title = if ($s.generated_title) { $s.generated_title } elseif ($s.session_summary) { $s.session_summary } else { '(no title)' }
    $live = ''
    if ($active.ContainsKey($id)) { $live = if ($active[$id].alive) { 'LIVE' } else { 'STALE' } }
    if ($running | Where-Object session_id -eq $id) { $live = if ($live) { "$live+RUNNING" } else { 'RUNNING' } }
    $sessions += [pscustomobject]@{
      id=$id; title=$title; updated=$updated; live=$live
      msgs=$s.num_chat_messages; model=$s.current_model_id; effort=$s.reasoning_effort
      agent=$s.agent_name; branch=$s.head_branch
      last_turn=$s.last_turn_summary; recap=$s.last_recap
      cwd=$(if ($s.info.cwd) { $s.info.cwd } else { $cwd })
    }
  }
  if ($sessions.Count -gt 0) { $folderMap[$cwd] = $sessions }
}

$liveRows = @()
foreach ($k in $active.Keys) {
  $a = $active[$k]; $hit = $null
  if ($folderMap.ContainsKey($a.cwd)) { $hit = $folderMap[$a.cwd] | Where-Object { $_.id -eq $k } | Select-Object -First 1 }
  $liveRows += [pscustomobject]@{
    status=$(if ($a.alive) {'LIVE'} else {'STALE'}); old_binary=$a.old_binary; pid=$a.pid; cwd=$a.cwd; id=$k
    title=$(if ($hit) { $hit.title } else { '(no summary)' }); last_turn=$hit.last_turn; msgs=$hit.msgs
    model=$hit.model; effort=$hit.effort; branch=$hit.branch; recap=$hit.recap; updated=$hit.updated
  }
}
$idleFolders = @()
foreach ($cwd in $folderMap.Keys) {
  $sess = @($folderMap[$cwd] | Sort-Object updated -Descending)
  $idleFolders += [pscustomobject]@{
    cwd=$cwd; exists=(Test-Path -LiteralPath $cwd)
    session_count=$sess.Count
    live_count=@($sess | Where-Object { $_.live -like 'LIVE*' }).Count
    newest=$sess[0].updated
    sessions=@($sess | Select-Object -First $IdlePerFolder)
  }
}
$idleFolders = @($idleFolders | Sort-Object newest -Descending | Select-Object -First $MaxIdleFolders)
$result = [pscustomobject]@{
  scanned_at = (Get-Date).ToUniversalTime().ToString('o')
  grok_version = $version
  version_drift = [pscustomobject]@{ installed = "$installed"; verified = "$verified"; latest = $latest; drift = $drift }
  live = @($liveRows | Sort-Object status, cwd)
  running = $running
  folders = $idleFolders
  totals = [pscustomobject]@{
    live = @($liveRows | Where-Object status -eq 'LIVE').Count
    stale = @($liveRows | Where-Object status -eq 'STALE').Count
    running = $running.Count
    folders = $folderMap.Count
    sessions = ($folderMap.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
  }
}
if (-not $OutJson) { $OutJson = Join-Path $env:USERPROFILE '.grok-bridge\grok-mission-control.json' }
New-Item -ItemType Directory -Force -Path (Split-Path $OutJson) | Out-Null
$result | ConvertTo-Json -Depth 8 | Set-Content -Path $OutJson -Encoding utf8
Write-Output "WROTE $OutJson"
Write-Output "VERSION=$version"
$latestTxt = if ($latest) { " LATEST=$latest" } else { '' }
Write-Output "DRIFT=$drift INSTALLED=$installed VERIFIED=$verified$latestTxt"
Write-Output "LIVE=$($result.totals.live) STALE=$($result.totals.stale) RUNNING=$($result.totals.running) FOLDERS=$($result.totals.folders) SESSIONS=$($result.totals.sessions)"
foreach ($r in $result.live) {
  $st = if ($r.old_binary) { "$($r.status)(old-binary)" } else { $r.status }
  Write-Output ("LIVE_ROW|{0}|{1}|{2}|{3}|{4}" -f $st, $r.id, $r.cwd, ($r.title -replace '\|','/'), $r.pid)
}
foreach ($r in $running) { Write-Output ("RUN_ROW|{0}|{1}|{2}" -f $r.pid, $r.session_id, $r.cwd) }
