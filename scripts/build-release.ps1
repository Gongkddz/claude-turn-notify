[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$manifest = Get-Content -LiteralPath (Join-Path $root 'plugins/turn-notify/.claude-plugin/plugin.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$market = Get-Content -LiteralPath (Join-Path $root '.claude-plugin/marketplace.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$version = $manifest.version
if ($version -notmatch '^\d+\.\d+\.\d+$' -or $market.plugins[0].version -ne $version) { throw 'Plugin and marketplace versions must match.' }
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Path $dist -Force | Out-Null
$archivePath = Join-Path $dist ("claude-turn-notify-$version-windows.zip")

# Explicit public distribution inputs. Hidden manifest directories are required.
$files = @('install.cmd', 'install.ps1', 'README.md', 'LICENSE', 'AGENTS.md', 'CLAUDE.md', 'llms.txt', 'CHANGELOG.md', 'CONTRIBUTING.md', 'SECURITY.md', 'THIRD_PARTY_NOTICES.md', '.claude-plugin/marketplace.json')
foreach ($directory in @('plugins/turn-notify', 'docs')) {
    $files += Get-ChildItem -LiteralPath (Join-Path $root $directory) -Recurse -File -Force | ForEach-Object {
        $_.FullName.Substring($root.Length + 1).Replace('\', '/')
    }
}
$files = @($files | Sort-Object -Unique)
$inventory = @("# turn-notify $version — bundled files (SHA-256)")
foreach ($relative in $files) {
    $full = Join-Path $root $relative
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { throw "Missing distribution file: $relative" }
    $inventory += (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant() + '  ' + $relative
}

Add-Type -AssemblyName System.IO.Compression
$stream = [IO.File]::Open($archivePath, [IO.FileMode]::Create)
$zip = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($relative in $files) {
        $entry = $zip.CreateEntry($relative, [IO.Compression.CompressionLevel]::Optimal)
        $entry.LastWriteTime = [DateTimeOffset]::new(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
        $target = $entry.Open()
        try {
            $bytes = [IO.File]::ReadAllBytes((Join-Path $root $relative))
            $target.Write($bytes, 0, $bytes.Length)
        } finally { $target.Dispose() }
    }
    $entry = $zip.CreateEntry('FILES.txt')
    $entry.LastWriteTime = [DateTimeOffset]::new(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
    $target = $entry.Open()
    try {
        $bytes = [Text.Encoding]::UTF8.GetBytes(($inventory -join "`n") + "`n")
        $target.Write($bytes, 0, $bytes.Length)
    } finally { $target.Dispose() }
} finally { $zip.Dispose(); $stream.Dispose() }

# Also publish the bootstrap installer as a small standalone download.
Copy-Item -LiteralPath (Join-Path $root 'install.ps1') -Destination (Join-Path $dist 'install.ps1') -Force
$checksums = foreach ($item in @($archivePath, (Join-Path $dist 'install.ps1'))) {
    (Get-FileHash -LiteralPath $item -Algorithm SHA256).Hash.ToLowerInvariant() + '  ' + [IO.Path]::GetFileName($item)
}
[IO.File]::WriteAllText((Join-Path $dist 'SHA256SUMS.txt'), ($checksums -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "Built $archivePath ($($files.Count + 1) files)"
Write-Output 'SHA256SUMS.txt covers the ZIP and standalone installer.'
