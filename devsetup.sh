#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║           WSL Developer Environment Setup Script            ║
# ║     Tools: Docker · Python · Node · Go · Rust · more        ║
# ╚══════════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Colors & Styles ───────────────────────────────────────────
RED='\033[0;31m';    GREEN='\033[0;32m';  YELLOW='\033[1;33m'
BLUE='\033[0;34m';   CYAN='\033[0;36m';   BOLD='\033[1m'
DIM='\033[2m';       NC='\033[0m'

# ── Tool Registry ─────────────────────────────────────────────
TOOLS=(
  "Docker Engine + Compose"
  "Python 3 + pip"
  "Node.js LTS + npm"
  "Git"
  "Go (latest)"
  "Rust (via rustup)"
  "VS Code CLI"
  "kubectl + Helm"
)

declare -A SELECTED
for i in "${!TOOLS[@]}"; do SELECTED[$i]=0; done

# ── Helpers ───────────────────────────────────────────────────
log_info()    { echo -e "  ${BLUE}ℹ${NC}  $1"; }
log_ok()      { echo -e "  ${GREEN}✔${NC}  $1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${NC}  $1"; }
log_error()   { echo -e "  ${RED}✘${NC}  $1"; }
log_section() { echo -e "\n  ${CYAN}${BOLD}▸ $1${NC}"; echo -e "  ${DIM}$(printf '─%.0s' {1..50})${NC}"; }

is_installed() { command -v "$1" &>/dev/null; }

toggle() {
  [[ ${SELECTED[$1]} -eq 0 ]] && SELECTED[$1]=1 || SELECTED[$1]=0
}

# ── Menu ──────────────────────────────────────────────────────
print_banner() {
  clear
  echo -e "${CYAN}${BOLD}"
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║    🛠  WSL Dev Environment Setup  🛠           ║"
  echo "  ║       Ubuntu/Debian (apt) · WSL 2            ║"
  echo "  ╚══════════════════════════════════════════════╝"
  echo -e "${NC}"
}

show_menu() {
  print_banner
  echo -e "  ${BOLD}Select tools to install:${NC}"
  echo -e "  ${DIM}Enter number to toggle · A = All · N = None · I = Install · Q = Quit${NC}"
  echo ""

  for i in "${!TOOLS[@]}"; do
    local num=$((i + 1))
    if [[ ${SELECTED[$i]} -eq 1 ]]; then
      echo -e "  ${GREEN}[✔] $num. ${TOOLS[$i]}${NC}"
    else
      echo -e "  ${DIM}[ ] $num. ${TOOLS[$i]}${NC}"
    fi
  done

  # Show already-installed indicators
  echo ""
  echo -e "  ${DIM}Already installed on your system:${NC}"
  local found=()
  is_installed docker   && found+=("Docker")
  is_installed python3  && found+=("Python3")
  is_installed node     && found+=("Node")
  is_installed git      && found+=("Git")
  is_installed go       && found+=("Go")
  is_installed rustc    && found+=("Rust")
  is_installed code     && found+=("VSCode CLI")
  is_installed kubectl  && found+=("kubectl")
  is_installed helm     && found+=("Helm")

  if [[ ${#found[@]} -gt 0 ]]; then
    echo -e "  ${GREEN}${found[*]}${NC}"
  else
    echo -e "  ${DIM}(none detected)${NC}"
  fi

  echo ""
  echo -n "  → "
}

run_menu() {
  while true; do
    show_menu
    read -r choice
    case "$choice" in
      1|2|3|4|5|6|7|8) toggle $((choice - 1)) ;;
      [aA]) for i in "${!TOOLS[@]}"; do SELECTED[$i]=1; done ;;
      [nN]) for i in "${!TOOLS[@]}"; do SELECTED[$i]=0; done ;;
      [iI]) break ;;
      [qQ])
        echo -e "\n  ${YELLOW}Bye! No changes made.${NC}\n"
        exit 0
        ;;
      *)
        echo -e "  ${RED}Invalid input. Try 1-8, A, N, I, or Q.${NC}"
        sleep 1
        ;;
    esac
  done
}

# ── Installers ────────────────────────────────────────────────

install_git() {
  log_section "Git"
  if is_installed git; then
    log_warn "Already installed → $(git --version)"
    return
  fi
  sudo apt-get install -y git &>/dev/null
  log_ok "Git installed → $(git --version)"
}

install_docker() {
  log_section "Docker Engine + Compose"
  if is_installed docker; then
    log_warn "Already installed → $(docker --version)"
    return
  fi

  log_info "Adding Docker's official GPG key and repo..."
  sudo apt-get install -y ca-certificates curl gnupg &>/dev/null
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # shellcheck source=/dev/null
  . /etc/os-release
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    ${VERSION_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -qq &>/dev/null
  sudo apt-get install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin &>/dev/null

  sudo usermod -aG docker "$USER"
  log_ok "Docker installed → $(docker --version)"
  log_ok "Docker Compose installed → $(docker compose version)"
  log_warn "WSL tip: Run 'newgrp docker' or restart WSL to use Docker without sudo."
}

install_python() {
  log_section "Python 3 + pip + venv"
  if is_installed python3; then
    log_warn "Python already installed → $(python3 --version)"
  else
    sudo apt-get install -y python3 python3-venv &>/dev/null
    log_ok "Python installed → $(python3 --version)"
  fi

  if is_installed pip3; then
    log_warn "pip already installed → $(pip3 --version | awk '{print $1,$2}')"
  else
    sudo apt-get install -y python3-pip &>/dev/null
    log_ok "pip installed → $(pip3 --version | awk '{print $1,$2}')"
  fi
}

install_node() {
  log_section "Node.js LTS + npm"
  if is_installed node; then
    log_warn "Already installed → Node $(node --version) · npm $(npm --version)"
    return
  fi
  log_info "Setting up NodeSource LTS repository..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &>/dev/null
  sudo apt-get install -y nodejs &>/dev/null
  log_ok "Node.js installed → Node $(node --version) · npm $(npm --version)"
}

install_go() {
  log_section "Go (latest stable)"
  if is_installed go; then
    log_warn "Already installed → $(go version)"
    return
  fi

  log_info "Fetching latest Go version..."
  GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)
  log_info "Downloading $GO_VERSION..."
  curl -fsSL "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz

  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm /tmp/go.tar.gz

  # Add to PATH in both .bashrc and .profile
  # shellcheck disable=SC2016  # single quotes intentional: vars expand at shell startup, not now
  for rc in ~/.bashrc ~/.profile; do
    grep -q '/usr/local/go/bin' "$rc" 2>/dev/null || \
      echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$rc"
  done
  export PATH=$PATH:/usr/local/go/bin

  log_ok "Go installed → $(/usr/local/go/bin/go version)"
  log_info "PATH updated in ~/.bashrc and ~/.profile"
}

install_rust() {
  log_section "Rust (via rustup)"
  if is_installed rustc; then
    log_warn "Already installed → $(rustc --version)"
    return
  fi

  log_info "Running rustup installer..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

  # Source cargo env
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env" 2>/dev/null || true

  # Add to .bashrc if not present
  # shellcheck disable=SC2016  # single quotes intentional: $HOME expands at shell startup
  grep -q '.cargo/env' ~/.bashrc 2>/dev/null || \
    echo 'source "$HOME/.cargo/env"' >> ~/.bashrc

  log_ok "Rust installed → $(~/.cargo/bin/rustc --version)"
  log_ok "Cargo installed → $(~/.cargo/bin/cargo --version)"
}

install_vscode_cli() {
  log_section "VS Code CLI"

  if is_installed code; then
    log_warn "VS Code CLI already available in PATH"
    return
  fi

  # Check if accessible via Windows VS Code (common in WSL)
  if [[ -f "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin/code" ]]; then
    log_warn "VS Code found via Windows install — 'code .' should already work in WSL."
    return
  fi

  log_info "Downloading VS Code CLI (Linux x64)..."
  curl -fsSL \
    "https://update.code.visualstudio.com/latest/cli-linux-x64/stable" \
    -o /tmp/vscode_cli.tar.gz

  sudo tar -xzf /tmp/vscode_cli.tar.gz -C /usr/local/bin
  rm /tmp/vscode_cli.tar.gz
  sudo chmod +x /usr/local/bin/code

  log_ok "VS Code CLI installed → $(code --version 2>/dev/null | head -1 || echo 'installed')"
  log_info "Run 'code .' to open current folder in VS Code"
  log_info "Run 'code tunnel' for remote access from any browser"
}

install_kubectl() {
  log_section "kubectl"
  if is_installed kubectl; then
    log_warn "Already installed → $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    return
  fi

  log_info "Adding Kubernetes apt repository..."
  sudo apt-get install -y apt-transport-https ca-certificates curl &>/dev/null
  sudo mkdir -p /etc/apt/keyrings

  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
    https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

  sudo apt-get update -qq &>/dev/null
  sudo apt-get install -y kubectl &>/dev/null
  log_ok "kubectl installed → $(kubectl version --client --short 2>/dev/null || echo 'installed')"
}

install_helm() {
  log_section "Helm"
  if is_installed helm; then
    log_warn "Already installed → $(helm version --short)"
    return
  fi

  log_info "Adding Helm apt repository..."
  curl -fsSL https://baltocdn.com/helm/signing.asc \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

  sudo apt-get install -y apt-transport-https &>/dev/null
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
    https://baltocdn.com/helm/stable/debian/ all main" \
    | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null

  sudo apt-get update -qq &>/dev/null
  sudo apt-get install -y helm &>/dev/null
  log_ok "Helm installed → $(helm version --short)"
}

# ── Summary ───────────────────────────────────────────────────
print_summary() {
  echo ""
  echo -e "  ${CYAN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
  echo -e "  ${CYAN}${BOLD}║             Installation Summary             ║${NC}"
  echo -e "  ${CYAN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
  echo ""

  is_installed docker   && log_ok "Docker    → $(docker --version)"
  is_installed python3  && log_ok "Python    → $(python3 --version)"
  is_installed pip3     && log_ok "pip       → $(pip3 --version | awk '{print $1,$2}')"
  is_installed node     && log_ok "Node.js   → $(node --version)"
  is_installed npm      && log_ok "npm       → $(npm --version)"
  is_installed git      && log_ok "Git       → $(git --version)"
  /usr/local/go/bin/go version &>/dev/null 2>&1 && log_ok "Go        → $(/usr/local/go/bin/go version | awk '{print $3}')"
  ~/.cargo/bin/rustc --version &>/dev/null 2>&1  && log_ok "Rust      → $(~/.cargo/bin/rustc --version)"
  is_installed code     && log_ok "VSCode CLI → installed"
  is_installed kubectl  && log_ok "kubectl   → installed"
  is_installed helm     && log_ok "Helm      → $(helm version --short)"

  echo ""
  echo -e "  ${YELLOW}${BOLD}Next steps:${NC}"
  echo -e "  ${DIM}→ Run: ${NC}${BOLD}source ~/.bashrc${NC}${DIM}  (or restart terminal)${NC}"
  echo -e "  ${DIM}→ For Docker without sudo: ${NC}${BOLD}newgrp docker${NC}"
  echo ""
  echo -e "  ${GREEN}${BOLD}✔  Setup complete! Happy coding 🚀${NC}"
  echo ""
}

# ── Entry Point ───────────────────────────────────────────────
main() {
  run_menu

  # Count selected
  # NOTE: ((count++)) triggers set -e when count=0 (expression value 0 = exit code 1)
  # Use count=$((count+1)) instead — always safe with set -e
  local count=0
  for i in "${!TOOLS[@]}"; do [[ ${SELECTED[$i]} -eq 1 ]] && count=$((count + 1)); done

  if [[ $count -eq 0 ]]; then
    echo -e "\n  ${YELLOW}No tools selected. Exiting.${NC}\n"
    exit 0
  fi

  print_banner
  echo -e "  ${BOLD}Installing $count selected tool(s)...${NC}"
  echo -e "  ${DIM}(sudo password may be required)${NC}\n"

  log_info "Refreshing package lists..."
  sudo apt-get update -qq &>/dev/null

  # Run installers in dependency order
  [[ ${SELECTED[3]} -eq 1 ]] && install_git
  [[ ${SELECTED[0]} -eq 1 ]] && install_docker
  [[ ${SELECTED[1]} -eq 1 ]] && install_python
  [[ ${SELECTED[2]} -eq 1 ]] && install_node
  [[ ${SELECTED[4]} -eq 1 ]] && install_go
  [[ ${SELECTED[5]} -eq 1 ]] && install_rust
  [[ ${SELECTED[6]} -eq 1 ]] && install_vscode_cli
  [[ ${SELECTED[7]} -eq 1 ]] && { install_kubectl; install_helm; }

  print_summary
}

main