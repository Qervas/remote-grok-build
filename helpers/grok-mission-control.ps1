param(
  [int]$IdlePerFolder = 3,
  [int]$MaxIdleFolders = 12,
  [string]$OutJson = ""
)
$ErrorActionPreference = 'SilentlyContinue'
$grok = Join-Path $env:USERPROFILE '.grok'
$active = @{}
if (Test-Path (Join-Path $grok 'active_sessions.json')) {
  $raw = Get-Content (Join-Path $grok 'active_sessions.json') -Raw | ConvertFrom-Json
  foreach ($a in @($raw)) {
    $alive = $false
    try { $null = Get-Process -Id $a.pid -ErrorAction Stop; $alive = $true } catch {}
    $active[$a.session_id] = [pscustomobject]@{ cwd=$a.cwd; pid=$a.pid; alive=$alive; opened_at=$a.opened_at }
  }
}
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
    if ($s.updated_at) { try { $updated = [datetime]$s.updated_at } catch {} }
    if (-not $updated -and $s.last_active_at) { try { $updated = [datetime]$s.last_active_at } catch {} }
    if (-not $updated) { $updated = $_.LastWriteTime.ToUniversalTime() }
    $title = if ($s.generated_title) { $s.generated_title } elseif ($s.session_summary) { $s.session_summary } else { '(no title)' }
    $live = ''
    if ($active.ContainsKey($id)) { $live = if ($active[$id].alive) { 'LIVE' } else { 'STALE' } }
    $sessions += [pscustomobject]@{
      id=$id; title=$title; updated=$updated; live=$live
      msgs=$s.num_chat_messages; model=$s.current_model_id
      recap=$s.last_recap; cwd=$(if ($s.info.cwd) { $s.info.cwd } else { $cwd })
    }
  }
  if ($sessions.Count -gt 0) { $folderMap[$cwd] = $sessions }
}
$liveRows = @()
foreach ($k in $active.Keys) {
  $a = $active[$k]
  $title = '(no summary)'
  $msgs = $null; $model = $null; $recap = $null; $updated = $null
  if ($folderMap.ContainsKey($a.cwd)) {
    $hit = $folderMap[$a.cwd] | Where-Object { $_.id -eq $k } | Select-Object -First 1
    if ($hit) { $title=$hit.title; $msgs=$hit.msgs; $model=$hit.model; $recap=$hit.recap; $updated=$hit.updated }
  }
  $liveRows += [pscustomobject]@{
    status=$(if ($a.alive) {'LIVE'} else {'STALE'}); pid=$a.pid; cwd=$a.cwd; id=$k
    title=$title; msgs=$msgs; model=$model; recap=$recap; updated=$updated
  }
}
$idleFolders = @()
foreach ($cwd in $folderMap.Keys) {
  $sess = @($folderMap[$cwd] | Sort-Object updated -Descending)
  $liveCount = @($sess | Where-Object live -eq 'LIVE').Count
  $idleFolders += [pscustomobject]@{
    cwd=$cwd
    session_count=$sess.Count
    live_count=$liveCount
    newest=$sess[0].updated
    sessions=@($sess | Select-Object -First $IdlePerFolder)
  }
}
$idleFolders = @($idleFolders | Sort-Object newest -Descending | Select-Object -First $MaxIdleFolders)
$result = [pscustomobject]@{
  scanned_at = (Get-Date).ToUniversalTime().ToString('o')
  live = @($liveRows | Sort-Object status, cwd)
  folders = $idleFolders
  totals = [pscustomobject]@{
    live = @($liveRows | Where-Object status -eq 'LIVE').Count
    stale = @($liveRows | Where-Object status -eq 'STALE').Count
    folders = $folderMap.Count
    sessions = ($folderMap.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
  }
}
if (-not $OutJson) { $OutJson = Join-Path $env:USERPROFILE '.grok-bridge\grok-mission-control.json' }
$result | ConvertTo-Json -Depth 8 | Set-Content -Path $OutJson -Encoding utf8
Write-Output "WROTE $OutJson"
Write-Output "LIVE=$($result.totals.live) STALE=$($result.totals.stale) FOLDERS=$($result.totals.folders) SESSIONS=$($result.totals.sessions)"
foreach ($r in $result.live) {
  Write-Output ("LIVE_ROW|{0}|{1}|{2}|{3}|{4}" -f $r.status, $r.id, $r.cwd, ($r.title -replace '\|','/'), $r.pid)
}
