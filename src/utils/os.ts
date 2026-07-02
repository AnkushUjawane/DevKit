import { execSync } from 'child_process';
import * as os from 'os';
import * as fs from 'fs';

export type OsType  = 'linux' | 'macos' | 'windows';
export type PkgMgr  = 'apt' | 'brew' | 'winget' | 'pacman' | 'dnf' | 'unknown';
export type EnvType = 'wsl' | 'native-linux' | 'macos' | 'windows';

export interface OsInfo {
  os:     OsType;
  env:    EnvType;
  pkgMgr: PkgMgr;
  distro: string;
  arch:   string;
}

function isWsl(): boolean {
  try {
    const v = fs.readFileSync('/proc/version', 'utf8').toLowerCase();
    return v.includes('microsoft') || v.includes('wsl');
  } catch { return false; }
}

function getDistro(): string {
  try {
    const c = fs.readFileSync('/etc/os-release', 'utf8');
    const m = c.match(/^PRETTY_NAME="?([^"\n]+)"?/m);
    return m ? m[1] : 'Unknown Linux';
  } catch { return 'Unknown'; }
}

function detectPkgMgr(): PkgMgr {
  const has = (cmd: string) => {
    try { execSync(`command -v ${cmd}`, { stdio: 'ignore' }); return true; }
    catch { return false; }
  };
  if (has('apt-get')) return 'apt';
  if (has('brew'))    return 'brew';
  if (has('pacman'))  return 'pacman';
  if (has('dnf'))     return 'dnf';
  if (has('winget'))  return 'winget';
  return 'unknown';
}

export function detectOs(): OsInfo {
  const platform = os.platform();
  const arch     = os.arch();

  if (platform === 'darwin')
    return { os: 'macos', env: 'macos', pkgMgr: 'brew', distro: 'macOS', arch };

  if (platform === 'win32')
    return { os: 'windows', env: 'windows', pkgMgr: 'winget', distro: 'Windows', arch };

  return {
    os:     'linux',
    env:    isWsl() ? 'wsl' : 'native-linux',
    pkgMgr: detectPkgMgr(),
    distro: getDistro(),
    arch,
  };
}

export function commandExists(cmd: string): boolean {
  try { execSync(`command -v ${cmd}`, { stdio: 'ignore' }); return true; }
  catch { return false; }
}
