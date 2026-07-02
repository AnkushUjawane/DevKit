import { execa }       from 'execa';
import type { OsInfo } from '../utils/os.js';
import type { ToolId } from '../tools.js';

export type InstallStatus = 'idle' | 'running' | 'done' | 'skipped' | 'error';

export interface InstallResult {
  toolId: ToolId;
  status: InstallStatus;
  output: string[];
  error?: string;
}

type OutputCb = (line: string) => void;

async function runScript(script: string, onOutput: OutputCb): Promise<void> {
  const proc = execa('bash', ['-c', script], {
    env: { ...process.env, DEBIAN_FRONTEND: 'noninteractive' },
  });
  proc.stdout?.on('data', (chunk: Buffer) =>
    chunk.toString().split('\n').filter((l: string) => l.trim()).forEach((l: string) => onOutput(l)));
  proc.stderr?.on('data', (chunk: Buffer) =>
    chunk.toString().split('\n').filter((l: string) => l.trim()).forEach((l: string) => onOutput(`⚠ ${l}`)));
  await proc;
}

// ── Install recipes per tool per package manager ──────────
const recipes: Record<ToolId, Record<string, string>> = {
  git: {
    apt:    'sudo apt-get install -y git',
    brew:   'brew install git',
    winget: 'winget install --id Git.Git -e',
  },
  docker: {
    apt: [
      'sudo apt-get install -y ca-certificates curl gnupg',
      'sudo install -m 0755 -d /etc/apt/keyrings',
      'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg',
      'sudo chmod a+r /etc/apt/keyrings/docker.gpg',
      '. /etc/os-release && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null',
      'sudo apt-get update -qq',
      'sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin',
      'sudo usermod -aG docker $USER',
    ].join(' && \\\n  '),
    brew:   'brew install --cask docker',
    winget: 'winget install Docker.DockerDesktop',
  },
  python: {
    apt:    'sudo apt-get install -y python3 python3-pip python3-venv',
    brew:   'brew install python3',
    winget: 'winget install Python.Python.3',
  },
  node: {
    apt: [
      'curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -',
      'sudo apt-get install -y nodejs',
    ].join(' && \\\n  '),
    brew:   'brew install node',
    winget: 'winget install OpenJS.NodeJS.LTS',
  },
  go: {
    apt: [
      'GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)',
      'curl -fsSL "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz',
      'sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go.tar.gz',
      'rm /tmp/go.tar.gz',
      "grep -q '/usr/local/go/bin' ~/.bashrc || echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc",
    ].join(' && \\\n  '),
    brew:   'brew install go',
    winget: 'winget install GoLang.Go',
  },
  rust: {
    apt: [
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path",
      'grep -q \'.cargo/env\' ~/.bashrc || echo \'source "$HOME/.cargo/env"\' >> ~/.bashrc',
    ].join(' && \\\n  '),
    brew:   'brew install rust',
    winget: 'winget install Rustlang.Rustup',
  },
  vscode: {
    apt: [
      'curl -fsSL "https://update.code.visualstudio.com/latest/cli-linux-x64/stable" -o /tmp/vscode_cli.tar.gz',
      'sudo tar -xzf /tmp/vscode_cli.tar.gz -C /usr/local/bin',
      'rm /tmp/vscode_cli.tar.gz && sudo chmod +x /usr/local/bin/code',
    ].join(' && \\\n  '),
    brew:   'brew install --cask visual-studio-code',
    winget: 'winget install Microsoft.VisualStudioCode',
  },
  kubectl: {
    apt: [
      'sudo apt-get install -y apt-transport-https ca-certificates curl',
      'sudo mkdir -p /etc/apt/keyrings',
      'curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg',
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null",
      'sudo apt-get update -qq && sudo apt-get install -y kubectl',
      'curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null',
      'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null',
      'sudo apt-get update -qq && sudo apt-get install -y helm',
    ].join(' && \\\n  '),
    brew:   'brew install kubectl helm',
    winget: 'winget install Kubernetes.kubectl && winget install Helm.Helm',
  },
};

export async function installTool(
  toolId: ToolId, osInfo: OsInfo, onOutput: OutputCb,
): Promise<InstallResult> {
  const output: string[] = [];
  const collect: OutputCb = (line) => { output.push(line); onOutput(line); };
  const cmd = recipes[toolId][osInfo.pkgMgr] ?? recipes[toolId]['apt'];

  if (!cmd) return { toolId, status: 'error', output, error: `No recipe for ${toolId} on ${osInfo.pkgMgr}` };

  try {
    collect(`▸ Installing ${toolId} via ${osInfo.pkgMgr}...`);
    await runScript(cmd, collect);
    return { toolId, status: 'done', output };
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return { toolId, status: 'error', output, error: msg };
  }
}
