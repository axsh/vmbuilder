#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

## public functions

function setUp() {
  mkdir -p ${chroot_dir}
}

function tearDown() {
  rm -f  ${pubkey_file}
  rm -rf ${chroot_dir}
}

function test_install_authorized_keys_no_opts() {
  install_authorized_keys
  assertNotEquals $? 0
}

function test_install_authorized_keys_opts() {
  install_authorized_keys ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
