# Codex Clean Rebuild Kit

目标：把 Codex 的可复用配置迁移到英文路径，清理当前混乱的中文/乱码路径、半安装 runtime、残留 junction，然后重新安装并用脚本恢复一个干净环境。

推荐英文路径：

- `F:\CodexClean\Home`：新的 `.codex` 目录目标
- `F:\CodexClean\Runtime`：Codex runtime 目标
- `F:\CodexClean\Projects`：以后新建 Codex 项目/输出目录
- `F:\CodexClean\Backups`：清理前备份

## 为什么不直接把所有东西上传 GitHub

不要把完整 `.codex`、Roaming/Local app data、日志、会话、token、历史线程原样上传 GitHub。里面可能包含账号状态、历史对话、个人路径、插件缓存、临时文件和敏感配置。

GitHub 只建议上传：

- 本目录 `CodexCleanKit`
- `README.md`
- `scripts/*.ps1`
- 清理后的配置模板
- skills 清单或你确认可公开的自定义 skills

不建议上传：

- `auth*`
- `sessions`
- `logs`
- `history`
- `*.db`
- `*.sqlite`
- `Local Storage`
- `Session Storage`
- `runtimes`
- `plugins/cache`
- 含 token/key/cookie 的文件

## 使用顺序

1. 关闭 Codex。
2. 以管理员 PowerShell 运行备份：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\01_backup_current_codex.ps1
```

3. 先预览清理项：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\02_uninstall_clean_codex.ps1
```

4. 确认后执行清理：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\02_uninstall_clean_codex.ps1 -Execute
```

5. 重新下载安装 Codex。
6. 运行干净重建：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\03_rebuild_clean_codex.ps1 -Execute
```

## 当前建议

先不要急着上传 GitHub。先用这套脚本在本机完成干净重建，确认 Codex 启动正常、浏览器控制正常后，再把 `CodexCleanKit` 上传到 GitHub 私有仓库。

