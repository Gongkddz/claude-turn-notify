# Installation and troubleshooting

[English](INSTALL.md) · [简体中文](INSTALL.zh-CN.md) · [Project home](../README.md)

## Requirements

Native Windows 10/11, Windows PowerShell 5.1, plugin-capable Claude Code CLI and an interactive desktop. Check `claude --version` and `powershell.exe -NoProfile -Command '$PSVersionTable.PSVersion'`. WSL, macOS, Linux and headless servers are unsupported.

See [Claude Code setup](https://code.claude.com/docs/en/setup). This plugin needs no extra Node/Python runtime or administrator access. GitHub installation requires networking and a Git environment available to the CLI; the ZIP provides a local marketplace. Respect organization restrictions on third-party plugins.

## Install from GitHub

```powershell
claude plugin marketplace add Gongkddz/claude-turn-notify
claude plugin install turn-notify@claude-turn-notify --scope user
claude plugin list --json
```

Check each exit code and verify the requested scope and enabled state. Default to `user`; use `project` or `local` when requested, and keep later operations in the same scope. Project scope affects shared project configuration.

## Install the release ZIP

Download the ZIP and `SHA256SUMS.txt` from [Releases](https://github.com/Gongkddz/claude-turn-notify/releases/latest). Compare `Get-FileHash ./claude-turn-notify-1.0.0-windows.zip -Algorithm SHA256` with the checksum list. **Extract everything**, including `.claude-plugin` and `plugins`.

Double-click `install.cmd`, or ask an agent to run this from the extracted root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./install.ps1 -Source Local
```

The installer copies the plugin to `%LOCALAPPDATA%\ClaudeTurnNotify\marketplace\<version>`, then uses the official CLI to register and install it. You may remove the download and extraction folders afterward. ExecutionPolicy Bypass applies to that process only; the script does not change system policy or replace settings.json manually.

Options: `-Source Auto|Local|GitHub`, `-Scope user|project|local`, `-CheckOnly`. Auto selects Local inside a complete bundle and GitHub for a standalone script. CheckOnly checks the environment and CLI without changing settings or verifying desktop delivery.

## First use and verification

Open a **new Claude Code session**. Run `/turn-notify:status`; if off, run `/turn-notify:on`. Use `/turn-notify:test` to check a sample toast and sound, then finish a normal conversation turn. The test command's own answer can also trigger the normal Stop notification.

| Command | Action |
| --- | --- |
| `/turn-notify:on` | Enable |
| `/turn-notify:off` | Mute |
| `/turn-notify:status` | Read switch |
| `/turn-notify:test` | Send a sample notification if enabled |
| `/turn-notify:help` | Usage and troubleshooting |

Registration, successful process exit and visible delivery are distinct outcomes. Windows permissions, Do not disturb / Focus assist, volume and desktop availability affect presentation. Stop events within about three seconds merge per session; separate sessions remain independent.

## Update

For a GitHub source:

```powershell
claude plugin marketplace update claude-turn-notify
claude plugin update turn-notify@claude-turn-notify
```

For a ZIP source, download the new version first. If the marketplace points at an older version's directory, switch it as described below. Open a new session after updating. A marketplace update alone does not download a new GitHub release for a local ZIP source.

## Switch installation source

Use `claude plugin marketplace list` to inspect the current source. If it already matches, continue installation. To switch between GitHub and ZIP, or move to a newer ZIP directory, first check the installed plugin scope, then run:

```powershell
claude plugin uninstall turn-notify@claude-turn-notify --scope user
claude plugin marketplace remove claude-turn-notify
```

Follow the desired source's installation steps. Only act on the intended `claude-turn-notify` source. Match project/local scopes; review each scope if more than one is installed. The installer reports same-name source conflicts and preserves the existing source.

## Missing notifications or sound

- Check the new session, enabled plugin, saved switch and whether Claude Code hooks are disabled.
- Check Windows Settings → System → Notifications and Do not disturb / Focus assist. Fallback notifications may appear under Windows PowerShell.
- Check volume, audio output and `%WINDIR%\Media\Windows Notify System Generic.wav`.
- Use a native Windows desktop. WSL, SSH, service processes and noninteractive sessions are unsupported.
- Data is in `~/.claude/turn-notify` or `CLAUDE_CONFIG_DIR/turn-notify`. In `notify.log`, `sound-played-ok` means the playback call completed; `toast-submitted-ok` / `toast-submitted-fallback-ok` means the API accepted submission. These do not prove the user saw or heard it. `toast-error` / `worker-error` records failure.
- `pending-*.txt` retains recent previews. Previews may also appear on the lock screen and in notification history. Logs record technical events only; do not share private content or full transcripts.

## Uninstall

```powershell
claude plugin uninstall turn-notify@claude-turn-notify --scope user
```

If no longer needed, remove the marketplace with `claude plugin marketplace remove claude-turn-notify`. Open a new session to stop loading the old hook. The notification switch, logs, pending files and local ZIP marketplace are not automatically removed; delete them only when the user requests it.

## Official references

[Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) · [Manifest reference](https://code.claude.com/docs/en/plugins-reference) · [Hooks reference](https://code.claude.com/docs/en/hooks)
