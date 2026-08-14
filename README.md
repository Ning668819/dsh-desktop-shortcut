# 🐋 DSH Desktop Shortcut

One-click desktop shortcut for [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) (DSH).

Double-click the shortcut → the `dsh web` server starts (if not already running) and your browser opens the DSH web UI automatically. The shortcut uses the official DSH whale icon.

> 中文说明见下方 [中文版](#中文版)

---

## ✨ Features

- **One click to the web UI** — double-click the desktop icon and your browser jumps to DSH
- **Auto-start server** — starts `dsh web` in a visible "DSH Server" console if it isn't running; closing that window stops the server
- **Idempotent** — clicking again while the server is up just reopens the browser; re-running the installer updates instead of failing
- **Toast notifications** — a Windows notification tells you what's happening (starting / ready / timed out) even though the launcher runs hidden
- **Official whale icon** — bundled `dsh.ico` generated from the official DSH favicon
- **OneDrive-safe** — resolves your real Desktop path, even when redirected
- **DSH skill included** — install it as a skill and any DSH agent can create the shortcut for you
- **Clean uninstall** — bundled `uninstall.ps1` removes the shortcut, skill, and launcher in one go
- **Versioned releases** — remote installs pull the latest [GitHub release](https://github.com/Ning668819/dsh-desktop-shortcut/releases), not random main-branch code
- **Windows only** — PowerShell 5.1+, ships with Windows 10/11

## 📦 Installation

### Option A — One-line remote install (recommended)

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Ning668819/dsh-desktop-shortcut/main/scripts/install.ps1 | iex"
```

Installs the skill and creates the desktop shortcut in one go.
The installer automatically fetches the **latest [release](https://github.com/Ning668819/dsh-desktop-shortcut/releases)** (falls back to `main` if none exists).

### Option B — Clone and run

```powershell
git clone https://github.com/Ning668819/dsh-desktop-shortcut.git
cd dsh-desktop-shortcut
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
```

### Option C — Install the skill only (no shortcut yet)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -SkipShortcut
```

Then in any DSH session, ask your agent: **"create a desktop shortcut for DSH"**.

### Option D — Just the shortcut, no install

```powershell
powershell -ExecutionPolicy Bypass -File scripts\create-shortcut.ps1
```

## 🚀 Usage

1. Double-click **`DSH 网页启动`** on your desktop.
2. If the server isn't running, a **"DSH Server"** console window opens — keep it open (closing it stops the server).
3. The browser opens `http://127.0.0.1:3080` automatically.

### Customize

```powershell
# different shortcut name
.\scripts\create-shortcut.ps1 -ShortcutName "My DSH"

# different port / URL
.\scripts\create-shortcut.ps1 -Url "http://127.0.0.1:8080" -Port 8080

# overwrite existing shortcut
.\scripts\create-shortcut.ps1 -Force
```

## 🗑️ Uninstall

Run the bundled uninstaller (or, if you used the remote install, run the
`uninstall.ps1` that was installed into your skill folder):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1
```

Removes the desktop shortcut, the installed skill folder, and the generated
launcher script. Add `-Yes` to skip the confirmation prompt, or `-RemoveRepo`
to also delete the local clone.

## 📁 Project layout

```
dsh-desktop-shortcut/
├── SKILL.md                  # DSH skill definition (agent instructions)
├── scripts/
│   ├── install.ps1           # one-click installer (skill + shortcut)
│   ├── create-shortcut.ps1   # core shortcut creator (runnable standalone)
│   └── uninstall.ps1         # clean uninstaller (shortcut + skill + launcher)
├── assets/
│   ├── dsh.ico               # whale icon (multi-size, generated from official favicon)
│   └── dsh-logo.svg          # source SVG
└── LICENSE
```

## ❓ Troubleshooting

| Problem | Fix |
| --- | --- |
| `dsh` not found | Install DSH: `npm install -g @deepseek-ai/dsh`, or add it to PATH |
| Re-running says "already exists" | Since v1.1 the script updates an existing shortcut automatically; use `-Force` to overwrite explicitly |
| Icon doesn't update on desktop | Press `F5` or restart Explorer |
| Browser shows connection refused | The server failed to start — read the "DSH Server" console for the error |

## 🧪 Verification

Run the script and confirm it prints `[ok]` lines, then double-click the new shortcut. The script is designed to be idempotent and safe to re-run.

## 📄 License

[MIT](LICENSE)

---

## 中文版

# 🐋 DSH 桌面快捷方式

为 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) (DSH) 一键创建桌面快捷方式。

双击快捷方式 → 自动启动 `dsh web`（如未运行）并打开浏览器跳转到 DSH 网页，图标使用官方黑鲸鱼。

## ✨ 功能

- **一键跳转网页** — 双击桌面图标，浏览器自动打开 DSH 页面
- **自动启动服务器** — 未运行时自动开一个 "DSH Server" 控制台窗口启动 `dsh web`；关闭该窗口即停止服务器
- **可重复点击** — 服务器已运行时再次双击只是重新打开浏览器；重复安装也会自动更新而不是报错
- **系统通知反馈** — 启动、就绪、超时都会弹出 Windows 通知，不会干等无反馈
- **官方鲸鱼图标** — 内置 `dsh.ico`（由官方 favicon 生成，含多尺寸）
- **兼容 OneDrive 桌面重定向**
- **自带 DSH skill** — 安装为 skill 后，DSH 助手可以帮你创建快捷方式
- **一键卸载** — 内置 `uninstall.ps1`，一次清理快捷方式 + skill + 启动脚本
- **版本化发布** — 远程安装自动拉取最新 [GitHub Release](https://github.com/Ning668819/dsh-desktop-shortcut/releases)，不是随机的 main 分支代码
- **仅支持 Windows** — 需要 PowerShell 5.1+（Win10/11 自带）

## 📦 安装

### 方式 A — 一行远程安装（推荐）

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Ning668819/dsh-desktop-shortcut/main/scripts/install.ps1 | iex"
```

一次完成 skill 安装 + 桌面快捷方式创建。
安装器会自动获取**最新 [Release](https://github.com/Ning668819/dsh-desktop-shortcut/releases)**（没有 Release 时回退到 main）。

### 方式 B — 克隆后运行

```powershell
git clone https://github.com/Ning668819/dsh-desktop-shortcut.git
cd dsh-desktop-shortcut
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
```

### 方式 C — 只装 skill（暂不创建快捷方式）

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -SkipShortcut
```

之后在任意 DSH 会话中对助手说：**"帮我创建 DSH 桌面快捷方式"**。

### 方式 D — 只创建快捷方式

```powershell
powershell -ExecutionPolicy Bypass -File scripts\create-shortcut.ps1
```

## 🚀 使用方法

1. 双击桌面上的 **`DSH 网页启动`**。
2. 如果服务器未运行，会弹出 **"DSH Server"** 控制台窗口——保持它开着（关闭即停止服务器）。
3. 浏览器自动打开 `http://127.0.0.1:3080`。

### 自定义

```powershell
# 改快捷方式名称
.\scripts\create-shortcut.ps1 -ShortcutName "我的DSH"

# 改端口 / 网址
.\scripts\create-shortcut.ps1 -Url "http://127.0.0.1:8080" -Port 8080

# 覆盖已有快捷方式
.\scripts\create-shortcut.ps1 -Force
```

## 🗑️ 卸载

运行内置卸载脚本（远程安装的用户，直接运行 skill 目录里的 `uninstall.ps1` 即可）：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1
```

会删除：桌面快捷方式、已安装的 skill 目录、生成的启动脚本。加 `-Yes` 跳过确认，加 `-RemoveRepo` 可连本地克隆一起删除。

## 📁 项目结构

```
dsh-desktop-shortcut/
├── SKILL.md                  # DSH skill 定义（agent 指令）
├── scripts/
│   ├── install.ps1           # 一键安装器（skill + 快捷方式）
│   ├── create-shortcut.ps1   # 核心创建脚本（可单独运行）
│   └── uninstall.ps1         # 一键卸载（快捷方式 + skill + 启动脚本）
├── assets/
│   ├── dsh.ico               # 鲸鱼图标（多尺寸，由官方 favicon 生成）
│   └── dsh-logo.svg          # 源 SVG
└── LICENSE
```

## ❓ 常见问题

| 问题 | 解决 |
| --- | --- |
| 找不到 `dsh` 命令 | 先安装 DSH：`npm install -g @deepseek-ai/dsh`，或加入 PATH |
| 重复运行提示已存在 | v1.1 起脚本会自动更新已有快捷方式；想强制覆盖加 `-Force` |
| 桌面图标没变 | 按 `F5` 刷新，或重启资源管理器 |
| 浏览器提示无法连接 | 服务器启动失败——查看 "DSH Server" 控制台里的报错 |

## 🧪 验证

运行脚本并确认输出 `[ok]` 信息，然后双击新快捷方式测试。脚本可重复运行，安全无副作用。

## 📄 许可证

[MIT](LICENSE)
