# Codex Path Policy

Use English-only paths for Codex data that can grow or be regenerated.

## Recommended

- `F:\CodexClean\Home`
- `F:\CodexClean\Runtime`
- `F:\CodexClean\Projects`
- `F:\CodexClean\Backups`
- `F:\CodexCleanKit`

## Avoid

- Chinese user-profile paths for runtime or project storage
- Garbled profile paths such as stale folders under `C:\Users`
- Junctioning `%USERPROFILE%\Documents\Codex`
- Putting runtime binaries in GitHub
- Uploading `.codex` wholesale to GitHub

## Why Documents\Codex Is Special

Codex may require the projectless thread directory to be a real directory. If it is changed to a junction, startup or task creation can fail with:

`Projectless thread directory must be a real directory`

Therefore this kit keeps `%USERPROFILE%\Documents\Codex` as a normal directory and redirects only:

- `%USERPROFILE%\.codex`
- `%LOCALAPPDATA%\OpenAI\Codex\runtimes`
