$ErrorActionPreference = 'Stop'
$siteRoot = $PSScriptRoot
$assetRoot = Join-Path $siteRoot 'site-public'
$allowedFiles = @(
  'index.html',
  'about.html',
  'founding-operator-program.html',
  'ios-waitlist.html',
  'privacy.html',
  'terms.html',
  'style.css',
  'homepage.css'
)

if (-not (Test-Path -LiteralPath $assetRoot)) {
  New-Item -ItemType Directory -Path $assetRoot | Out-Null
}

# Keep deployment assets on an explicit allowlist. Never publish .git or .wrangler.
foreach ($file in $allowedFiles) {
  Copy-Item -LiteralPath (Join-Path $siteRoot $file) -Destination (Join-Path $assetRoot $file) -Force
}
$actualFiles = @(Get-ChildItem -LiteralPath $assetRoot -File | Select-Object -ExpandProperty Name)
$unexpected = @($actualFiles | Where-Object { $_ -notin $allowedFiles })
if ($unexpected.Count -gt 0) {
  throw "Unexpected files in site-public: $($unexpected -join ', ')"
}

Push-Location $siteRoot
try {
  npx.cmd wrangler deploy
  if ($LASTEXITCODE -ne 0) { throw 'Wrangler deployment failed.' }
} finally {
  Pop-Location
}
