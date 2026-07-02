<div align="center">

# DevKit

**One command to set up your entire developer environment.**
Interactive CLI installer with smart detection, official package sources, and AI-powered error fixing.

<br/>

[![npm](https://img.shields.io/npm/v/@ankushujawane/devkit?color=cb3837&logo=npm&logoColor=white)](https://www.npmjs.com/package/@ankushujawane/devkit)
[![npm downloads](https://img.shields.io/npm/dm/@ankushujawane/devkit?color=cb3837)](https://www.npmjs.com/package/@ankushujawane/devkit)
[![Platform](https://img.shields.io/badge/platform-WSL2%20%7C%20Linux%20%7C%20macOS-blue?logo=linux&logoColor=white)]()
[![License](https://img.shields.io/badge/license-MIT-22c55e)](./LICENSE)
[![ShellCheck](https://img.shields.io/badge/shellcheck-passing-22c55e)](https://www.shellcheck.net/)
[![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen?logo=node.js&logoColor=white)](https://nodejs.org)
[![Version](https://img.shields.io/badge/version-v2.0.0-8b5cf6)]()

<br/>

```bash
npx devkit-setup
```

</div>

---

## Table of Contents

- [Why DevKit](#-why-devkit)
- [Quick Start](#-quick-start)
- [Supported Tools](#-supported-tools)
- [How It Works](#-how-it-works)
- [After Installation](#-after-installation)
- [Project Structure](#-project-structure)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)

---

## Why DevKit

Every developer setting up a new machine faces the same problem — hours spent installing tools one by one, each from a different website, each with different instructions. A wrong command, a deprecated repo, a missing dependency, and you're debugging your environment before you've written a single line of code.

DevKit solves that. One command, pick your tools from an interactive menu, and walk away. Every installer uses the **official source** for that tool. No outdated PPAs, no third-party mirrors, no guesswork.

**Coming in v3.0:** A built-in AI assistant that watches your install output, catches errors as they happen, explains what went wrong, and suggests the exact fix — live in the terminal.

---

## Quick Start

### Run instantly (no install required)

```bash
npx devkit-setup
```

Node.js 18+ is the only requirement. Works on WSL 2, native Linux, and macOS.

### Install globally (run anytime as `devkit`)

```bash
npm install -g devkit-setup
devkit
```

### Legacy one-liner (bash only, WSL/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/AnkushUjawane/DevKit/main/install.sh | bash
```

---

## Supported Tools

| # | Tool | Installs | Source |
|---|------|----------|--------|
| 1 | **Docker** | Docker Engine, CLI, Containerd, Compose plugin | [docker.com](https://docs.docker.com/engine/install/ubuntu/) apt repo |
| 2 | **Python 3** | python3, pip3, venv | Ubuntu apt |
| 3 | **Node.js** | Node.js LTS + npm | [NodeSource](https://github.com/nodesource/distributions) apt repo |
| 4 | **Git** | Latest stable | Ubuntu apt |
| 5 | **Go** | Latest stable binary | [go.dev](https://go.dev/dl/) official |
| 6 | **Rust** | rustc + cargo | [rustup.rs](https://rustup.rs/) |
| 7 | **VS Code CLI** | `code` command + tunnel support | [Microsoft](https://code.visualstudio.com/docs/editor/command-line) official |
| 8 | **kubectl + Helm** | kubectl v1.30, Helm v3 | [k8s.io](https://kubernetes.io/docs/tasks/tools/) + [Helm](https://helm.sh/) apt repos |

Every tool is installed from its **official source only** — no third-party mirrors.

---

## How It Works

### The menu

When you run `devkit`, an interactive menu appears. Navigate with arrow keys, toggle tools with numbers or Space, then press `I` to install.

Tools already on your system are detected automatically and shown as `(installed)` — they will be skipped.

```
    ____             _    _ _
   |  _ \  _____   _| | _(_) |_
   | | | |/ _ \ \ / / |/ / | __|
   | |_| |  __/\ V /|   <| | |_
   |____/ \___| \_/ |_|\_\_|\__|
   Development Environment Setup

  ↑↓ navigate · Space/number toggle · A=All · N=None · I=Install · Q=Quit

  > [*] 1. Docker Engine + Compose
    [ ] 2. Python 3 + pip (installed)
    [*] 3. Node.js LTS + npm
    [ ] 4. Git (installed)
    [*] 5. Go (latest)
    [*] 6. Rust (via rustup)
    [ ] 7. VS Code CLI (installed)
    [*] 8. kubectl + Helm

  Already on your system:
  Python 3 + pip · Git · VS Code CLI

  5 tools selected — press I to install
```

### Live install output

```
  Installing 5 tools on wsl (apt)

  ⠋ Docker Engine + Compose
     Adding Docker official GPG key...
     Setting up repository...

  ✔ Go (latest)
  ✔ Rust (via rustup)
  o  kubectl + Helm       (waiting)
```

### Summary

```
  ╭─────────────────────────────╮
  │  Installation Complete      │
  │                             │
  │  ✔ 5 installed              │
  │  ⊘ 3 skipped               │
  │                             │
  │  Run source ~/.bashrc       │
  │  to pick up Go/Rust PATH    │
  ╰─────────────────────────────╯
```

### OS detection

DevKit automatically detects your environment and uses the right package manager:

| Environment | Package Manager | Status |
|---|---|---|
| WSL 2 / Ubuntu / Debian | `apt` | ✔ fully supported |
| macOS | `brew` | ✔ supported |
| Windows | `winget` | ✔ supported |
| Arch / Manjaro | `pacman` | coming soon |
| Fedora / RHEL | `dnf` | coming soon |

---

## After Installation

```bash
# Reload shell — required for Go and Rust PATH
source ~/.bashrc

# Use Docker without sudo (WSL — restart terminal after)
newgrp docker

# Verify all tools
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

### Docker on WSL 2

The Docker daemon needs to be started manually on WSL 2:

```bash
# Start daemon
sudo service docker start

# Auto-start on every terminal open
echo 'sudo service docker start > /dev/null 2>&1' >> ~/.bashrc
```

> Or install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) with the WSL 2 backend — it manages the daemon automatically.

---

## Project Structure

```
DevKit/
├── src/
│   ├── cli.tsx                  <- Entry point (npx @ankushujawane/devkit)
│   ├── tools.ts                 <- Central tool registry
│   ├── ui/
│   │   ├── Menu.tsx             <- Interactive Ink menu
│   │   └── Installer.tsx        <- Live progress + spinner UI
│   ├── installers/
│   │   └── index.ts             <- apt/brew/winget recipes via execa
│   └── utils/
│       └── os.ts                <- OS/env/pkg manager detection
├── devsetup.sh                  <- Legacy bash installer (v1)
├── install.sh                   <- curl | bash entry point (v1)
├── package.json
├── tsconfig.json
└── .github/
    └── workflows/
        ├── shellcheck.yml       <- Lint bash scripts on every push
        └── publish.yml          <- Auto-publish to npm on version tag
```

---

## Roadmap

### v1.0.0 — Bash CLI
- [x] Interactive menu-based installer for WSL 2
- [x] 8 tools from official sources
- [x] Smart skip detection
- [x] `curl | bash` one-line install
- [x] ShellCheck CI

### v2.0.0 — npm CLI (current)
- [x] Rebuilt in Node.js + TypeScript
- [x] Terminal UI with Ink (React for CLI)
- [x] Cross-platform: WSL 2, Linux, macOS, Windows
- [x] Live install output streaming via execa
- [x] `npx @ankushujawane/devkit` — zero pre-install
- [x] Auto-publish to npm via GitHub Actions

### v3.0.0 — AI Assistant (next)
- [ ] Built-in AI that watches install output in real time
- [ ] Error detected → AI explains it and suggests a fix instantly
- [ ] `[Run this fix?]` — apply the AI suggestion with one keypress
- [ ] Chat mode: ask questions about any tool directly in the terminal

### v4.0.0 — Profiles & Community
- [ ] Save tool selections as named profiles (`devkit save my-stack`)
- [ ] Share stacks as `devkit.yaml`
- [ ] Plugin system for community-contributed tools
- [ ] Update manager — detect and update installed tools

---

## Contributing

To add a new tool:

1. Fork and create a branch: `git checkout -b feat/add-toolname`
2. Add the tool to `TOOLS[]` in `src/tools.ts`
3. Add install recipes for `apt`, `brew`, and `winget` in `src/installers/index.ts`
4. Test locally: `npm run dev`
5. Open a Pull Request

For bugs, open an issue with your OS, environment, and the full error output.

---

## License

MIT — see [LICENSE](./LICENSE)

---

<div align="center">
  <sub>Built by <a href="https://github.com/AnkushUjawane">Ankush Ujawane</a> · For developers tired of setting up the same tools on every new machine.</sub>
</div>