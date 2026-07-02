#!/usr/bin/env node
import React, { useState } from 'react';
import { render }          from 'ink';
import { Menu }            from './ui/Menu.js';
import { Installer }       from './ui/Installer.js';
import { detectOs }        from './utils/os.js';
import type { ToolId }     from './tools.js';

type Screen = 'menu' | 'installing';

function App() {
  const [screen,   setScreen]   = useState<Screen>('menu');
  const [selected, setSelected] = useState<ToolId[]>([]);
  const osInfo = detectOs();

  if (screen === 'menu')
    return <Menu onStart={(tools) => { setSelected(tools); setScreen('installing'); }} />;

  return <Installer selected={selected} osInfo={osInfo} />;
}

render(<App />);
