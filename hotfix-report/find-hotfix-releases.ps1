<#
.SYNOPSIS
    Finds hotfix releases from an Azure SDK GitHub repo in the last N months.

.DESCRIPTION
    Queries GitHub for releases that were made from release/hotfix branches
    (i.e., not developed and released directly from main).

    Uses a dual approach:
    1. Searches for merged PRs from release/ branches to identify hotfix events
    2. Matches those PRs to published releases by name/date correlation

    This script is designed to work across azure-sdk-for-net, azure-sdk-for-python,
    azure-sdk-for-java, azure-sdk-for-js, and similar repos.

.PARAMETER Repo
    The GitHub repository in "owner/repo" format. Default: Azure/azure-sdk-for-net

.PARAMETER Months
    Number of months to look back. Default: 12

.PARAMETER BranchPrefixes
    Branch name prefixes that indicate a hotfix/release branch. Default: @("release/")

.PARAMETER OutputPath
    Path to write the results as a markdown file. If not specified, outputs to console.

.EXAMPLE
    .\find-hotfix-releases.ps1
    .\find-hotfix-releases.ps1 -Repo "Azure/azure-sdk-for-python" -Months 6
    .\find-hotfix-releases.ps1 -Repo "Azure/azure-sdk-for-net" -OutputPath ".\hotfix-report.md"
#>
param(
    [string]$Repo = "Azure/azure-sdk-for-net",
    [int]$Months = 12,
    [string[]]$BranchPrefixes = @("release/"),
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

# Parse owner/repo
$parts = $Repo -split "/"
if ($parts.Count -ne 2) {
    Write-Error "Repo must be in 'owner/repo' format. Got: $Repo"
    return
}
$owner = $parts[0]
$repoName = $parts[1]

$cutoffDate = (Get-Date).AddMonths(-$Months).ToString("yyyy-MM-dd")
Write-Host "Finding hotfix releases for $Repo since $cutoffDate" -ForegroundColor Cyan
Write-Host ""

function Invoke-GraphQL {
    param([string]$Query, [int]$MaxRetries = 3)
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        $body = @{ query = $Query } | ConvertTo-Json -Compress
        $raw = $body | gh api graphql --input - 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $raw | ConvertFrom-Json
        }
        if ($attempt -lt $MaxRetries) {
            $delay = $attempt * 3
            Write-Host "    Retrying in $delay seconds (attempt $attempt/$MaxRetries)..." -ForegroundColor DarkYellow
            Start-Sleep -Seconds $delay
        }
    }
    Write-Error "gh api graphql failed after $MaxRetries attempts: $raw"
    return $null
}

# ============================================================
# PHASE 1: Find all PRs from release/ branches in the time range
# ============================================================
Write-Host "Phase 1: Finding release branch PRs..." -ForegroundColor Cyan

$releasePRs = @()
foreach ($prefix in $BranchPrefixes) {
    $searchQuery = "head:$prefix merged:>$cutoffDate"
    $prs = gh pr list --repo $Repo --state merged --search $searchQuery --limit 200 --json number,title,headRefName,mergedAt,mergeCommit 2>&1 | ConvertFrom-Json
    if ($prs) {
        $releasePRs += $prs
    }
}

# Deduplicate by PR number
$releasePRs = $releasePRs | Sort-Object -Property number -Unique
Write-Host "  Found $($releasePRs.Count) release branch PRs" -ForegroundColor White

if ($releasePRs.Count -eq 0) {
    Write-Host "No release branch PRs found in the date range." -ForegroundColor Green
    return
}

# ============================================================
# PHASE 2: Get all releases in the date range
# ============================================================
Write-Host "Phase 2: Fetching releases..." -ForegroundColor Cyan

$pageSize = 50
$allReleases = @()
$cursor = $null
$hasNextPage = $true
$pageNum = 0
$cutoffISO = "${cutoffDate}T00:00:00Z"

while ($hasNextPage) {
    $pageNum++
    $afterClause = if ($cursor) { ", after:""$cursor""" } else { "" }
    
    $query = "{ repository(owner:""$owner"", name:""$repoName"") { releases(first:$pageSize, orderBy:{field:CREATED_AT, direction:DESC}$afterClause) { nodes { tagName publishedAt url tagCommit { oid } } pageInfo { hasNextPage endCursor } } } }"

    Write-Host "  Fetching releases page $pageNum..." -ForegroundColor DarkGray
    
    $result = Invoke-GraphQL -Query $query
    
    if (-not $result -or $result.errors) {
        Write-Error "GraphQL error: $($result.errors | ConvertTo-Json -Depth 5)"
        return
    }
    
    $releases = $result.data.repository.releases
    $pageInfo = $releases.pageInfo
    $nodes = $releases.nodes
    
    if (-not $nodes -or $nodes.Count -eq 0) { break }
    
    $pastCutoff = $false
    foreach ($release in $nodes) {
        if ($release.publishedAt -lt $cutoffISO) {
            $pastCutoff = $true
            break
        }
        $allReleases += $release
    }
    
    if ($pastCutoff -or -not $pageInfo.hasNextPage) {
        $hasNextPage = $false
    } else {
        $cursor = $pageInfo.endCursor
    }
}

Write-Host "  Found $($allReleases.Count) total releases in date range" -ForegroundColor White

# Build a lookup: commit SHA -> releases
$commitToReleases = @{}
foreach ($rel in $allReleases) {
    if ($rel.tagCommit) {
        $sha = $rel.tagCommit.oid
        if (-not $commitToReleases.ContainsKey($sha)) {
            $commitToReleases[$sha] = @()
        }
        $commitToReleases[$sha] += $rel
    }
}

# ============================================================  
# PHASE 3: Match release branch PRs to releases
# ============================================================
Write-Host "Phase 3: Matching PRs to releases..." -ForegroundColor Cyan

# Helper: check if a release tag matches a PR's package context
function Test-ReleaseMatchesPR {
    param($Release, $PR)
    
    $tagName = $Release.tagName
    $prBranch = $PR.headRefName
    $prTitle = $PR.title
    
    # Extract package name from tag: "Azure.Something_1.2.3" -> "Azure.Something"
    $tagPackage = $tagName -replace '_[0-9].*$', ''
    $tagVersion = if ($tagName -match '_(.+)$') { $Matches[1] } else { $null }
    
    $searchSpace = "$prBranch $prTitle".ToLower()
    
    # Generic words that should NOT be used for matching on their own
    $genericWords = @('azure', 'microsoft', 'system', 'extensions', 'resourcemanager',
                      'provisioning', 'storage', 'data', 'core', 'common', 'sdk',
                      'release', 'prepare', 'version', 'client', 'model', 'web',
                      'aspnetcore', 'configuration', 'webjobs', 'management')
    
    # Strategy 1: STRONG match - full or near-full package name appears in branch/title
    $tagPackageLower = $tagPackage.ToLower()
    $tagPackageNoDots = $tagPackageLower -replace '\.', ''
    $tagPackageSpaced = $tagPackageLower -replace '\.', ' '
    $tagPackageDashed = $tagPackageLower -replace '\.', '-'
    $tagPackageSlashed = $tagPackageLower -replace '\.', '/'
    
    foreach ($variant in @($tagPackageLower, $tagPackageNoDots, $tagPackageSpaced, $tagPackageDashed, $tagPackageSlashed)) {
        # Require word boundary after match to prevent prefix matches
        # e.g., "azure.provisioning" should NOT match "azure.provisioning.postgresql"
        $pattern = [regex]::Escape($variant) + '(?=[\s_\-/\d]|$)'
        if ($searchSpace -match $pattern) {
            return $true
        }
    }
    
    # Strategy 2: Match on multi-segment suffixes (2+ segments) after removing top-level prefix
    # e.g., "Azure.ResourceManager.PostgreSql" -> try "ResourceManager.PostgreSql"
    # This prevents cross-family matches like ResourceManager.PostgreSql matching Provisioning.PostgreSql
    $segments = $tagPackage -split '\.'
    $startIdx = if ($segments[0] -in @('Azure', 'Microsoft', 'System')) { 1 } else { 0 }
    
    # Only try suffixes of 2+ segments (single segments are too ambiguous across package families)
    for ($i = $startIdx; $i -lt ($segments.Count - 1); $i++) {
        $suffix = ($segments[$i..($segments.Count-1)] -join '.').ToLower()
        $suffixSpaced = ($segments[$i..($segments.Count-1)] -join ' ').ToLower()
        $suffixDashed = ($segments[$i..($segments.Count-1)] -join '-').ToLower()
        
        foreach ($variant in @($suffix, $suffixSpaced, $suffixDashed)) {
            # Require word boundary after match
            $pattern = [regex]::Escape($variant) + '(?=[\s_\-/\d]|$)'
            if ($searchSpace -match $pattern) {
                return $true
            }
        }
    }
    
    # Strategy 3: PascalCase split on distinctive last segment (very specific matches only)
    # e.g., "DataFactory" -> "data factory" in title
    $lastSeg = $segments[-1]
    if ($lastSeg.Length -gt 4 -and $lastSeg.ToLower() -notin $genericWords) {
        $kwSplit = ($lastSeg -creplace '(?<=.)([A-Z])', ' $1').ToLower()
        if ($kwSplit -ne $lastSeg.ToLower() -and $searchSpace -match [regex]::Escape($kwSplit)) {
            return $true
        }
    }
    
    return $false
}

$hotfixReleases = @()
$matchedPRs = @{}

foreach ($pr in $releasePRs) {
    $prMergeCommitSha = if ($pr.mergeCommit) { $pr.mergeCommit.oid } else { $null }
    $mergeDate = [datetime]$pr.mergedAt
    
    # Find matching releases
    $matchingReleases = @()
    
    foreach ($rel in $allReleases) {
        $pubDate = [datetime]$rel.publishedAt
        
        # Consider releases published within a wide window around the PR merge.
        # Branch merges back to main can happen weeks after the actual release.
        # -30 days (release from branch before merge-back) to +7 days after merge.
        $daysDiff = ($pubDate - $mergeDate).TotalDays
        if ($daysDiff -lt -30 -or $daysDiff -gt 7) { continue }
        
        # Check if this release matches the PR's package
        if (Test-ReleaseMatchesPR -Release $rel -PR $pr) {
            $matchingReleases += $rel
        }
    }
    
    # Also check releases that share the exact merge commit SHA (regardless of date window)
    if ($prMergeCommitSha -and $commitToReleases.ContainsKey($prMergeCommitSha)) {
        foreach ($rel in $commitToReleases[$prMergeCommitSha]) {
            if (Test-ReleaseMatchesPR -Release $rel -PR $pr) {
                if ($rel.tagName -notin $matchingReleases.tagName) {
                    $matchingReleases += $rel
                }
            }
        }
    }
    
    foreach ($rel in $matchingReleases) {
        # Avoid duplicate entries (same release matched by multiple PRs)
        if ($rel.tagName -notin $hotfixReleases.Tag) {
            $hotfixReleases += [PSCustomObject]@{
                Tag           = $rel.tagName
                PublishedAt   = $rel.publishedAt
                ReleaseUrl    = $rel.url
                PRNumber      = $pr.number
                PRTitle       = $pr.title
                PRUrl         = "https://github.com/$Repo/pull/$($pr.number)"
                BranchName    = $pr.headRefName
                CommitSHA     = if ($rel.tagCommit) { $rel.tagCommit.oid.Substring(0, 12) } else { "N/A" }
            }
            
            if (-not $matchedPRs.ContainsKey($pr.number)) {
                $matchedPRs[$pr.number] = @()
            }
            $matchedPRs[$pr.number] += $rel.tagName
        }
    }
    
    if ($matchingReleases.Count -eq 0) {
        Write-Host "  WARNING: No matching release found for PR #$($pr.number) ($($pr.headRefName) - $($pr.title))" -ForegroundColor DarkYellow
    }
}

# ============================================================
# PHASE 4: Output results
# ============================================================
Write-Host ""
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "  Total releases in last $Months months: $($allReleases.Count)" -ForegroundColor White
Write-Host "  Release branch PRs found: $($releasePRs.Count)" -ForegroundColor White
Write-Host "  Hotfix releases identified: $($hotfixReleases.Count)" -ForegroundColor Yellow
Write-Host ""

if ($hotfixReleases.Count -eq 0) {
    Write-Host "No hotfix releases found." -ForegroundColor Green
    return
}

# Sort by published date descending
$hotfixReleases = $hotfixReleases | Sort-Object PublishedAt -Descending

# Display summary table
$hotfixReleases | Format-Table -AutoSize Tag, @{N='Published';E={([datetime]$_.PublishedAt).ToString('yyyy-MM-dd')}}, BranchName, PRNumber

# Generate markdown report - merged list with PR as primary key
$reportLines = @()
$reportLines += "# Hotfix Releases Report"
$reportLines += ""
$reportLines += "**Repository:** [$Repo](https://github.com/$Repo)"
$reportLines += "**Date Range:** $cutoffDate to $(Get-Date -Format 'yyyy-MM-dd')"
$reportLines += "**Total Releases in Period:** $($allReleases.Count)"  
$reportLines += "**Release Branch PRs Found:** $($releasePRs.Count)"
$reportLines += "**Hotfix Releases Matched:** $($hotfixReleases.Count)"
$reportLines += ""
$reportLines += "## Method"
$reportLines += ""
$reportLines += "A release is classified as a **hotfix** if it was published through a PR from a ``release/`` branch."
$reportLines += "This indicates the release was prepared on a branch rather than directly on ``main``."
$reportLines += ""
$reportLines += "## Release Branch Activity"
$reportLines += ""
$reportLines += "| # | PR | Release Branch | Package/Tag | Published |"
$reportLines += "|---|-----|----------------|-------------|-----------|"

# Build merged list: group hotfix releases by PR, then add unmatched PRs
$unmatchedPRs = $releasePRs | Where-Object { -not $matchedPRs.ContainsKey($_.number) }

# Collect all rows: each hotfix release is a row, each unmatched PR is a row
$allRows = @()

foreach ($hf in $hotfixReleases) {
    $allRows += [PSCustomObject]@{
        SortDate   = [datetime]$hf.PublishedAt
        PRNumber   = $hf.PRNumber
        PRUrl      = $hf.PRUrl
        BranchName = $hf.BranchName
        Tag        = $hf.Tag
        ReleaseUrl = $hf.ReleaseUrl
        Published  = ([datetime]$hf.PublishedAt).ToString("yyyy-MM-dd")
    }
}

foreach ($pr in $unmatchedPRs) {
    $allRows += [PSCustomObject]@{
        SortDate   = [datetime]$pr.mergedAt
        PRNumber   = $pr.number
        PRUrl      = "https://github.com/$Repo/pull/$($pr.number)"
        BranchName = $pr.headRefName
        Tag        = $null
        ReleaseUrl = $null
        Published  = $null
    }
}

# Sort by date descending
$allRows = $allRows | Sort-Object SortDate -Descending

$i = 0
foreach ($row in $allRows) {
    $i++
    $prLink = "[#$($row.PRNumber)]($($row.PRUrl))"
    if ($row.Tag) {
        $tagLink = "[$($row.Tag)]($($row.ReleaseUrl))"
        $pubDate = $row.Published
    } else {
        $tagLink = ""
        $pubDate = ""
    }
    $reportLines += "| $i | $prLink | ``$($row.BranchName)`` | $tagLink | $pubDate |"
}

$reportLines += "---"
$reportLines += "*Generated on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') UTC*"

$report = $reportLines -join "`n"

if ($OutputPath) {
    $report | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "Report written to: $OutputPath" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host $report
}

# Also return the objects for programmatic use
return $hotfixReleases
