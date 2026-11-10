# Agent entry point — turn-notify

This repository is a Claude Code plugin marketplace. Its one plugin shows native Windows answer notifications. Apply this runbook when the user requests installation, maintenance, or help with this project.

## Install for a user

1. Check **native Windows**, `powershell.exe` and `claude --version`. WSL, macOS, Linux and remote/headless sessions are unsupported. Do not install unrelated runtimes. If Claude Code is missing, link to https://code.claude.com/docs/en/setup.
2. Read `docs/INSTALL.md`. Default scope is `user`; honor any user-requested project/local scope. Installation registers a marketplace and plugin in Claude Code settings. Do not replace settings.json or hand-add a Stop hook.
3. Run these commands, checking each exit code:

   ```powershell
   claude plugin marketplace add Gongkddz/claude-turn-notify
   claude plugin install turn-notify@claude-turn-notify --scope user
   claude plugin list --json
   ```

4. Verify `turn-notify@claude-turn-notify` is installed in the requested scope and enabled. An existing marketplace must resolve to this repository or a verified local release. Do not silently replace a conflicting source or remove unrelated marketplaces; follow `docs/INSTALL.md`.
5. Tell the user to open a **new Claude Code session**, then run `/turn-notify:status` and `/turn-notify:test`. Registration does not prove visible delivery. Windows permissions, Do not disturb / Focus assist, audio and an interactive desktop affect the result.
6. Teach `on`, `off`, `status`, `test`, `help`, all prefixed `/turn-notify:`. Use the user's language. State actual blockers accurately; never claim installation based only on reading instructions.

## Downloadable release

- Latest: https://github.com/Gongkddz/claude-turn-notify/releases/latest
- Bundle: `claude-turn-notify-1.0.0-windows.zip`, with `SHA256SUMS.txt` alongside it.
- Download ZIP and checksums, compare SHA-256, extract the **entire** bundle and read `install.ps1`. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./install.ps1 -Source Local` from its root. No administrator access is needed.
- Preserve `.claude-plugin` directories. The installer keeps a durable marketplace under `%LOCALAPPDATA%\ClaudeTurnNotify\marketplace\<version>` and uses the official CLI. Check exit codes.
- `-Source GitHub` uses the repository. `-CheckOnly` checks prerequisites without changing settings. `-Scope user|project|local` selects installation scope.

## Privacy and diagnosis

The hook uses Stop input's `last_assistant_message` or the current session's transcript. It does not scan unrelated latest conversations. The script makes no network requests. Data defaults to `~/.claude/turn-notify` or `$CLAUDE_CONFIG_DIR/turn-notify`. Pending files contain answer previews; Windows history can retain them. Do not request transcripts, credentials or unredacted private logs. Do not erase local state unless requested.

## Maintenance

Read `CONTRIBUTING.md`. Synchronize plugin and marketplace versions. PowerShell scripts must be UTF-8 **with BOM** for Windows PowerShell 5.1. Preserve quoting for spaces/non-ASCII paths. Keep generated releases, private files, local checks and temporary files out of Git. Build with `scripts/build-release.ps1`; include manifests, commands, license and installer.

Map: `llms.txt`. Operations: `docs/INSTALL.md`. Presentation: `README.md`, `docs/README.en.md`.
