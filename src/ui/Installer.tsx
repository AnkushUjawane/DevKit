import React, { useState, useEffect }     from 'react';
import { Box, Text, useApp }              from 'ink';
import Spinner                            from 'ink-spinner';
import { installTool }                    from '../installers/index.js';
import type { OsInfo }                    from '../utils/os.js';
import type { ToolId }                    from '../tools.js';
import { TOOLS }                          from '../tools.js';
import { commandExists }                  from '../utils/os.js';

interface Props { selected: ToolId[]; osInfo: OsInfo; }

type Status = 'waiting' | 'running' | 'done' | 'skipped' | 'error';
interface ToolState { id: ToolId; label: string;  status: Status; lines: string[]; error?: string; }

export function Installer({ selected, osInfo }: Props) {
  const { exit } = useApp();

  const [tools, setTools] = useState<ToolState[]>(() =>
    selected.map(id => {
      const t = TOOLS.find(t => t.id === id)!;
      return { id, label: t.label, status: 'waiting' as Status, lines: [] };
    })
  );
  const [done, setDone] = useState(false);

  const update = (id: ToolId, patch: Partial<ToolState>) =>
    setTools(prev => prev.map(t => t.id === id ? { ...t, ...patch } : t));

  useEffect(() => {
    (async () => {
      for (const toolId of selected) {
        const tool = TOOLS.find(t => t.id === toolId)!;

        if (commandExists(tool.checkCmd)) {
          update(toolId, { status: 'skipped', lines: ['Already installed — skipping'] });
          continue;
        }

        update(toolId, { status: 'running' });

        const result = await installTool(toolId, osInfo, (line) =>
          setTools(prev => prev.map(t =>
            t.id === toolId ? { ...t, lines: [...t.lines.slice(-4), line] } : t
          ))
        );

        update(toolId, {
          status: result.status === 'done' ? 'done' : 'error',
          error:  result.error,
        });
      }
      setDone(true);
    })();
  }, []);

  useEffect(() => { if (done) setTimeout(() => exit(), 3000); }, [done]);

  const icon = (s: Status) => {
    if (s === 'waiting')  return <Text dimColor>○</Text>;
    if (s === 'running')  return <Text color="cyan"><Spinner type="dots" /></Text>;
    if (s === 'done')     return <Text color="green">✔</Text>;
    if (s === 'skipped')  return <Text color="yellow">⊘</Text>;
    return                       <Text color="red">✘</Text>;
  };

  const doneCount    = tools.filter(t => t.status === 'done').length;
  const skippedCount = tools.filter(t => t.status === 'skipped').length;
  const errorCount   = tools.filter(t => t.status === 'error').length;

  return (
    <Box flexDirection="column" paddingX={2} paddingY={1}>

      <Box marginBottom={1}>
        <Text color="cyan" bold>
          ⚙️  Installing {selected.length} tool{selected.length > 1 ? 's' : ''} on {osInfo.env} ({osInfo.pkgMgr})
        </Text>
      </Box>

      {tools.map(tool => (
        <Box key={tool.id} flexDirection="column" marginBottom={1}>
          <Box gap={1}>
            {icon(tool.status)}
            <Text color={tool.status === 'done' ? 'green' : tool.status === 'error' ? 'red' : undefined}
                  bold={tool.status === 'running'}>
              {tool.label}
            </Text>
            {tool.status === 'skipped' && <Text dimColor>(already installed)</Text>}
          </Box>
          {tool.status === 'running' && tool.lines.map((l, i) =>
            <Box key={i} paddingLeft={3}><Text dimColor>{l.slice(0, 70)}</Text></Box>
          )}
          {tool.status === 'error' && tool.error &&
            <Box paddingLeft={3}><Text color="red">{tool.error.slice(0, 80)}</Text></Box>
          }
        </Box>
      ))}

      {done && (
        <Box flexDirection="column" marginTop={1} borderStyle="round" borderColor="cyan" paddingX={2} paddingY={1}>
          <Text color="cyan" bold>Installation Complete</Text>
          <Box gap={3} marginTop={1}>
            {doneCount    > 0 && <Text color="green">✔ {doneCount} installed</Text>}
            {skippedCount > 0 && <Text color="yellow">⊘ {skippedCount} skipped</Text>}
            {errorCount   > 0 && <Text color="red">✘ {errorCount} failed</Text>}
          </Box>
          <Box marginTop={1}>
            <Text dimColor>Run </Text><Text bold>source ~/.bashrc</Text>
            <Text dimColor> to pick up Go/Rust PATH changes</Text>
          </Box>
          {errorCount > 0 &&
            <Box><Text color="yellow">Run </Text><Text bold>devkit</Text><Text color="yellow"> again to retry failed tools</Text></Box>
          }
          <Text dimColor>Exiting in 3s...</Text>
        </Box>
      )}

    </Box>
  );
}
