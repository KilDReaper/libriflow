param(
  [string]$LcovPath = "coverage/lcov.info",
  [string]$IncludeRegex = "lib/features/.*/domain/.*",
  [double]$MinCoverage = 80.0
)

if (-not (Test-Path $LcovPath)) {
  Write-Error "Coverage file not found: $LcovPath"
  exit 1
}

[int]$totalLf = 0
[int]$totalLh = 0
[string]$currentFile = ""
[int]$currentLf = 0
[int]$currentLh = 0

foreach ($raw in Get-Content $LcovPath) {
  $line = $raw.Trim()

  if ($line.StartsWith('SF:')) {
    $currentFile = $line.Substring(3) -replace '\\', '/'
    $currentLf = 0
    $currentLh = 0
    continue
  }

  if ($line.StartsWith('LF:')) {
    $currentLf = [int]$line.Substring(3)
    continue
  }

  if ($line.StartsWith('LH:')) {
    $currentLh = [int]$line.Substring(3)
    continue
  }

  if ($line -eq 'end_of_record') {
    if ($currentFile -match $IncludeRegex) {
      $totalLf += $currentLf
      $totalLh += $currentLh
    }
  }
}

if ($totalLf -eq 0) {
  Write-Error "No files matched regex: $IncludeRegex"
  exit 1
}

$coverage = [math]::Round(($totalLh * 100.0) / $totalLf, 2)
Write-Output "Coverage scope regex: $IncludeRegex"
Write-Output "Covered lines: $totalLh/$totalLf"
Write-Output "Coverage: $coverage%"

if ($coverage -lt $MinCoverage) {
  Write-Error "Coverage check failed. Required >= $MinCoverage%, got $coverage%"
  exit 2
}

Write-Output "Coverage check passed."
