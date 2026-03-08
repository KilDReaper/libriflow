#!/usr/bin/env pwsh

Write-Host "Running Flutter tests with coverage..." -ForegroundColor Cyan
Write-Host ""

# Run tests with coverage
$testOutput = flutter test test/unit test/widgets --coverage --no-pub 2>&1
$testOutput | Out-String | Write-Host

# Check if tests passed
if ($LASTEXITCODE -ne 0) {
  Write-Host "Tests failed. Exiting..." -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Generating coverage report..." -ForegroundColor Cyan
Write-Host ""

# Run coverage report
& powershell -ExecutionPolicy Bypass -File scripts/coverage_report.ps1

exit 0
