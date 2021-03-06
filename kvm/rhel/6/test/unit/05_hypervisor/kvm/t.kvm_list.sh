#!/bin/bash
#
# requires:
#   bash
#

## include files

. $(cd ${BASH_SOURCE[0]%/*} && pwd)/helper_shunit2.sh

## variables

## public functions

function setUp() {
  add_option_hypervisor_kvm
  function egrep() { echo egrep $*; }
}

function test_kvm_list() {
  # connect to local tcp/22
  kvm_list | grep -q "egrep -v egrep -w"
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}
