# Restore After Reinstall

1. Install Codex.
2. Do not open a large old project first.
3. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File F:\CodexCleanKit\scripts\03_rebuild_clean_codex.ps1 -Execute
powershell -NoProfile -ExecutionPolicy Bypass -File F:\CodexCleanKit\scripts\04_verify_clean_codex.ps1
```

4. Start Codex.
5. Open or create projects under:

```text
F:\CodexClean\Projects
```

6. Reinstall required plugins from the Codex plugin UI if browser control or computer-use is unavailable.

Do not restore old `sessions`, `logs`, `runtimes`, `plugins/cache`, `Local Storage`, or `Session Storage` into the clean home.
