[CmdletBinding()]
param(
    [ValidateSet('Auto', 'GitHub', 'Local')]
    [string]$Source = 'Auto',
    [ValidateSet('user', 'project', 'local')]
    [string]$Scope = 'user',
    [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$repository = 'Gongkddz/claude-turn-notify'
$pluginId = 'turn-notify@claude-turn-notify'

try {
    if ($env:OS -ne 'Windows_NT') { throw 'This plugin requires native Windows 10/11. WSL is not supported.' }
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $claude) { throw 'Claude Code CLI was not found. Install it from https://code.claude.com/docs/en/setup and reopen your terminal.' }
    & $claude.Source --version
    if ($LASTEXITCODE -ne 0) { throw 'Claude Code could not start.' }
    if (-not (Get-Command powershell.exe -ErrorAction SilentlyContinue)) { throw 'Windows PowerShell 5.1 is required.' }
    if ($Source -eq 'Auto') {
        $Source = if (Test-Path -LiteralPath (Join-Path $PSScriptRoot '.claude-plugin/marketplace.json')) { 'Local' } else { 'GitHub' }
    }
    Write-Output "turn-notify: source=$Source scope=$Scope"
    if ($CheckOnly) { Write-Output 'turn-notify: prerequisites found; nothing changed.'; exit 0 }

    $marketplace = $repository
    if ($Source -eq 'Local') {
        $manifestPath = Join-Path $PSScriptRoot 'plugins/turn-notify/.claude-plugin/plugin.json'
        if (-not (Test-Path -LiteralPath $manifestPath)) { throw 'Extract the complete release ZIP before installing.' }
        $version = (Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).version
        if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'The bundle has an invalid version.' }
        # Keep a durable marketplace: users may delete Downloads after installing.
        $marketplace = Join-Path $env:LOCALAPPDATA ("ClaudeTurnNotify/marketplace/" + $version)
        if ([IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\') -ne [IO.Path]::GetFullPath($marketplace).TrimEnd('\')) {
            New-Item -ItemType Directory -Path $marketplace -Force | Out-Null
            foreach ($entry in @('.claude-plugin', 'plugins', 'LICENSE', 'README.md')) {
                $item = Join-Path $PSScriptRoot $entry
                if (-not (Test-Path -LiteralPath $item)) { throw "Bundle is missing: $entry" }
                Copy-Item -LiteralPath $item -Destination $marketplace -Recurse -Force
            }
        }
    }
    & $claude.Source plugin marketplace add $marketplace
    if ($LASTEXITCODE -ne 0) { throw 'Marketplace registration failed. Check the message above; existing sources with this name may need to be removed explicitly.' }
    & $claude.Source plugin install $pluginId --scope $Scope
    if ($LASTEXITCODE -ne 0) { throw 'Plugin installation failed. Check Claude Code policy and network access.' }
    & $claude.Source plugin list
    if ($LASTEXITCODE -ne 0) { throw 'Installation finished, but plugin listing failed. Verify with claude plugin list.' }
    Write-Output ''
    Write-Output 'Installed. Start a NEW Claude Code session, then use:'
    Write-Output '  /turn-notify:status    Check the notification switch'
    Write-Output '  /turn-notify:test      Send a sample desktop notification'
    Write-Output '  /turn-notify:help      Learn commands and troubleshooting'
    Write-Output '  /turn-notify:off       Mute notifications'
    Write-Output 'Windows notification settings and Do not disturb can hide toasts.'
} catch {
    [Console]::Error.WriteLine('turn-notify: ' + $_.Exception.Message)
    exit 1
}
