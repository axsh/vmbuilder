#!/bin/bash
#
# requires:
#  bash
#  cd, dirname
#

## include files

. $(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helper_shunit2.sh

## functions

function test_is_dev_device() {
  is_dev /dev/null
  assertEquals "$?" "0"
}

function test_is_dev_text() {
  is_dev /var/log/messages
  assertNotEquals "$?" "0"
}

function test_is_dev_empty() {
  is_dev
  assertNotEquals "$?" "0"
}

## shunit2

. ${shunit2_file}
