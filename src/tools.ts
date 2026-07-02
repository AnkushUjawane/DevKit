// Central registry — add a new tool here + a case in installers/

export type ToolId =
  | 'docker' | 'python' | 'node' | 'git'
  | 'go'     | 'rust'   | 'vscode' | 'kubectl';

export interface Tool {
  id:          ToolId;
  label:       string;
  description: string;
  emoji:       string;
  checkCmd:    string;   // used to detect if already installed
}

export const TOOLS: Tool[] = [
  { id: 'docker',  label: 'Docker Engine + Compose', description: 'Containers & orchestration',     emoji: '🐳', checkCmd: 'docker'  },
  { id: 'python',  label: 'Python 3 + pip',          description: 'python3, pip3, venv',            emoji: '🐍', checkCmd: 'python3' },
  { id: 'node',    label: 'Node.js LTS + npm',       description: 'Latest LTS via NodeSource',      emoji: '🟩', checkCmd: 'node'    },
  { id: 'git',     label: 'Git',                     description: 'Version control',                emoji: '🔵', checkCmd: 'git'     },
  { id: 'go',      label: 'Go (latest)',              description: 'Official binary from go.dev',    emoji: '🐹', checkCmd: 'go'      },
  { id: 'rust',    label: 'Rust (via rustup)',        description: 'rustc + cargo',                  emoji: '🦀', checkCmd: 'rustc'   },
  { id: 'vscode',  label: 'VS Code CLI',             description: 'code command + tunnel support',  emoji: '💻', checkCmd: 'code'    },
  { id: 'kubectl', label: 'kubectl + Helm',          description: 'Kubernetes CLI + Helm v3',       emoji: '☸️', checkCmd: 'kubectl' },
];
