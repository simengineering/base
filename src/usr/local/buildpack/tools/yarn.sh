#!/usr/bin/env bash

set -e

check_command node

tool_path=$(find_tool_path)

function update_env () {
  reset_tool_env
  export_tool_path "${1}/bin"
}

if [[ -z "${tool_path}" ]]; then
  INSTALL_DIR=$(get_install_dir)
  base_path=${INSTALL_DIR}/${TOOL_NAME}
  tool_path=${base_path}/${TOOL_VERSION}

  mkdir -p ${tool_path}

  NPM_CONFIG_PREFIX=$tool_path npm install --cache /tmp/empty-cache -g ${TOOL_NAME}@${TOOL_VERSION}

  # Clean download cache
  NPM_CONFIG_PREFIX=$tool_path npm cache clean --force
  # Clean node-gyp cache
  rm -rf $HOME/.cache /tmp/empty-cache

  update_env ${tool_path}
  shell_wrapper ${TOOL_NAME}
else
  echo "Already installed, resetting env"
  update_env ${tool_path}
fi

yarn --version
