<#
  grok-turn.ps1 - launch one headless Grok Build turn (grok >= 1.0.50) in the
  background and stream NDJSON to a log the bridge can tail.

  Resume:   grok-turn.ps1 -Cwd C:\path\proj -SessionId <uuid> -Prompt "fix the bug"
  New:      grok-turn.ps1 -Cwd C:\path\proj -Prompt "start"        (id arrives on the `end` line)
  Images:   grok-turn.ps1 -Cwd ... -SessionId ... -Prompt "see this" -Images C:\in\a.png
  Preview:  add -DryRun to print the command line without launching.

  Prints: PID=<pid>  LOG=<ndjson>  ERR=<stderr>  META=<json>
#>
param(
  [Parameter(Mandatory=$true)][string]$Cwd,
  [string]$SessionId = '',
  [string]$Prompt = '',
  [string]$PromptFile = '',
  [string[]]$Images = @(),
  [string]$Model = '',
  [string]$Effort = '',
  [ValidateSet('streaming-json','streaming-messages-json','json','plain')][string]$Format = 'streaming-json',
  [switch]$PartialMessages,
  [switch]$Fork,
  [string]$PermissionMode = '',
  [switch]$NoAlwaysApprove,
  [int]$MaxTurns = 0,
  [string]$OutDir = '',
  [int]$MaxInlineChars = 30000,
  [switch]$Wait,
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

function Quote-Arg([string]$a) {
  # CommandLineToArgvW-compatible quoting for native exes.
  if ($a -eq '') { return '""' }
  if ($a -notmatch '[\s"]') { return $a }
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('"'); $bs = 0
  foreach ($ch in $a.ToCharArray()) {
    if ($ch -eq [char]'\') { $bs++; continue }
    if ($ch -eq [char]'"') { [void]$sb.Append('\' * ($bs * 2 + 1)); [void]$sb.Append('"'); $bs = 0; continue }
    if ($bs) { [void]$sb.Append('\' * $bs); $bs = 0 }
    [void]$sb.Append($ch)
  }
  if ($bs) { [void]$sb.Append('\' * ($bs * 2)) }
  [void]$sb.Append('"')
  return $sb.ToString()
}

if (-not (Test-Path -LiteralPath $Cwd -PathType Container)) { Write-Output "ERROR|cwd not found: $Cwd"; exit 2 }
$Cwd = (Resolve-Path -LiteralPath $Cwd).ProviderPath
if ($PromptFile) { $Prompt = Get-Content -LiteralPath $PromptFile -Raw }
if (-not $Prompt -and $Images.Count -eq 0) { Write-Output 'ERROR|no prompt'; exit 2 }
if ($Fork -and -not $SessionId) { Write-Output 'ERROR|-Fork needs -SessionId'; exit 2 }

$grok = (Get-Command grok -ErrorAction SilentlyContinue).Source
if (-not $grok) { $grok = Join-Path $env:USERPROFILE '.grok\bin\grok.exe' }
if (-not $OutDir) { $OutDir = Join-Path $env:USERPROFILE '.grok-bridge\turns' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$tag = if ($SessionId) { $SessionId } else { 'new' }
$base = Join-Path $OutDir "$tag-$stamp"
$log = "$base.ndjson"; $err = "$base.stderr.txt"; $meta = "$base.json"; $pfile = "$base.prompt.txt"

$a = New-Object System.Collections.Generic.List[string]
$a.Add('--cwd'); $a.Add($Cwd)
if ($SessionId) { $a.Add('--resume'); $a.Add($SessionId); if ($Fork) { $a.Add('--fork-session') } }
if ($Model)  { $a.Add('--model'); $a.Add($Model) }
if ($Effort) { $a.Add('--effort'); $a.Add($Effort) }
if ($PermissionMode) { $a.Add('--permission-mode'); $a.Add($PermissionMode) }
elseif (-not $NoAlwaysApprove) { $a.Add('--always-approve') }
if ($MaxTurns -gt 0) { $a.Add('--max-turns'); $a.Add("$MaxTurns") }
$a.Add('--no-auto-update')
$a.Add('--output-format'); $a.Add($Format)
if ($PartialMessages -and $Format -eq 'streaming-messages-json') { $a.Add('--include-partial-messages') }

$mode = 'prompt-file'; $fallbackImages = @()
if ($Images.Count -gt 0) {
  $blocks = New-Object System.Collections.ArrayList
  [void]$blocks.Add([ordered]@{ type = 'text'; text = $(if ($Prompt) { $Prompt } else { 'See the attached image(s).' }) })
  foreach ($img in $Images) {
    $full = (Resolve-Path -LiteralPath $img).ProviderPath
    $ext = [IO.Path]::GetExtension($full).ToLowerInvariant()
    $mime = switch ($ext) { '.png' {'image/png'} '.jpg' {'image/jpeg'} '.jpeg' {'image/jpeg'} '.gif' {'image/gif'} '.webp' {'image/webp'} default {'application/octet-stream'} }
    [void]$blocks.Add([ordered]@{ type = 'image'; mimeType = $mime; data = [Convert]::ToBase64String([IO.File]::ReadAllBytes($full)) })
    $fallbackImages += $full
  }
  $json = ConvertTo-Json -InputObject $blocks -Depth 5 -Compress
  $projected = ($a | ForEach-Object { Quote-Arg $_ }) -join ' '
  if (($projected.Length + $json.Length + 32) -le $MaxInlineChars) {
    $mode = 'prompt-json'; $a.Add('--prompt-json'); $a.Add($json)
  } else {
    $mode = 'prompt-file+paths'
    $Prompt = ($Prompt + "`n`nAttached image file(s) on this machine, open them before answering:`n" + (($fallbackImages | ForEach-Object { "- $_" }) -join "`n")).Trim()
  }
}
if ($mode -ne 'prompt-json') {
  [IO.File]::WriteAllText($pfile, $Prompt, (New-Object System.Text.UTF8Encoding($false)))
  $a.Add('--prompt-file'); $a.Add($pfile)
}
$argLine = ($a | ForEach-Object { Quote-Arg $_ }) -join ' '
$shown = $argLine -replace '[A-Za-z0-9+/=]{64,}', '<base64>'

if ($DryRun) {
  Write-Output "DRYRUN|mode=$mode|chars=$($argLine.Length)"
  Write-Output "CMD|$grok $shown"
  exit 0
}

$p = Start-Process -FilePath $grok -ArgumentList $argLine -WorkingDirectory $Cwd `
  -RedirectStandardOutput $log -RedirectStandardError $err -WindowStyle Hidden -PassThru
$info = [ordered]@{
  pid = $p.Id; cwd = $Cwd; session_id = $SessionId; fork = [bool]$Fork; format = $Format; mode = $mode
  images = $fallbackImages; image_sha256 = @($fallbackImages | ForEach-Object { (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash }); log = $log; stderr = $err; started_at = (Get-Date).ToUniversalTime().ToString('o'); cmd = "$grok $shown"
}
$info | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $meta -Encoding utf8
Write-Output "PID=$($p.Id)"; Write-Output "LOG=$log"; Write-Output "ERR=$err"; Write-Output "META=$meta"; Write-Output "MODE=$mode"

if ($Wait) {
  # Prefer polling (Get-Process -Id + tail LOG) over -Wait on a remote link: long waits can be cut off.
  $p.WaitForExit()
  Write-Output "EXIT=$($p.ExitCode)"
  $endLine = Get-Content -LiteralPath $log -ErrorAction SilentlyContinue | Where-Object { $_ -match '^\{"type":"(end|error|result)"' } | Select-Object -Last 1
  if ($endLine) { try { $e = $endLine | ConvertFrom-Json; Write-Output ("END|{0}|{1}" -f $(if ($e.stopReason) { $e.stopReason } else { $e.stop_reason }), $(if ($e.sessionId) { $e.sessionId } else { $e.session_id })) } catch {} }
  else { Write-Output 'END|none' }
}
