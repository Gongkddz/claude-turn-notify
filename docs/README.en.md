# turn-notify

**Step away. Know when Claude is done.**

Native Windows notifications for Claude Code: a final-answer preview, system sound and per-session three-second Stop-event coalescing. The notification hook runs locally without network requests.

[Download ZIP](https://github.com/Gongkddz/claude-turn-notify/releases/latest) · [中文](../README.md) · [For agents](../AGENTS.md) · [Installation runbook](INSTALL.md)

## Ask your agent

```text
Install https://github.com/Gongkddz/claude-turn-notify for me.
Read AGENTS.md, check requirements, install with Claude Code's plugin CLI,
verify registration, and teach me how to enable, mute, and test notifications.
```

Requires an agent with terminal access on your Windows machine. The repository provides a standard marketplace, AGENTS.md, CLAUDE.md, llms.txt, an installer and in-plugin help.

## Install

```powershell
claude plugin marketplace add Gongkddz/claude-turn-notify
claude plugin install turn-notify@claude-turn-notify --scope user
```

Open a **new Claude Code session**. Run `/turn-notify:status` and `/turn-notify:test`.

For the downloadable release, extract the full ZIP and double-click `install.cmd`. Claude Code must already be installed. No compilation, administrator rights or extra Node/Python runtime is needed. The installer keeps a durable marketplace in `%LOCALAPPDATA%\ClaudeTurnNotify\marketplace\<version>`. See the runbook to switch an existing source.

## Commands

| Command | Action |
| --- | --- |
| `/turn-notify:on` | Enable |
| `/turn-notify:off` | Mute |
| `/turn-notify:status` | Read switch |
| `/turn-notify:test` | Preview toast and sound if enabled |
| `/turn-notify:help` | Usage, updates, uninstall and troubleshooting |

## Requirements and privacy

Native Windows 10/11, Windows PowerShell 5.1, plugin-capable Claude Code and an interactive desktop. This release was checked on Windows with Claude Code 2.1.319; Windows 10 display and other versions require separate validation. WSL, macOS, Linux and headless sessions are unsupported. Windows permissions, Focus assist / Do not disturb, volume and audio devices affect delivery.

Local data lives in `~/.claude/turn-notify` or `$CLAUDE_CONFIG_DIR/turn-notify`: switch, rolling diagnostic log and pending answer previews. Previews may also appear on the lock screen and in notification history. Logs omit answer text, session IDs and transcript paths. Installation/updates use Claude Code and GitHub networking; the notification script has no telemetry.

## Development

Validate with `claude plugin validate .` and `claude plugin validate ./plugins/turn-notify`. Build with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./scripts/build-release.ps1`; ZIP and SHA-256 files go to ignored `dist/`.

[Contributing](../CONTRIBUTING.md) · [MIT](../LICENSE) · [Third-party notices](../THIRD_PARTY_NOTICES.md). Independent community project.
