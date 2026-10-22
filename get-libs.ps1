# ينزّل المكتبات والخطوط إلى lib و fonts بجانب index.html
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'
Set-Location -Path $PSScriptRoot
New-Item -ItemType Directory -Force -Path 'lib','fonts' | Out-Null

$libs = [ordered]@{
  'lib/mp4-muxer.js'      = 'https://cdn.jsdelivr.net/npm/mp4-muxer@5.1.3/build/mp4-muxer.js'
  'lib/pdf.min.js'        = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js'
  'lib/pdf.worker.min.js' = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js'
}
foreach ($k in $libs.Keys) {
  Invoke-WebRequest -Uri $libs[$k] -OutFile $k -UserAgent $ua -UseBasicParsing
  Write-Host ('OK ' + $k + ' ' + [int]((Get-Item $k).Length / 1KB) + ' KB')
}

$fontUrls = @(
  'https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap',
  'https://fonts.googleapis.com/css2?family=Playpen+Sans+Arabic:wght@400;600&display=swap'
)
$sha = [Security.Cryptography.SHA1]::Create()
$all = @(); $count = 0
foreach ($u in $fontUrls) {
  $css = (Invoke-WebRequest -Uri $u -UserAgent $ua -UseBasicParsing).Content
  $found = [regex]::Matches($css, 'https://fonts\.gstatic\.com[^)''"\s]+') | ForEach-Object { $_.Value } | Sort-Object -Unique
  foreach ($f in $found) {
    $h = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($f))
    $name = (($h | ForEach-Object { $_.ToString('x2') }) -join '').Substring(0, 12) + '.woff2'
    Invoke-WebRequest -Uri $f -OutFile ('fonts/' + $name) -UserAgent $ua -UseBasicParsing
    $css = $css.Replace($f, $name); $count++
  }
  $all += $css
}
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'fonts/fonts.css'), ($all -join "`n"), (New-Object Text.UTF8Encoding($false)))
Write-Host "OK fonts/fonts.css + $count font files"
Write-Host 'Done. Upload lib and fonts with the other files.'
