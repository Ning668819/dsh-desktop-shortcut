---
name: dsh-desktop-shortcut
description: Create a one-click desktop shortcut for DeepSeek Harness that starts the dsh web server (if needed) and opens the browser to the web UI, using the DSH whale icon. Use this skill whenever the user wants a desktop icon to launch DSH, wants to jump to the DSH web page with one click, or asks to install this shortcut tool.
whenToUse: The user wants a desktop shortcut/icon for DeepSeek Harness, wants one-click access to the DSH web UI, or asks to install/set up this desktop shortcut tool.
---

# DSH Desktop Shortcut

Create a desktop shortcut that, when double-clicked, starts the `dsh web` server (if it is not already running) and opens the default browser at the DeepSeek Harness web UI. The shortcut uses the official DSH whale icon.

## Locating the scripts

This skill is a directory bundle. The helper scripts live in the `scripts/`
subdirectory of this skill's own directory. Resolve the skill directory first
(typically `<DSH_HOME or ~/.dsh>/skills/dsh-desktop-shortcut`), then run the
scripts from there. Do not rely on `$PSScriptRoot` expanding inside this
markdown — substitute the real path.

## Quickest path

Run the bundled installer directly (it installs the skill and creates the shortcut):

```powershell
powershell -ExecutionPolicy Bypass -File "<SKILL_DIR>\scripts\install.ps1"
```

This is the recommended first action when the user asked to "install" or "set up" the shortcut.

## Standard workflow (create the shortcut only)

1. Run the core script with the default settings:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "<SKILL_DIR>\scripts\create-shortcut.ps1"
   ```
2. The script:
   - Verifies the `dsh` command exists on PATH (fails with a clear message if not).
   - Resolves the real Desktop path, including OneDrive redirection.
   - Generates a launcher script at `<DSH_HOME or ~/.dsh>\start-web.ps1` that
     checks port 3080, starts `dsh web` in a visible "DSH Server" console
     window when needed, waits for the server, and opens the browser.
   - Creates `DSH 网页启动.lnk` on the Desktop pointing at that launcher,
     using `assets\dsh.ico` (the whale icon) bundled in this skill.
   - Refreshes the Windows icon cache.

## Customization

The script accepts parameters; pass them through when the user asks for
different behavior:

```powershell
# different shortcut name
powershell -ExecutionPolicy Bypass -File "<SKILL_DIR>\scripts\create-shortcut.ps1" -ShortcutName "My DSH"

# different port/URL (e.g. custom --port from dsh web)
powershell -ExecutionPolicy Bypass -File "<SKILL_DIR>\scripts\create-shortcut.ps1" -Url "http://127.0.0.1:8080" -Port 8080

# overwrite an existing shortcut without prompting
powershell -ExecutionPolicy Bypass -File "<SKILL_DIR>\scripts\create-shortcut.ps1" -Force
```

## What to tell the user after success

- Double-click **"DSH 网页启动"** on the desktop to start DSH and open the page.
- If the server was not running, a console window titled **"DSH Server"** opens
  and stays open; **closing it stops the server**.
- Clicking the shortcut again while the server is already running just reopens
  the browser.
- To change the shortcut name, URL, or port, re-run with the parameters above
  (add `-Force` to overwrite).

## Failure handling

- `dsh` not found on PATH → tell the user to install DeepSeek Harness
  (`npm install -g @deepseek-ai/dsh`) or fix PATH, then re-run.
- Port already in use by another process → the launcher still opens the URL;
  the browser will show whatever is serving that port.
- Desktop is OneDrive-redirected → the script resolves the real Desktop
  automatically; no action needed.

## Notes

- Windows only; requires PowerShell 5.1+ (ships with Windows 10/11).
- The whale icon `assets\dsh.ico` was generated from the official DSH
  `favicon.svg` and is bundled here so no external tools are needed.
