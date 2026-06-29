<div align="center">

# ⚙️ DevKit

**One command to set up your entire developer environment.**  
An interactive, menu-driven CLI installer for WSL 2 — with smart detection, official package sources, and a clean terminal UI.

<br/>

[![Platform](https://img.shields.io/badge/platform-WSL%202-0078D4?logo=windows&logoColor=white)](https://learn.microsoft.com/en-us/windows/wsl/)
[![Distro](https://img.shields.io/badge/distro-Ubuntu%20%7C%20Debian-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-22c55e)](./LICENSE)
[![ShellCheck](https://img.shields.io/badge/shellcheck-passing-22c55e)](https://www.shellcheck.net/)
[![Tools](https://img.shields.io/badge/tools-8_supported-8b5cf6)]()
[![Version](https://img.shields.io/badge/version-v1.0.0-0ea5e9)]()

<br/>

```bash
curl -fsSL https://raw.githubusercontent.com/AnkushUjawane/DevKit/main/install.sh | bash
```

</div>

---

## 📖 Table of Contents

- [Why DevKit](#-why-devkit)
- [Quick Start](#-quick-start)
- [Supported Tools](#-supported-tools)
- [How It Works](#-how-it-works)
- [After Installation](#-after-installation)
- [Docker on WSL 2](#-docker-on-wsl-2)
- [Project Structure](#-project-structure)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## 💡 Why DevKit

Every developer setting up a new machine faces the same problem: spending hours installing tools one by one, each from a different website, each with its own instructions. A wrong command, a deprecated repo, a missing dependency — and you're debugging before you've written a single line of code.

DevKit solves that with a single command. Run it, pick your tools from an interactive menu, and walk away. Every installer uses the official source for that tool — no outdated PPAs, no third-party mirrors.

---

## 🚀 Quick Start

### ⚡ Option 1 — One-line install (recommended)

Installs the `devkit` command permanently on your system.

```bash
curl -fsSL https://raw.githubusercontent.com/AnkushUjawane/DevKit/main/install.sh | bash
```

Then reload your shell and launch:

```bash
source ~/.bashrc
devkit
```

After that, you can run `devkit` from anywhere, anytime.

### 🔧 Option 2 — Manual (clone & run directly)

```bash
git clone https://github.com/AnkushUjawane/DevKit.git
cd DevKit
chmod +x devsetup.sh
./devsetup.sh
```

> **Requirements:** WSL 2 with Ubuntu 20.04, 22.04, or 24.04 (or any Debian-based distro). `curl` and `bash` are pre-installed on all of these.

---

## 📦 Supported Tools

| # | Tool | Installs | Source |
|---|------|----------|--------|
| 1 | 🐳 **Docker** | Docker Engine, CLI, Containerd, Compose plugin | [docker.com](https://docs.docker.com/engine/install/ubuntu/) apt repo |
| 2 | 🐍 **Python 3** | python3, pip3, venv | Ubuntu apt |
| 3 | 🟩 **Node.js** | Node.js LTS + npm | [NodeSource](https://github.com/nodesource/distributions) apt repo |
| 4 | 🔵 **Git** | Latest stable git | Ubuntu apt |
| 5 | 🐹 **Go** | Latest stable binary | [go.dev](https://go.dev/dl/) official |
| 6 | 🦀 **Rust** | rustc + cargo | [rustup.rs](https://rustup.rs/) |
| 7 | 💻 **VS Code CLI** | `code` command, tunnel support | [Microsoft](https://code.visualstudio.com/docs/editor/command-line) official |
| 8 | ☸️ **kubectl + Helm** | kubectl v1.30, Helm v3 | [k8s.io](https://kubernetes.io/docs/tasks/tools/) + [Helm](https://helm.sh/docs/intro/install/) apt repos |

> Each tool is installed from its **official source** only — no third-party mirrors, no outdated PPAs.

---

## 🎬 How It Works

### The menu

When you run `devkit`, an interactive menu appears in your terminal. Type a number to toggle a tool on or off. Tools already installed on your system are detected automatically and shown at the bottom — they will be skipped if selected.

```
╔══════════════════════════════════════════════╗
║    ⚙️  DevKit — Dev Environment Setup        ║
║       Ubuntu/Debian (apt) · WSL 2            ║
╚══════════════════════════════════════════════╝

  Select tools to install:
  Enter number to toggle · A = All · N = None · I = Install · Q = Quit

  [✔] 1. Docker Engine + Compose
  [ ] 2. Python 3 + pip
  [✔] 3. Node.js LTS + npm
  [ ] 4. Git
  [✔] 5. Go (latest)
  [✔] 6. Rust (via rustup)
  [ ] 7. VS Code CLI
  [✔] 8. kubectl + Helm

  Already installed on your system: Git Python3

  → I
```

### Installation output

```
  ▸ Docker Engine + Compose
  ──────────────────────────────────────────────────
  ℹ  Adding Docker's official GPG key and repo...
  ✔  Docker installed → Docker version 27.x.x
  ✔  Docker Compose installed → Docker Compose version v2.x.x
  ⚠  WSL tip: Run 'newgrp docker' or restart WSL to use Docker without sudo.

  ▸ Go (latest)
  ──────────────────────────────────────────────────
  ℹ  Fetching latest Go version...
  ℹ  Downloading go1.23.x...
  ✔  Go installed → go version go1.23.x linux/amd64
  ℹ  PATH updated in ~/.bashrc and ~/.profile
```

### Summary

```
  ╔══════════════════════════════════════════════╗
  ║             Installation Summary             ║
  ╚══════════════════════════════════════════════╝

  ✔  Docker    → Docker version 27.x.x
  ✔  Node.js   → v22.x.x
  ✔  Go        → go1.23.x
  ✔  Rust      → rustc 1.8x.x
  ✔  kubectl   → installed
  ✔  Helm      → v3.x.x

  → Run: source ~/.bashrc  (or restart terminal)
  → For Docker without sudo: newgrp docker

  ✔  Setup complete! Happy coding 🚀
```

### How `install.sh` works

When you run the one-line curl command:

1. `curl` fetches `install.sh` from GitHub and pipes it to `bash`
2. `install.sh` downloads `devsetup.sh` to `~/.local/bin/devkit`
3. Sets `chmod +x` so it's executable
4. Adds `~/.local/bin` to your `$PATH` in `~/.bashrc` if not already there
5. From then on, `devkit` is available from anywhere in your terminal

---

## 🔧 After Installation

```bash
# Reload shell config — required for Go and Rust to be in PATH
source ~/.bashrc

# Use Docker without sudo
newgrp docker

# Verify all tools are installed correctly
docker --version
python3 --version && pip3 --version
node --version && npm --version
git --version
go version
rustc --version && cargo --version
code --version
kubectl version --client
helm version --short
```

---

## 🐳 Docker on WSL 2

Docker Engine runs natively inside WSL 2, but the daemon needs to be started manually since WSL doesn't use systemd by default.

```bash
# Start the Docker daemon
sudo service docker start

# Optional: auto-start every time you open a terminal
echo 'sudo service docker start > /dev/null 2>&1' >> ~/.bashrc
```

> **Alternative:** Install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) and enable the WSL 2 backend — it manages the daemon automatically and integrates cleanly with WSL.

---

## 📁 Project Structure

```
DevKit/
├── devsetup.sh               ← Interactive menu installer (main script)
├── install.sh                ← curl | bash entry point — installs devkit permanently
├── README.md
├── LICENSE
├── .gitignore
└── .github/
    ├── workflows/
    │   └── shellcheck.yml    ← Lints all scripts on every push/PR
    └── ISSUE_TEMPLATE/
        └── bug_report.md
```

---

## 🗺️ Roadmap

### ✅ v1.0.0 — Bash CLI (current)
- [x] Interactive menu-based installer for WSL 2
- [x] 8 tools from official sources
- [x] Smart detection — skips already-installed tools
- [x] `curl | bash` one-line install via `install.sh`
- [x] ShellCheck validated, zero warnings
- [x] GitHub Actions CI on every push

### 🔄 v2.0.0 — npm CLI (next)
- [ ] Rebuild as a Node.js + TypeScript package
- [ ] Terminal UI powered by [Ink](https://github.com/vadimdemedes/ink) (React for CLI)
- [ ] Cross-platform: Linux, macOS, WSL, Windows
- [ ] `npx devkit` — works with zero pre-install
- [ ] Publish to npm

### 🤖 v3.0.0 — AI Assistant
- [ ] Built-in Claude AI that watches your install output
- [ ] When an error occurs → AI explains it and suggests a fix, live in the terminal
- [ ] `[Run this fix?]` prompt — apply the AI's suggestion in one keypress
- [ ] Chat mode: ask questions about any tool directly in the terminal

### 🌐 v4.0.0 — Profiles & Community
- [ ] Save your tool selection as a named profile (`devkit save my-stack`)
- [ ] Share profiles as a `devkit.yaml` file
- [ ] Plugin system — community-contributed tools
- [ ] Update manager — detect and update installed tools

---

## 🤝 Contributing

Contributions are welcome. To add a new tool:

1. Fork the repo and create a branch: `git checkout -b feat/add-toolname`
2. Add the tool name to the `TOOLS[]` array in `devsetup.sh`
3. Write an `install_<toolname>()` function following the existing pattern
4. Wire it into `main()` with `[[ ${SELECTED[N]} -eq 1 ]] && install_<toolname>`
5. Run `shellcheck devsetup.sh` — must pass with zero warnings
6. Open a Pull Request with a short description

For bugs, use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md).

---

## 📄 License

MIT — see [LICENSE](./LICENSE)

---

<div align="center">
  <sub>Built by <a href="https://github.com/AnkushUjawane">Ankush Ujawane</a> · For developers tired of setting up the same tools on every new machine.</sub>
</div>
