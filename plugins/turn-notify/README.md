# turn-notify

Native Windows notifications for Claude Code. When a reply finishes, this plugin sends a Windows toast containing a short answer preview and plays the system notification sound. Stop events within a three-second window are merged per session. The notification hook runs locally without network requests.

## Install

Ask your agent to install https://github.com/Gongkddz/claude-turn-notify, or run:

```powershell
claude plugin marketplace add Gongkddz/claude-turn-notify
claude plugin install turn-notify@claude-turn-notify --scope user
```

Requires native Windows 10/11, Windows PowerShell 5.1 and Claude Code with plugin support. Open a new Claude Code session after installing.

## Commands

| Command | Action |
| --- | --- |
| `/turn-notify:on` | Enable notifications |
| `/turn-notify:off` | Mute notifications |
| `/turn-notify:status` | Read the notification switch |
| `/turn-notify:test` | Send a sample toast and sound |
| `/turn-notify:help` | Usage, updates and troubleshooting |

Windows settings, Focus assist / Do not disturb, and audio settings affect delivery. An interactive Windows desktop is required. WSL is unsupported. The switch, rolling log and pending snippets are stored under `~/.claude/turn-notify` (or `$CLAUDE_CONFIG_DIR/turn-notify`). Answer previews can appear in local files and Windows notification history.

See the [repository](https://github.com/Gongkddz/claude-turn-notify) for release downloads and agent installation instructions. Original code is licensed under MIT; see the bundled LICENSE.
