# Contributing

Report Windows/Claude Code versions, installation source/scope and expected versus observed behavior. Redact private paths, previews and credentials. See [SECURITY.md](SECURITY.md) for sensitive reports.

Runtime: Windows PowerShell 5.1 and Windows APIs; no package dependencies. Save scripts as UTF-8 with BOM. Preserve quoting for paths with spaces/non-ASCII names. Respect `CLAUDE_CONFIG_DIR` and per-session debounce tokens.

Validate with `claude plugin validate .` and `claude plugin validate ./plugins/turn-notify`. Check toggles, Stop input, single/multi-line transcripts, debounce and separate sessions using isolated temporary `CLAUDE_CONFIG_DIR`. Use `-Test` for worker checks without desktop output and `-Preview` for intentional desktop checks. Never use real private transcripts as fixtures.

Build with `scripts/build-release.ps1`. Keep marketplace and plugin versions synchronized; bump when releasing changes to invalidate caches. Verify extracted ZIP installation with the real CLI in an isolated configuration. API submission is distinct from visible delivery.

Keep generated archives, private files, local test fixtures and temporary material out of Git. Distribute binaries/archives through Releases.
