# FORGE installer for Claude Code (Windows)
# Usage:
#   .\install.ps1                      # user scope: ~\.claude (all projects)
#   .\install.ps1 -Scope project -Path C:\path\to\repo   # one repo
#   .\install.ps1 -Force               # overwrite existing FORGE files
# Never overwrites CLAUDE.md or settings.json. Prints manual steps instead.

param(
    [ValidateSet("user", "project")]
    [string]$Scope = "user",
    [string]$Path = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$src = $PSScriptRoot

if ($Scope -eq "user") {
    $dest = Join-Path $env:USERPROFILE ".claude"
} else {
    if ([string]::IsNullOrWhiteSpace($Path)) {
        Write-Error "Project scope requires -Path C:\path\to\repo"
        exit 1
    }
    $dest = Join-Path $Path ".claude"
}

Write-Host "FORGE install -> $dest"

$skillsDest = Join-Path $dest "skills"
$agentsDest = Join-Path $dest "agents"
New-Item -ItemType Directory -Force -Path $skillsDest | Out-Null
New-Item -ItemType Directory -Force -Path $agentsDest | Out-Null

$installed = 0
$skipped = 0

# Skills: each is a directory containing SKILL.md
Get-ChildItem -Directory (Join-Path $src "skills") | ForEach-Object {
    $target = Join-Path $skillsDest $_.Name
    if ((Test-Path $target) -and (-not $Force)) {
        Write-Host "  skip (exists): skills\$($_.Name)  (use -Force to overwrite)"
        $script:skipped++
    } else {
        Copy-Item -Recurse -Force $_.FullName $target
        Write-Host "  installed: skills\$($_.Name)"
        $script:installed++
    }
}

# Agents: flat .md files
Get-ChildItem -File (Join-Path $src "agents") -Filter *.md | ForEach-Object {
    $target = Join-Path $agentsDest $_.Name
    if ((Test-Path $target) -and (-not $Force)) {
        Write-Host "  skip (exists): agents\$($_.Name)  (use -Force to overwrite)"
        $script:skipped++
    } else {
        Copy-Item -Force $_.FullName $target
        Write-Host "  installed: agents\$($_.Name)"
        $script:installed++
    }
}

# Doctrine: copied next to CLAUDE.md, never merged automatically
$doctrineSrc = Join-Path $src "forge-doctrine.md"
$doctrineDest = Join-Path $dest "forge-doctrine.md"
if ((Test-Path $doctrineDest) -and (-not $Force)) {
    Write-Host "  skip (exists): forge-doctrine.md"
} else {
    Copy-Item -Force $doctrineSrc $doctrineDest
    Write-Host "  installed: forge-doctrine.md"
    $installed++
}

Write-Host ""
Write-Host "Done. $installed installed, $skipped skipped."
Write-Host ""
Write-Host "MANUAL STEPS (deliberate - this script does not edit your files):"
Write-Host "  1. Add this line to $dest\CLAUDE.md (create the file if missing):"
Write-Host "       @forge-doctrine.md"
Write-Host "  2. Optional hooks: review settings.example.json in the FORGE"
Write-Host "     source, then merge the hooks block into $dest\settings.json"
Write-Host "  3. Restart any running Claude Code session to load new agents."
Write-Host "  4. Per-repo state lives in .forge\ (created on first run)."
Write-Host "     Commit it for cross-machine resume, or gitignore it."
