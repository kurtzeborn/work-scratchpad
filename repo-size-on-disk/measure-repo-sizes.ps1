# measure-repo-sizes.ps1
# Measures the on-disk working tree size (no git history) of Azure SDK repos
# by downloading tarballs from GitHub, measuring them, then cleaning up.
#
# Prerequisites: gh CLI authenticated with access to Azure org repos
#
# Usage: .\measure-repo-sizes.ps1

$repos = @(
    "Azure/azure-sdk-for-net",
    "Azure/azure-sdk-for-java",
    "Azure/azure-sdk-for-js",
    "Azure/azure-sdk-for-python",
    "Azure/azure-sdk-for-go",
    "Azure/azure-sdk-for-rust",
    "Azure/azure-rest-api-specs"
)

$tempDir = Join-Path $env:TEMP "azsdk-size-check"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null

$results = @()
$totalCompressedMB = 0
$totalUncompressedGB = 0

foreach ($repo in $repos) {
    $repoName = ($repo -split '/')[1]
    $tarballPath = Join-Path $tempDir "$repoName.tar.gz"
    $extractDir = Join-Path $tempDir "$repoName-extracted"

    Write-Host "`n--- $repo ---"

    # Download tarball of default branch
    Write-Host "  Downloading tarball..."
    gh api "repos/$repo/tarball" > $tarballPath 2>&1

    $compressedBytes = (Get-Item $tarballPath).Length
    $compressedMB = [math]::Round($compressedBytes / 1MB, 1)
    Write-Host "  Compressed: $compressedMB MB"

    # Extract to measure uncompressed size
    Write-Host "  Extracting..."
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
    tar -xzf $tarballPath -C $extractDir 2>&1 | Out-Null

    $uncompressedBytes = (Get-ChildItem -Path $extractDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $uncompressedGB = [math]::Round($uncompressedBytes / 1GB, 2)
    Write-Host "  Uncompressed: $uncompressedGB GB"

    $results += [PSCustomObject]@{
        Repo           = $repoName
        CompressedMB   = $compressedMB
        UncompressedGB = $uncompressedGB
    }

    $totalCompressedMB += $compressedMB
    $totalUncompressedGB += $uncompressedGB

    # Clean up immediately to save disk space
    Write-Host "  Cleaning up..."
    Remove-Item $tarballPath -Force -ErrorAction SilentlyContinue
    Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
}

# Clean up temp directory
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

# Print summary
Write-Host "`n`n========== RESULTS =========="
Write-Host ("{0,-30} {1,15} {2,18}" -f "Repo", "Compressed (MB)", "Uncompressed (GB)")
Write-Host ("{0,-30} {1,15} {2,18}" -f "----", "---------------", "------------------")
foreach ($r in $results) {
    Write-Host ("{0,-30} {1,15} {2,18}" -f $r.Repo, $r.CompressedMB, $r.UncompressedGB)
}
Write-Host ("{0,-30} {1,15} {2,18}" -f "TOTAL", [math]::Round($totalCompressedMB, 1), [math]::Round($totalUncompressedGB, 2))
