#!/bin/bash

function install_tool () {
  local versioned_tool_path
  local arch
  local name
  local version
  local platform
  local repo

  arch=${ARCHITECTURE}
  name=$TOOL_NAME
  version=$TOOL_VERSION
  platform=$(uname -s)
  repo="astral-sh/$name"

  if [[ $platform == "Linux" ]]; then
    platform="linux"
  fi

  if [[ $arch == armv8* ]] || [[ $arch == arm64* ]] || [[ $arch == aarch64* ]]; then
    arch="aarch64"
  elif [[ $arch == i686* ]]; then
    arch="x86"
  fi

  binary="${name}-${arch}-${platform}"
  file_name="${binary}.gz"
  base_url="https://github.com/${repo}/releases/download/${version}"
  file_url="${base_url}/${file_name}"

  checksum_file=$(get_from_url "${file_url}.sha256")
  # get checksum from file
  expected_checksum=$(cut -d' ' -f1  "${checksum_file}")

  file=$(get_from_url "${file_url}" "${file_name}" "${expected_checksum}" "sha256sum")

  versioned_tool_path=$(create_versioned_tool_path)
  create_folder "${versioned_tool_path}/bin"

  gunzip -c "${file}" > "${TEMP_DIR}/rye"
  chmod +x "${TEMP_DIR}/rye"

  export RYE_HOME="${versioned_tool_path}"
  "${TEMP_DIR}/rye" self install --yes
}

function link_tool () {
  local versioned_tool_path
  versioned_tool_path=$(find_versioned_tool_path)

  reset_tool_env
  {
    printf -- "if [ -z \"\$RYE_HOME\" ]; then\n"
    printf -- "  export RYE_HOME=\"%s\"\n" "${versioned_tool_path}"
    printf -- "fi\n"
  } >> "$(find_tool_env)"

  shell_wrapper "rye" "${versioned_tool_path}/shims"
  [[ -n $SKIP_VERSION ]] || rye --version
}
