export type ToolId =
  | 'docker' | 'python' | 'node' | 'git'
  | 'go'     | 'rust'   | 'vscode' | 'kubectl';

export interface Tool {
  id:          ToolId;
  label:       string;
  description: string;
  checkCmd:    string;
}

export const TOOLS: Tool[] = [
  { id: 'docker',  label: 'Docker Engine + Compose', description: 'Containers & orchestration',    checkCmd: 'docker'  },
  { id: 'python',  label: 'Python 3 + pip',          description: 'python3, pip3, venv',           checkCmd: 'python3' },
  { id: 'node',    label: 'Node.js LTS + npm',       description: 'Latest LTS via NodeSource',     checkCmd: 'node'    },
  { id: 'git',     label: 'Git',                     description: 'Version control',               checkCmd: 'git'     },
  { id: 'go',      label: 'Go (latest)',              description: 'Official binary from go.dev',   checkCmd: 'go'      },
  { id: 'rust',    label: 'Rust (via rustup)',        description: 'rustc + cargo',                 checkCmd: 'rustc'   },
  { id: 'vscode',  label: 'VS Code CLI',             description: 'code command + tunnel support', checkCmd: 'code'    },
  { id: 'kubectl', label: 'kubectl + Helm',          description: 'Kubernetes CLI + Helm v3',      checkCmd: 'kubectl' },
];
