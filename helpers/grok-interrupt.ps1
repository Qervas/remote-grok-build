<#
  grok-interrupt.ps1 - stop a headless Grok Build turn and its child process tree.
  TUIs are never touched unless -IncludeTui is passed explicitly.

  grok-interrupt.ps1 -ListOnly
  grok-interrupt.ps1 -ProcessId <pid from grok-turn META>      (most precise)
  grok-interrupt.ps1 -SessionId <uuid>
  grok-interrupt.ps1 -AllHeadless                              (explicit opt-in)
#>
param(
  [string]$SessionId = '',
  [int]$ProcessId = 0,
  [switch]$AllHeadless,
  [switch]$IncludeTui,
  [switch]$ListOnly
)
$ErrorActionPreference = 'SilentlyContinue'
# CIM keeps the name grok.exe even after a self-update renames the running image to grok.exe.old.
$procs = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -match '^grok(-[\d.]+)?\.exe$' } | ForEach-Object {
  $cmd = '' + $_.CommandLine
  $kind = if ($cmd -match '(^|\s)(-p|--single|--prompt-file|--prompt-json)(\s|=|$)') { 'headless' }
          elseif ($cmd -match '(^|\s)agent(\s|$)') { 'agent' } else { 'tui' }
  [pscustomobject]@{ Pid = $_.ProcessId; Parent = $_.ParentProcessId; Kind = $kind; Cmd = $cmd }
})
Write-Output ('COUNT={0}' -f $procs.Count)
foreach ($p in $procs) {
  $c = ($p.Cmd -replace '[A-Za-z0-9+/=]{200,}', '<base64>' -replace '\|', '/')
  if ($c.Length -gt 300) { $c = $c.Substring(0, 300) + '...' }
  Write-Output ("PROC|{0}|{1}|{2}|{3}" -f $p.Pid, $p.Parent, $p.Kind, $c)
}
if ($ListOnly) { exit 0 }

$allowed = { param($p) $p.Kind -eq 'headless' -or $IncludeTui }
$targets = @()
if ($ProcessId) {
  $targets = @($procs | Where-Object { $_.Pid -eq $ProcessId -and (& $allowed $_) } | ForEach-Object Pid)
} elseif ($SessionId) {
  $targets = @($procs | Where-Object { $_.Cmd -match [regex]::Escape($SessionId) -and (& $allowed $_) } | ForEach-Object Pid)
  if ($IncludeTui) {
    $as = Join-Path $env:USERPROFILE '.grok\active_sessions.json'
    if (Test-Path $as) {
      foreach ($s in @(Get-Content $as -Raw | ConvertFrom-Json)) {
        if ($s.session_id -eq $SessionId -and ($procs.Pid -contains $s.pid)) { $targets += $s.pid }
      }
    }
  }
} elseif ($AllHeadless) {
  $targets = @($procs | Where-Object Kind -eq 'headless' | ForEach-Object Pid)
} else {
  Write-Output 'REFUSED|pass -ProcessId, -SessionId, or -AllHeadless'; exit 1
}
$targets = @($targets | Select-Object -Unique)
if ($targets.Count -eq 0) { Write-Output 'NO_MATCH'; exit 0 }
foreach ($t in $targets) {
  # /T takes the tool shells (builds, servers) the turn spawned down with it.
  & taskkill.exe /PID $t /T /F | Out-Null
  if (Get-Process -Id $t -ErrorAction SilentlyContinue) { Stop-Process -Id $t -Force }
  Write-Output ("STOPPED|{0}" -f $t)
}
