param(
  [string]$SessionId = '',
  [switch]$ListOnly
)
$ErrorActionPreference = 'SilentlyContinue'
$procs = @(Get-CimInstance Win32_Process -Filter "Name = 'grok.exe'" | ForEach-Object {
  [pscustomobject]@{ Pid=$_.ProcessId; Parent=$_.ParentProcessId; Cmd=$_.CommandLine }
})
Write-Output ('COUNT={0}' -f $procs.Count)
foreach ($p in $procs) { Write-Output ("PROC|{0}|{1}|{2}" -f $p.Pid, $p.Parent, (($p.Cmd -replace '\|','/') )) }
if ($ListOnly) { exit 0 }
$targets = @()
foreach ($p in $procs) {
  $cmd = '' + $p.Cmd
  if ($SessionId -and $cmd -match [regex]::Escape($SessionId)) { $targets += $p.Pid }
  elseif ($SessionId -eq '' -and ($cmd -match '--single|-p |--resume')) { $targets += $p.Pid }
}
$targets = @($targets | Select-Object -Unique)
if ($targets.Count -eq 0) { Write-Output 'NO_MATCH'; exit 0 }
foreach ($t in $targets) {
  Stop-Process -Id $t -Force -ErrorAction SilentlyContinue
  Write-Output ("STOPPED|{0}" -f $t)
}
