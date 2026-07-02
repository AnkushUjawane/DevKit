import React, { useState, useEffect } from 'react';
import figlet from 'figlet';
import { Box, Text, useInput, useApp } from 'ink';
import { commandExists } from '../utils/os.js';
import { TOOLS } from '../tools.js';
import type { ToolId } from '../tools.js';

interface Props { onStart: (selected: ToolId[]) => void; }
const banner = figlet.textSync("Devkit");

export function Menu({ onStart }: Props) {
  const { exit }                      = useApp();
  const [cursor,    setCursor]        = useState(0);
  const [selected,  setSelected]      = useState<Set<ToolId>>(new Set());
  const [installed, setInstalled]     = useState<string[]>([]);

  useEffect(() => {
    setInstalled(TOOLS.filter(t => commandExists(t.checkCmd)).map(t => t.label));
  }, []);

  const toggle = (id: ToolId) =>
    setSelected(prev => { const n = new Set(prev); n.has(id) ? n.delete(id) : n.add(id); return n; });

  useInput((input, key) => {
    if (key.upArrow)   setCursor(c => Math.max(0, c - 1));
    if (key.downArrow) setCursor(c => Math.min(TOOLS.length - 1, c + 1));
    if (input === ' ') toggle(TOOLS[cursor].id);

    const num = parseInt(input, 10);
    if (num >= 1 && num <= TOOLS.length) toggle(TOOLS[num - 1].id);

    if (input === 'a' || input === 'A') setSelected(new Set(TOOLS.map(t => t.id)));
    if (input === 'n' || input === 'N') setSelected(new Set());
    if (input === 'q' || input === 'Q') exit();
    if ((input === 'i' || input === 'I' || key.return) && selected.size > 0)
      onStart([...selected]);
  });

  return (
    <Box flexDirection="column" paddingX={2} paddingY={1}>

      <Box flexDirection="column" marginBottom={1}>
        <Text color="cyan" bold>{banner}</Text>
        <Text color="cyan" bold> Development Environment Setup </Text>
      </Box>

      <Box marginBottom={1}>
        <Text dimColor>↑↓ navigate · Space/number toggle · A=All · N=None · I=Install · Q=Quit</Text>
      </Box>

      {TOOLS.map((tool, i) => {
        const isSelected  = selected.has(tool.id);
        const isCursor    = cursor === i;
        const isInstalled = commandExists(tool.checkCmd);
        return (
          <Box key={tool.id}>
            <Text
              color={isCursor ? 'cyan' : isSelected ? 'green' : undefined}
              bold={isCursor}
              dimColor={!isSelected && !isCursor}
            >
              {isCursor ? '▶ ' : '  '}
              {isSelected ? '[✔]' : '[ ]'} {i + 1}. {tool.label}
              {isInstalled ? ' (installed)' : ''}
            </Text>
          </Box>
        );
      })}

      {installed.length > 0 && (
        <Box flexDirection="column" marginTop={1}>
          <Text dimColor>Already on your system:</Text>
          <Text color="yellow">{installed.join(' · ')}</Text>
        </Box>
      )}

      <Box marginTop={1}>
        <Text color={selected.size > 0 ? 'cyan' : 'gray'}>
          {selected.size > 0
            ? `${selected.size} tool${selected.size > 1 ? 's' : ''} selected — press I to install`
            : 'Nothing selected yet — press a number or Space to toggle'}
        </Text>
      </Box>

    </Box>
  );
}
