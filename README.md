# Codex Clean Rebuild Kit

This repository is a clean rebuild kit for the Windows Codex desktop app.

目标：把 Codex 的可复用配置固定到英文路径，清理当前可能损坏的中文/乱码用户路径、半安装 runtime、旧 junction 和残留数据，然后重新安装 Codex，并用脚本恢复一个干净环境。

## What This Kit Does

Recommended clean paths:

- `F:\CodexClean\Home`: target for `%USERPROFILE%\.codex`
- `F:\CodexClean\Runtime`: target for `%LOCALAPPDATA%\OpenAI\Codex\runtimes`
- `F:\CodexClean\Projects`: recommended location for future Codex workspaces
- `F:\CodexClean\Backups`: local backups before deletion

Important: do not junction `%USERPROFILE%\Documents\Codex` by default. Codex can reject a projectless thread directory when that path is not a normal directory. Keep it as a real directory and put new working projects under `F:\CodexClean\Projects`.

## Uploaded Files

Safe files included in this repo:

- `README.md`: full reinstall instructions
- `docs/`: path policy and recovery notes
- `templates/config.toml`: clean Codex config template
- `scripts/00_audit_current_codex.ps1`: inspect current Codex paths and package state
- `scripts/01_backup_current_codex.ps1`: local backup before cleanup
- `scripts/02_uninstall_clean_codex.ps1`: dry-run or execute cleanup
- `scripts/03_rebuild_clean_codex.ps1`: create clean English-path junctions and config
- `scripts/04_verify_clean_codex.ps1`: verify package, junctions, runtime, and config
- `scripts/99_one_click_clean_codex.ps1`: one command wrapper for audit, backup, cleanup, rebuild

Not uploaded intentionally:

- auth/session/token files
- logs and conversation history
- runtime binaries
- plugin cache directories
- browser local storage/session storage
- SQLite databases

These can contain account state, personal history, tokens, or very large/generated files.

## Clean Reinstall Workflow

Run PowerShell as Administrator.

1. Clone or download this repo.

```powershell
git clone https://github.com/ZHANGYANG6666/codex-clean-kit.git F:\CodexCleanKit
cd F:\CodexCleanKit
```

2. Close Codex completely.

Also close all `Codex.exe` processes in Task Manager if they remain.

3. Audit first.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\00_audit_current_codex.ps1
```

4. Back up local Codex data.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\01_backup_current_codex.ps1
```

5. Preview cleanup.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\02_uninstall_clean_codex.ps1 -IncludeStaleUserProfiles -RemoveAppPackage
```

6. Execute cleanup.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\02_uninstall_clean_codex.ps1 -Execute -IncludeStaleUserProfiles -RemoveAppPackage
```

7. Reinstall Codex from the official source or Microsoft Store.

8. Rebuild clean English-path config.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\03_rebuild_clean_codex.ps1 -Execute
```

9. Verify.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\04_verify_clean_codex.ps1
```

## One Command Option

Use this only after Codex is closed.

Dry run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\99_one_click_clean_codex.ps1 -IncludeStaleUserProfiles -RemoveAppPackage
```

Execute:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\99_one_click_clean_codex.ps1 -Execute -IncludeStaleUserProfiles -RemoveAppPackage
```

After that, reinstall Codex, then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\03_rebuild_clean_codex.ps1 -Execute
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\04_verify_clean_codex.ps1
```

## How To Tell Codex To Use English Paths

Codex desktop may still live under your Windows user profile, but the large/mutable data should be redirected:

- `%USERPROFILE%\.codex` is replaced with a junction to `F:\CodexClean\Home`
- `%LOCALAPPDATA%\OpenAI\Codex\runtimes` is replaced with a junction to `F:\CodexClean\Runtime`
- New projects should be created under `F:\CodexClean\Projects`

Do not use Chinese paths for future Codex project directories. Create a project folder like:

```powershell
mkdir F:\CodexClean\Projects\my-project
```

Then open that folder from Codex.

## Recovery Rule

If Codex is slow again after reinstall:

1. Run `scripts\04_verify_clean_codex.ps1`.
2. Check that `.codex` and `runtimes` are junctions to `F:\CodexClean`.
3. Check Chrome plugin status from Codex plugin UI and reinstall Chrome/Computer plugins if needed.
4. Do not move `Documents\Codex` into a junction unless Codex officially supports it.
