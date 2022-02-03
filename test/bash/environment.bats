setup() {
  load '../../node_modules/bats-support/load'
  load '../../node_modules/bats-assert/load'

  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"

  # Not used yet, will be used after the refactoring
  TEST_ROOT_DIR=$(mktemp -u)

  # Not used yet
  USER_NAME=user
  USER_ID=1000
  # Not needed in the future
  USER_HOME=${TEST_ROOT_DIR}

  load "$TEST_DIR/../../src/usr/local/buildpack/util.sh"
}

teardown() {
  rm -rf "${TEST_ROOT_DIR}"
}

@test "handles setting and getting the tool env correctly" {
  local install_dir=$(get_install_dir)
  local TOOL_NAME=foo
  local TOOL_VERSION=1.2.3

  mkdir -p "${TEST_ROOT_DIR}/env.d"

  # TODO(Chumper): This should fail
  TOOL_NAME= run export_tool_env
  # assert_failure
  assert_success

  export_tool_env FOO_HOME 123
  assert [ "${FOO_HOME}" = "123" ]
  run cat "${install_dir}/env.d/foo.sh"
  assert_success
  assert_output --partial "FOO_HOME=\${FOO_HOME-123}"

  run reset_tool_env
  assert_success

  run cat "${install_dir}/env.d/foo.sh"
  assert_failure
}

@test "handles complex setting and getting the tool env correctly" {
  local install_dir=$(get_install_dir)
  local TOOL_NAME=foo
  local TOOL_VERSION=1.2.3

  mkdir -p "${TEST_ROOT_DIR}/env.d"

  # TODO(Chumper): This should fail
  TOOL_NAME= run export_tool_env
  # assert_failure
  assert_success

  export_tool_env FOO_HOME 123
  assert [ "${FOO_HOME}" = "123" ]
  run cat "${install_dir}/env.d/foo.sh"
  assert_success
  assert_output --partial "FOO_HOME=\${FOO_HOME-123}"

  # Below cases cannot be tested unless we have flexible setup methods

  # unset FOO_HOME
  # assert [ -z "${FOO_HOME}" ]
  # assert [ -n "${TEST_ROOT_DIR}" ]
  # assert [ -n "${ENV_FILE}" ]

  # . "/usr/local/etc/env"
  # assert [ "${FOO_HOME}" = "123" ]

  # unset FOO_HOME

  # BASH_ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # run bash -c 'env | grep FOO'
  # assert_success
  # assert_output --partial FOO_HOME=123

  # unset FOO_HOME

  # BASH_ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # run bash -c "sh -c 'env | grep FOO'"
  # assert_success
  # assert_output --partial FOO_HOME=123
}

@test "handles complex setting and getting the tool path correctly" {
  local install_dir=$(get_install_dir)
  local TOOL_NAME=foo
  local TOOL_VERSION=1.2.3

  mkdir -p "${TEST_ROOT_DIR}/env.d"

  local old_path=$PATH

  # TODO(Chumper): This test should fail
  TOOL_NAME= run export_tool_path
  # assert_failure
  assert_success

  export_tool_path /foo
  assert echo "${PATH}" | grep "/foo:"

  # Append to the end is not implemented yet

  # export_tool_path /foo true
  # assert echo "${PATH}" | grep ":/foo"
  # export PATH=$old_path

  BASH_ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
    ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
    run bash -c 'env | grep PATH'
  assert_success
  assert_output --partial "/foo:"

  BASH_ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
    ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
    run bash -c 'sh -c "env | grep PATH"'
  assert_success
  assert_output --partial "/foo:"

  # Append to the end is not implemented yet

  # BASH_ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # run bash -c 'env | grep PATH'
  # assert_success
  # assert_output --partial :/foo
  # export PATH=$old_path

  # BASH_ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # ENV="${TEST_ROOT_DIR}/usr/local/etc/env" \
  # run bash -c 'sh -c "env | grep PATH"'
  # assert_success
  # assert_output --partial :/foo
  export PATH=$old_path
}
