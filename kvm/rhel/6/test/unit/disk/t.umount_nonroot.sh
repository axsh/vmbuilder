#!/bin/bash
#
# requires:
#   bash
#

## include files

. ./helper_shunit2.sh

## variables

declare chroot_dir=_chroot.$$

## public functions

function setUp() {
  mkdir -p ${chroot_dir}/proc
  mkdir -p ${chroot_dir}/dev
  mount --bind /proc ${chroot_dir}/proc
  mount --bind /dev  ${chroot_dir}/dev
}

function tearDown() {
  rm -rf ${chroot_dir}
}

function test_umount_nonroot() {
  umount_nonroot ${chroot_dir}
  assertEquals $? 0
}

## shunit2

. ${shunit2_file}