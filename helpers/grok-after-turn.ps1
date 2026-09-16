param(
  [Parameter(Mandatory=$true)][string]$Cwd,
  [Parameter(Mandatory=$true)][string]$SessionId,
  [string]$SinceIso = '',
  [string]$OutDir = ''
)
$ErrorActionPreference = 'SilentlyContinue'
if (-not $OutDir) { $OutDir = Join-Path $env:USERPROFILE '.grok-bridge\bridge-out' }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
if ($SinceIso) { $Since = [datetime]::Parse($SinceIso, $null, [System.Globalization.DateTimeStyles]::RoundtripKind) } else { $Since = [datetime]::UtcNow.AddMinutes(-30) }
$enc = [uri]::EscapeDataString($Cwd)
$sessionDir = Join-Path $env:USERPROFILE ".grok\sessions\$enc\$SessionId"
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
Push-Location $Cwd
try {
  $git = [pscustomobject]@{
    branch = (git rev-parse --abbrev-ref HEAD 2>$null)
    head = (git rev-parse --short HEAD 2>$null)
    status = ((git status --porcelain 2>$null | Out-String).Trim())
    diffstat = ((git diff --stat 2>$null | Out-String).Trim())
  }
} finally { Pop-Location }
$summary = $null
$sp = Join-Path $sessionDir 'summary.json'
if (Test-Path $sp) { try { $summary = Get-Content $sp -Raw | ConvertFrom-Json } catch {} }
$manifest = [pscustomobject]@{ cwd=$Cwd; session_id=$SessionId; since=$Since.ToUniversalTime().ToString('o'); scanned_at=(Get-Date).ToUniversalTime().ToString('o'); images=$images; assets=$assets; git=$git; summary=$summary }
$out = Join-Path $OutDir ("after-turn-{0}.json" -f $SessionId)
$manifest | ConvertTo-Json -Depth 8 | Set-Content $out -Encoding utf8
Write-Output "WROTE $out"
Write-Output ("IMAGES={0} ASSETS={1}" -f $images.Count, $assets.Count)
if ($git) { Write-Output ("GIT={0}@{1}" -f $git.branch, $git.head) }
