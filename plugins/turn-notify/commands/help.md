---
description: 使用说明、更新、卸载和通知故障排查 / Help and troubleshooting
---
Explain turn-notify in the user's language using these facts:

- This is a native Windows 10/11 Claude Code plugin. It shows an answer preview and plays a system sound about three seconds after the Stop hook. Rapid Stop events in the same session coalesce; separate sessions notify independently.
- Commands: `/turn-notify:on`, `/turn-notify:off`, `/turn-notify:status`, `/turn-notify:test`, `/turn-notify:help`.
- Notification display depends on Windows notification permissions, Do not disturb / Focus assist, the audio output device, volume and an interactive desktop session. WSL, macOS, Linux and remote/headless sessions are unsupported.
- Newly installed plugins need a new Claude Code session. Use `claude plugin list` to verify registration; use the test command to check visible behavior. Registration alone does not verify desktop delivery.
- State, a rolling diagnostic log and pending answer snippets are local to `%USERPROFILE%\.claude\turn-notify\`, or `$CLAUDE_CONFIG_DIR/turn-notify` when configured. The plugin makes no network requests. Snippets can appear in Windows notification history and local pending files. Do not request transcripts or unredacted logs.
- GitHub installs update with `claude plugin marketplace update claude-turn-notify` then `claude plugin update turn-notify@claude-turn-notify`; open a new session. ZIP installs need the new release bundle installer before those commands.
- User-scope uninstall: `claude plugin uninstall turn-notify@claude-turn-notify --scope user`. For a project/local install use its matching scope. The notification switch and log may remain until the user removes the data directory. Never delete user files without a request.
- Documentation: https://github.com/Gongkddz/claude-turn-notify

Choose the relevant steps for the user's question. Do not install software, change Windows settings or erase data merely because this help command was invoked.
