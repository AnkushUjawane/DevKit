#!/bin/bash
# ╔══════════════════════════════════════════════════════════╗
# ║              DevKit — One-line Installer                 ║
# ║   curl -fsSL https://raw.githubusercontent.com/         ║
# ║   YOUR_USERNAME/wsl-devkit/main/install.sh | bash       ║
# ╚══════════════════════════════════════════════════════════╝

set -euo pipefail

# ── Config ────────────────────────────────────────────────
REPO="AnkushUjawane/DevKit"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
INSTALL_DIR="${HOME}/.local/bin"
INSTALL_PATH="${INSTALL_DIR}/devkit"

# ── Colors ────────────────────────────────────────────────
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
RED='\033[0;31m';   BOLD='\033[1m';    NC='\033[0m'

log_info()    { echo -e "  ${CYAN}ℹ${NC}  $1"; }
log_ok()      { echo -e "  ${GREEN}✔${NC}  $1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${NC}  $1"; }
log_error()   { echo -e "  ${RED}✘${NC}  $1"; exit 1; }

# ── Banner ────────────────────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}  ┌────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}  │       Installing DevKit 🛠          │${NC}"
echo -e "${CYAN}${BOLD}  └────────────────────────────────────┘${NC}"
echo ""

# ── Checks ────────────────────────────────────────────────
log_info "Checking requirements..."

# Need bash
command -v bash &>/dev/null || log_error "bash not found. How are you even running this?"

# Need curl
command -v curl &>/dev/null || log_error "curl is not installed. Run: sudo apt-get install curl"

# Check WSL / Linux
if [[ "$(uname -s)" != "Linux" ]]; then
  log_warn "This tool is designed for Linux / WSL 2 (Ubuntu/Debian)."
  read -r -p "  Continue anyway? [y/N] " confirm
  [[ "${confirm}" =~ ^[Yy]$ ]] || exit 0
fi

log_ok "Requirements met"

# ── Install dir ───────────────────────────────────────────
log_info "Creating install directory: ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

# ── Download devsetup.sh ──────────────────────────────────
log_info "Downloading devkit from GitHub..."

SCRIPT_URL="${RAW_BASE}/devsetup.sh"

if ! curl -fsSL "${SCRIPT_URL}" -o "${INSTALL_PATH}"; then
  log_error "Download failed. Check your internet connection or GitHub URL:\n  ${SCRIPT_URL}"
fi

chmod +x "${INSTALL_PATH}"
log_ok "Downloaded → ${INSTALL_PATH}"

# ── Add to PATH ───────────────────────────────────────────
# Check if ~/.local/bin is already in PATH
if echo "$PATH" | grep -q "${INSTALL_DIR}"; then
  log_ok "${INSTALL_DIR} is already in your PATH"
else
  log_info "Adding ${INSTALL_DIR} to PATH in ~/.bashrc..."

  # Guard: only add if not already present in the file
  if ! grep -q 'HOME/.local/bin' ~/.bashrc 2>/dev/null; then
    # SC2016: single quotes intentional — $HOME must expand at shell startup, not now
    # SC2129: grouped redirect is cleaner here
    {
      echo ''
      echo '# Added by DevKit installer'
      # shellcheck disable=SC2016
      echo 'export PATH="$HOME/.local/bin:$PATH"'
    } >> ~/.bashrc
  fi

  # Also add to .profile for login shells
  if ! grep -q 'HOME/.local/bin' ~/.profile 2>/dev/null; then
    # shellcheck disable=SC2016
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
  fi

  log_ok "PATH updated in ~/.bashrc"
  log_warn "Run 'source ~/.bashrc' after install to use devkit immediately"
fi

# ── Verify ────────────────────────────────────────────────
if [[ -x "${INSTALL_PATH}" ]]; then
  log_ok "devkit is installed and executable"
else
  log_error "Something went wrong — ${INSTALL_PATH} is not executable"
fi

# ── Done ──────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}${BOLD}✔  DevKit installed successfully!${NC}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "  ${CYAN}1.${NC} Reload your shell:"
echo -e "     ${BOLD}source ~/.bashrc${NC}"
echo ""
echo -e "  ${CYAN}2.${NC} Run DevKit:"
echo -e "     ${BOLD}devkit${NC}"
echo ""
echo -e "  ${CYAN}3.${NC} Or re-run this installer to update:"
echo -e "     ${BOLD}curl -fsSL ${RAW_BASE}/install.sh | bash${NC}"
echo ""