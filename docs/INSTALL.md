# 安装与排障 / Installation runbook

## 前提

原生 Windows 10/11、Windows PowerShell 5.1、支持插件的 Claude Code CLI、交互式桌面。检查 `claude --version` 和 `powershell.exe -NoProfile -Command '$PSVersionTable.PSVersion'`。WSL、macOS、Linux、无桌面服务器不适用。

[Claude Code 官方安装](https://code.claude.com/docs/en/setup)。本插件无需额外 Node/Python 运行库或管理员权限。GitHub 来源需要网络及 CLI 可用的 Git 环境；ZIP 提供本地市场。组织策略可能限制第三方插件，不应绕过。

## GitHub 安装

```powershell
claude plugin marketplace add Gongkddz/claude-turn-notify
claude plugin install turn-notify@claude-turn-notify --scope user
claude plugin list --json
```

检查每步退出码和目标 scope、enabled 状态。默认 `user`；用户明确需要时选 `project` 或 `local`，后续保持一致。Project 会影响共享项目配置。

## Release ZIP 安装

从 [Releases](https://github.com/Gongkddz/claude-turn-notify/releases/latest) 下载 ZIP 和 `SHA256SUMS.txt`。用 `Get-FileHash ./claude-turn-notify-1.0.0-windows.zip -Algorithm SHA256` 对照校验文件。**完整解压**，保留 `.claude-plugin` 和 `plugins`。

双击 `install.cmd`，或让 agent 在解压目录执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./install.ps1 -Source Local
```

安装器将插件复制到 `%LOCALAPPDATA%\ClaudeTurnNotify\marketplace\<version>`，然后调用官方 CLI 注册并安装。安装后可以移除下载和解压目录。执行策略 Bypass 只作用于这次进程；脚本不更改系统策略，不手动覆盖 settings.json。

参数：`-Source Auto|Local|GitHub`、`-Scope user|project|local`、`-CheckOnly`。Auto 在完整包内选 Local，单独脚本选 GitHub；CheckOnly 只检查系统与 CLI，不更改配置，也不验证可见通知。

## 首次使用与验证

开一个**新的 Claude Code 会话**。输入 `/turn-notify:status`；若为 off，输入 `/turn-notify:on`。用 `/turn-notify:test` 检查示例 Toast 和提示音，再正常完成一轮回答。测试命令本身回答结束时也可能触发正常 Stop 通知。

| Command | Purpose |
| --- | --- |
| `/turn-notify:on` | 开启 |
| `/turn-notify:off` | 静音 |
| `/turn-notify:status` | 查看开关 |
| `/turn-notify:test` | 开关开启时发送示例通知 |
| `/turn-notify:help` | 使用与排障 |

安装注册、脚本成功退出和“看到了通知”是不同结果。显示受 Windows 权限、勿扰模式/专注助手、音量及桌面会话影响。约 3 秒内连续 Stop 合并，同一时刻不同会话独立。

## 更新

GitHub 来源运行：

```powershell
claude plugin marketplace update claude-turn-notify
claude plugin update turn-notify@claude-turn-notify
```

ZIP 来源先下载新版。若本地市场指向旧版目录，按下述步骤切换到新版。更新后开新会话。单纯 marketplace update 不会从 GitHub 下载本地 ZIP 来源的新文件。

## 切换安装来源

用 `claude plugin marketplace list` 核对来源。若已经是所需来源，继续安装。若在 GitHub 与 ZIP 之间切换，或换到新版 ZIP 目录，先核对插件 scope，再运行：

```powershell
claude plugin uninstall turn-notify@claude-turn-notify --scope user
claude plugin marketplace remove claude-turn-notify
```

然后运行目标来源的安装步骤。此操作只针对明确要切换的 `claude-turn-notify`。Project/local 安装匹配 scope；多个 scope 有安装时先逐一确认。安装器遇到同名来源冲突会报错，保留现有来源。

## 没有通知或声音

- 检查新会话、插件 enabled、通知开关、Claude Code hooks 是否被禁用。
- 检查 Windows「设置 → 系统 → 通知」和勿扰模式/专注助手；回退通知可能归属 Windows PowerShell。
- 检查音量、输出设备和 `%WINDIR%\Media\Windows Notify System Generic.wav`。
- 使用原生 Windows 桌面。WSL、SSH、服务进程或无交互桌面不适用。
- 数据在 `~/.claude/turn-notify` 或 `CLAUDE_CONFIG_DIR/turn-notify`。`notify.log` 的 `sound-played-ok` 表示播放调用完成；`toast-submitted-ok` / `toast-submitted-fallback-ok` 表示 API 接受提交，不能证明用户看见或听见。`toast-error` / `worker-error` 记录失败。
- `pending-*.txt` 留存最近的待处理摘要。摘要也可能出现在锁屏和通知历史中。日志只记录技术状态；分享信息时不要上传私人内容或完整会话记录。

## 卸载

```powershell
claude plugin uninstall turn-notify@claude-turn-notify --scope user
```

若不再需要市场，可运行 `claude plugin marketplace remove claude-turn-notify`。开新会话停止加载旧 hook。通知开关、日志、pending 和本地 ZIP 市场不会自动清除，用户确认后可自行删除。

## 官方参考

[Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) · [Manifest reference](https://code.claude.com/docs/en/plugins-reference) · [Hooks reference](https://code.claude.com/docs/en/hooks)
