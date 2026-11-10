param(
    [string]$DelayedToken = '',
    [switch]$Test,
    [switch]$Preview,
    [string]$Set = '',
    [string]$PendingFile = 'pending-default.txt'
)

$ErrorActionPreference = 'SilentlyContinue'

# Windows-only: the toast and sound use Windows APIs.
if ($env:OS -ne 'Windows_NT') { exit 0 }

$SnippetLength = 90
$SoundFile = Join-Path $env:WINDIR 'Media/Windows Notify System Generic.wav'

$configDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$dataDir = Join-Path $configDir 'turn-notify'
$togglePath = Join-Path $dataDir 'state.txt'
$logPath = Join-Path $dataDir 'notify.log'

if (-not (Test-Path -LiteralPath $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

function Write-Log([string]$msg) {
    try {
        if ((Test-Path -LiteralPath $logPath) -and (Get-Item -LiteralPath $logPath).Length -gt 1MB) {
            Move-Item -LiteralPath $logPath -Destination ($logPath + '.1') -Force
        }
        Add-Content -LiteralPath $logPath -Value ('{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $msg) -Encoding UTF8
    } catch { }
}

function Get-Toggle {
    try {
        if (Test-Path -LiteralPath $togglePath) {
            $v = (Get-Content -LiteralPath $togglePath -Encoding UTF8 -TotalCount 1).Trim()
            if ($v -eq 'off') { return 'off' }
        }
    } catch { }
    return 'on'
}

# Toggle mode: -Set on|off|status
if ($Set) {
    switch ($Set.ToLowerInvariant()) {
        'on'     { [IO.File]::WriteAllText($togglePath, 'on', [Text.Encoding]::UTF8);  Write-Output 'turn-notify: on' }
        'off'    { [IO.File]::WriteAllText($togglePath, 'off', [Text.Encoding]::UTF8); Write-Output 'turn-notify: off' }
        'status' { Write-Output ('turn-notify: ' + (Get-Toggle)) }
        default  { Write-Output 'turn-notify: usage: -Set on|off|status' }
    }
    exit 0
}

if ((Get-Toggle) -eq 'off') { exit 0 }

function Format-Snippet([string]$text) {
    $t = $text -replace '(?s)```.*?```', ' '
    $t = $t -replace '(?s)```.*', ' '
    $t = $t -replace '!\[[^\]]*\]\([^)]*\)', ''
    $t = $t -replace '\[([^\]]+)\]\([^)]+\)', '$1'
    $t = $t -replace '(?m)^\s*#{1,6}\s*', ''
    $t = $t -replace '(?m)^\s*[-*+]\s+', ''
    $t = $t -replace '(?m)^\s*\d+\.\s+', ''
    $t = $t -replace '\*\*|__|`', ''
    $t = ($t -replace '\s+', ' ').Trim()
    if ($t.Length -gt $SnippetLength) {
        $length = $SnippetLength - 1
        if ([char]::IsHighSurrogate($t[$length - 1])) { $length-- }
        $t = $t.Substring(0, $length) + '…'
    }
    return $t
}

function Get-ReplySnippet {
    param([string]$path)
    try {
        if (-not $path -or -not (Test-Path -LiteralPath $path)) { return '' }
        $lines = @(Get-Content -LiteralPath $path -Tail 300 -Encoding UTF8)
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            $o = $null
            try { $o = $lines[$i] | ConvertFrom-Json } catch { continue }
            if ($o.type -ne 'assistant' -or $o.isSidechain) { continue }
            $content = $o.message.content
            if (-not $content) { continue }
            $text = ''
            if ($content -is [string]) {
                $text = $content
            } else {
                $parts = @($content | Where-Object { $_.type -eq 'text' } | ForEach-Object { $_.text })
                $text = ($parts -join "`n")
            }
            if ($text.Trim()) {
                return (Format-Snippet $text)
            }
        }
    } catch { }
    return ''
}

function Find-Transcript {
    param([string]$sessionId, [string]$given)
    if ($given -and (Test-Path -LiteralPath $given)) { return $given }
    $root = Join-Path $configDir 'projects'
    if ($sessionId -and $sessionId -match '^[A-Za-z0-9-]+$') {
        $hit = Get-ChildItem -LiteralPath $root -Directory | ForEach-Object { Join-Path $_.FullName ($sessionId + '.jsonl') } | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
        if ($hit) { return $hit }
    }
    return ''
}

function Get-Pending {
    param([string]$path)
    try {
        $lines = @(Get-Content -LiteralPath $path -Encoding UTF8)
        if ($lines.Count -ge 2 -and $lines[0].Trim()) {
            return @{ token = $lines[0].Trim(); snippet = ($lines[1..($lines.Count - 1)] -join ' ') }
        }
    } catch { }
    return $null
}

function Show-Notification([string]$snippet) {
    # 1) Sound
    try {
        $player = New-Object System.Media.SoundPlayer $SoundFile
        $player.Load()
        $player.PlaySync()
        Write-Log 'sound-played-ok'
    } catch {
        Write-Log ('sound-error: ' + $_.Exception.GetType().FullName + ' :: ' + $_.Exception.Message)
    }

    # 2) Toast
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
        $pieces = $template.GetElementsByTagName('text')
        $pieces.Item(0).AppendChild($template.CreateTextNode('Claude Code')) | Out-Null
        $pieces.Item(1).AppendChild($template.CreateTextNode($snippet)) | Out-Null

        # Keep the toast silent so it does not double up with the SoundPlayer sound.
        $audio = $template.CreateElement('audio')
        $audio.SetAttribute('silent', 'true')
        $template.DocumentElement.AppendChild($audio) | Out-Null

        $toast = New-Object Windows.UI.Notifications.ToastNotification $template
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show($toast)
        Write-Log 'toast-submitted-ok'
    } catch {
        # Fall back to the AppID registered for Windows PowerShell.
        try {
            $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
            [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
            Write-Log 'toast-submitted-fallback-ok'
        } catch { Write-Log ('toast-error: ' + $_.Exception.GetType().FullName) }
    }
}

if ($Preview) {
    Show-Notification '通知已就绪 / Your Claude Code notification is ready.'
    Write-Output 'turn-notify: preview submitted; check your desktop and sound.'
    exit 0
}

# Delayed branch: wait 3 seconds; if a newer signal arrived, stay silent.
if ($DelayedToken) {
    if ($PendingFile -notmatch '^pending-[A-Za-z0-9-]+\.txt$') { exit 0 }
    Start-Sleep -Milliseconds 3000
    if ((Get-Toggle) -eq 'off') {
        Write-Log ("notify-skipped-off token={0}" -f $DelayedToken)
        exit 0
    }
    $pending = Get-Pending (Join-Path $dataDir $PendingFile)
    if ($pending -and $pending.token -eq $DelayedToken) {
        if ($Test) {
            Write-Log ("notify-test-final token={0}" -f $DelayedToken)
        } else {
            Write-Log ("notify-final token={0}" -f $DelayedToken)
            Show-Notification $pending.snippet
        }
    } else {
        Write-Log ("notify-cancelled token={0}" -f $DelayedToken)
    }
    exit 0
}

# Read the hook input (transcript path, session id, cwd).
# The desktop app keeps the hook's stdin pipe open, so a plain CopyTo would
# block until the 15s hook timeout cancels us. Read with a hard cap instead.
Write-Log 'hook-start'
$raw = ''
$hookInput = $null
try {
    if ([Console]::IsInputRedirected) {
        $stdin = [Console]::OpenStandardInput()
        $buffer = New-Object System.IO.MemoryStream
        $copyTask = $stdin.CopyToAsync($buffer)
        $copyTask.Wait(1500) | Out-Null
        try { $raw = [System.Text.Encoding]::UTF8.GetString($buffer.ToArray()) } catch { }
        $buffer.Dispose()
        if ($raw.Trim()) { try { $hookInput = $raw | ConvertFrom-Json } catch { } }
    }
} catch { }

$given = ''
$sessionId = ''
if ($hookInput) {
    if ($hookInput.transcript_path) { $given = [string]$hookInput.transcript_path }
    if ($hookInput.session_id) { $sessionId = [string]$hookInput.session_id }
}

$snippet = ''
if ($hookInput -and $hookInput.last_assistant_message) {
    $snippet = Format-Snippet ([string]$hookInput.last_assistant_message)
}
if (-not $snippet) {
    $transcript = Find-Transcript $sessionId $given
    $snippet = Get-ReplySnippet $transcript
}
if (-not $snippet) { $snippet = '回答已完成，可以继续输入了' }

$safeSession = $sessionId -replace '[^A-Za-z0-9\-]', ''
if (-not $safeSession) { $safeSession = 'default' }
$pendingFile = 'pending-' + $safeSession + '.txt'
$pendingPath = Join-Path $dataDir $pendingFile

$token = [guid]::NewGuid().ToString('N')
try { [IO.File]::WriteAllLines($pendingPath, @($token, $snippet), [Text.Encoding]::UTF8) } catch { }
Write-Log ("inputParsed={0} snippetLen={1} token={2}" -f [bool]$hookInput, $snippet.Length, $token)

try {
    $procArgs = @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $PSCommandPath + '"'), '-DelayedToken', $token, '-PendingFile', $pendingFile)
    if ($Test) { $procArgs += '-Test' }
    Start-Process -FilePath 'powershell.exe' -ArgumentList $procArgs -WindowStyle Hidden
} catch { Write-Log ('worker-error: ' + $_.Exception.GetType().FullName) }
