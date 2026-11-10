---
description: 发送一条示例桌面通知并播放提示音 / Test the desktop notification
---
Run the following command to send a sample toast using the current notification switch. If the switch is off, explain how to enable it with /turn-notify:on. A successful process exit does not prove that the toast was visible; ask the user whether they saw it only if diagnosing a notification issue.

!`powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/turn-notify.ps1" -Preview`
