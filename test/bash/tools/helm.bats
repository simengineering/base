setup_file () {
  # set up the cache
  BUILDPACK_CACHE_DIR="$(mktemp -u)"
  mkdir -m 777 -p "${BUILDPACK_CACHE_DIR}"
}

setup() {
  load '../../../node_modules/bats-support/load'
  load '../../../node_modules/bats-assert/load'

  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  TEST_ROOT_DIR=$(mktemp -u)

  echo $TEST_DIR
  echo $BATS_TEST_FILENAME

  load "$TEST_DIR/../../../src/usr/local/buildpack/util.sh"

  # load v2 overwrites
  load "$TEST_DIR/../../../src/usr/local/buildpack/utils/v2/overrides.sh"

  # load test overwrites
  load "$TEST_DIR/../util.sh"

  # set directories for test
  ROOT_DIR="${TEST_ROOT_DIR}/root"
  BIN_DIR="${TEST_ROOT_DIR}/bin"

  setup_directories

  # set default test user
  TEST_ROOT_USER=1000

  # load helm
  load "$TEST_DIR/../../../src/usr/local/buildpack/tools/v2/helm.sh"

}

teardown() {
    rm -rf "${TEST_ROOT_DIR}"
}

teardown_file () {
  rm -rf "${BUILDPACK_CACHE_DIR}"
}

@test "helm: check_tool_requirements" {
  TOOL_NAME=helm

  TOOL_VERSION=foobar \
  run check_tool_requirements
  assert_failure

  TOOL_VERSION=1.2.3 \
  run check_tool_requirements
  assert_success
}

@test "helm: check_tool_installed" {
  local TOOL_NAME=helm

  # renovate: datasource=github-releases lookupName=helm/helm
  TOOL_VERSION=3.8.0

  run check_tool_installed
  assert_failure

  run install_tool
  assert_success

  run check_tool_installed
  assert_success
}

@test "helm: install_tool" {
  local TOOL_NAME=helm

  # renovate: datasource=github-releases lookupName=helm/helm
  TOOL_VERSION=3.8.0

  run install_tool
  assert_success

  local versioned_tool_path=$(find_versioned_tool_path)

  PATH="${versioned_tool_path}/bin" \
  run helm version
  assert_success
  assert_output --partial "${TOOL_VERSION}"

  # don't update
  TOOL_VERSION=3.7.0

  run install_tool
  assert_success

  local versioned_tool_path=$(find_versioned_tool_path)

  PATH="${versioned_tool_path}/bin" \
  run helm version
  assert_success
  assert_output --partial "${TOOL_VERSION}"
}

@test "helm: link_tool" {
  local TOOL_NAME=helm
  local bin_path=$(get_bin_path)

  # renovate: datasource=github-releases lookupName=helm/helm
  TOOL_VERSION=3.8.0

  run install_tool
  assert_success

  PATH="${bin_path}:$PATH" \
  run link_tool
  assert_success
  assert_output --partial "${TOOL_VERSION}"

  PATH="${bin_path}" \
  run helm version
  assert_success
  assert_output --partial "${TOOL_VERSION}"

  local versioned_tool_path=$(find_versioned_tool_path)

  PATH="${versioned_tool_path}/bin" \
  run helm version
  assert_success
  assert_output --partial "${TOOL_VERSION}"

  # don't update
  TOOL_VERSION=3.7.0

  run install_tool
  assert_success

  PATH="${bin_path}:$PATH" \
  run link_tool
  assert_success
  assert_output --partial "${TOOL_VERSION}"

  local versioned_tool_path=$(find_versioned_tool_path)

  PATH="${versioned_tool_path}/bin" \
  run helm version
  assert_success
  assert_output --partial "${TOOL_VERSION}"
}
