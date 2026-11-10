
<p align="center"><img src="docs/assets/hero.svg" alt="turn-notify — Step away. Know when Claude is done." width="100%"></p>

<p align="center">
  <a href="https://github.com/Gongkddz/claude-turn-notify/releases/latest"><img alt="Latest release v1.0.0" src="https://img.shields.io/badge/release-v1.0.0-38bda5?style=flat-square"></a>
  <a href="LICENSE"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-8b98b5?style=flat-square"></a>
  <img alt="Windows 10 / 11" src="https://img.shields.io/badge/Windows-10%20%2F%2011-6aa9ff?style=flat-square">
  <img alt="Claude Code plugin" src="https://img.shields.io/badge/Claude_Code-plugin-d59a79?style=flat-square">
</p>

<p align="center"><strong>Claude 回答完，桌面提醒你。</strong><br>原生 Windows 通知 · 回答摘要 · 系统提示音 · 本地运行</p>

<p align="center">
  <a href="#让-agent-帮你装">让 agent 帮你装</a> ·
  <a href="https://github.com/Gongkddz/claude-turn-notify/releases/latest">下载安装包</a> ·
  <a href="docs/INSTALL.md">安装指南</a> ·
  <a href="docs/README.en.md">English</a> ·
  <a href="AGENTS.md">For agents</a>
</p>

---

等待 Claude Code 完成任务时，可以切去做别的事。`turn-notify` 会在回答结束约 3 秒后播放提示音，并在 Windows 通知中显示一小段回答。它使用 Claude Code 原生插件系统安装，无需手动编辑 hook 或复制配置。

## 让 agent 帮你装

把下面这段话发给**运行在你 Windows 电脑上、有终端权限的 agent**：

```text
请帮我安装 https://github.com/Gongkddz/claude-turn-notify
先阅读仓库的 AGENTS.md，检查环境，用 Claude Code 原生插件方式安装，
验证安装结果，然后用中文教我开启、关闭和测试通知。
```

Agent 可以读取 [AGENTS.md](AGENTS.md)、[纯文本入口 llms.txt](llms.txt) 和[安装指南](docs/INSTALL.md)，检查系统、执行安装、核对结果并说明用法。网页聊天里的 agent 如果不能操作本机，仍需要在你的电脑上执行安装命令。

<details>
<summary><strong>想自己安装？复制这两条命令。</strong></summary>

在 PowerShell 中运行：

```powershell
claude plugin marketplace add Gongkddz/claude-turn-notify
claude plugin install turn-notify@claude-turn-notify --scope user
```

随后打开一个**新的 Claude Code 会话**。运行 `/turn-notify:status` 查看开关，再运行 `/turn-notify:test` 测试桌面通知。

</details>

## 下载后直接安装

**[下载 Windows 安装包 ZIP →](https://github.com/Gongkddz/claude-turn-notify/releases/latest/download/claude-turn-notify-1.0.0-windows.zip)**

完整解压 ZIP，双击 `install.cmd`，再打开新的 Claude Code 会话。安装包内包含完整插件、安装脚本和说明；使用系统自带 PowerShell，无需编译、额外 Python/Node 运行库或管理员权限。**电脑需已安装 Claude Code CLI**。

安装器将本地市场保存在 `%LOCALAPPDATA%\ClaudeTurnNotify\marketplace\1.0.0`，安装后可移除下载和解压目录。下载和 GitHub 安装需要联网，通知脚本本身不联网。已有同名市场时，安装器保留来源检查；切换来源见[安装指南](docs/INSTALL.md#切换安装来源)。

## 小功能，刚刚好

| 能力 | 具体行为 |
| :--- | :--- |
| 桌面通知 | 显示 Claude Code 和最后回答的摘要 |
| 听得见的提醒 | Windows 自带提示音；Toast 本身静音，避免重复播放 |
| 适度的摘要 | 清理常见 Markdown，最多约 90 个字符 |
| 合并连续触发 | 同一会话 3 秒内连续 Stop 保留最后一次，会话间独立 |
| 随时静音 | 开关保存在本机，后续会话继续沿用 |
| Agent 友好 | 标准市场清单、明确操作步骤、纯文本入口、内置帮助 |

## 五个命令

| 在 Claude Code 中输入 | 作用 |
| :--- | :--- |
| `/turn-notify:on` | 开启通知 |
| `/turn-notify:off` | 关闭通知 |
| `/turn-notify:status` | 查看通知开关 |
| `/turn-notify:test` | 发送示例通知并播放提示音，遵循当前开关 |
| `/turn-notify:help` | 使用说明、更新、卸载和故障排查 |

## 环境与隐私

- **原生 Windows 10 / 11、Windows PowerShell 5.1、支持插件的 Claude Code 2.x。** 本次在 Windows 和 Claude Code 2.1.319 上完成安装与脚本验证。Windows 10 的实际显示及其他 CLI 版本仍需对应环境验证。
- 需要交互式 Windows 桌面；WSL、macOS、Linux、无桌面服务器不在支持范围内。
- 通知权限、勿扰模式/专注助手、音量和输出设备会影响显示与声音。系统控制通知位置与历史记录，安装成功不代表桌面已显示通知。
- 通知脚本不发送网络请求，无遥测。安装与更新由 Claude Code/GitHub 完成，沿用其网络行为。
- 数据目录为 `%USERPROFILE%\.claude\turn-notify\`；设置 `CLAUDE_CONFIG_DIR` 时使用其下的 `turn-notify`。包含 `state.txt` 开关、`notify.log` 滚动日志（约 1 MB 后轮换一次）和每个会话的 `pending-*.txt`。
- **摘要会保存在本地 pending 文件，也可能出现在锁屏和 Windows 通知历史中。** 日志只记技术状态，不记录回答正文、会话路径或 ID。缺少有效会话来源时使用通用提示。

## 更新与卸载

GitHub 安装：

```powershell
claude plugin marketplace update claude-turn-notify
claude plugin update turn-notify@claude-turn-notify
```

ZIP 安装：下载新版本并运行安装器，按[切换来源说明](docs/INSTALL.md#切换安装来源)更新本地市场。更新后打开新会话。

卸载用户级插件：

```powershell
claude plugin uninstall turn-notify@claude-turn-notify --scope user
```

卸载不会自动删除通知数据目录。项目级安装需匹配 `--scope project` 或 `--scope local`。

## 开发与打包

项目由 PowerShell 脚本与插件清单组成，没有第三方运行库。克隆后执行：

```powershell
claude plugin validate .
claude plugin validate ./plugins/turn-notify
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./scripts/build-release.ps1
```

安装包和 SHA-256 校验文件生成在 `dist/`，不进入源码仓库。打包显式选择分发文件并保留隐藏的 `.claude-plugin`。通知逻辑见 [turn-notify.ps1](plugins/turn-notify/scripts/turn-notify.ps1)，协作见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可与致谢

原创代码按 [MIT](LICENSE) 开源。使用 [Claude Code 插件与市场接口](https://code.claude.com/docs/en/plugin-marketplaces)、[Stop hook](https://code.claude.com/docs/en/hooks#stop)及 Windows 通知和声音 API，详见[第三方说明](THIRD_PARTY_NOTICES.md)。这是独立社区项目。
