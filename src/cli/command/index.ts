import process from 'node:process';
import type { Cli } from 'clipanion';
import type { CliMode } from '../utils';
import { logger } from '../utils/logger';
import {
  InstallToolLegacyCommand,
  InstallToolLegacyShortCommand,
} from './install-tools/legacy';
import {
  InstallToolNodeCommand,
  InstallToolNodeShortCommand,
} from './install-tools/node';
import { prepareToolVersion } from './install-tools/utils';

export function prepareCommands(
  cli: Cli,
  mode: CliMode | null,
  args: string[]
): string[] {
  logger.debug('prepare commands');
  /*
   * Workaround for linking the cli tool as different executables.
   * So it can be called as `install-tool node 1.2.3`.
   */
  if (mode === 'install-tool') {
    cli.register(InstallToolLegacyShortCommand);
    cli.register(InstallToolNodeShortCommand);
    return prepareToolVersion(mode, args);
  }

  cli.register(InstallToolLegacyCommand);
  cli.register(InstallToolNodeCommand);
  return prepareToolVersion(mode, args);
}

export function parseBinaryName(
  mode: CliMode | null,
  node: string,
  app: string
): string | undefined {
  if (mode) {
    return mode;
  }

  return process.argv0.endsWith('/node') || process.argv0 === 'node'
    ? `${node} ${app}`
    : process.argv0;
}
