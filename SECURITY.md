# Security and privacy

This plugin runs PowerShell through Claude Code's Stop hook, reads the final answer or current-session transcript and submits a Windows notification. The hook makes no network requests; installation and updates may access GitHub.

Pending files contain recent answer previews. Windows lock-screen settings and notification history can expose them. Diagnostic logs omit answer text, session IDs and transcript paths. Data is under `~/.claude/turn-notify` or `$CLAUDE_CONFIG_DIR/turn-notify`.

Use **Security → Report a vulnerability** in this repository when available. Do not post credentials, private transcripts or sensitive answers in public issues. Include the affected version and minimal redacted reproduction. This community project has no guaranteed response-time SLA.
