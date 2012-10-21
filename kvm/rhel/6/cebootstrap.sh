#!/bin/bash
#
# description:
#  Bootstrap a basic CentOS system
#
# requires:
#  bash
#  dirname, pwd
#
# import:
#   distro: build_chroot
#
# OPTIONS
#        --distro-arch=[x86_64 | i686]
#        --distro-name=[centos | sl]
#        --distro-ver=[6 | 6.0 | 6.2 | ... ]
#        --chroot-dir=/path/to/rootfs
#        --keepcache=1
#        --debug=1
#
set -e

## private functions

function register_options() {
  debug=${debug:-}
  [[ -z "${debug}" ]] || set -x
  chroot_dir=${chroot_dir:-}
}

### read-only variables

readonly abs_dirname=$(cd $(dirname $0) && pwd)

### include files

. ${abs_dirname}/functions/utils.sh
. ${abs_dirname}/functions/disk.sh
. ${abs_dirname}/functions/distro.sh

### prepare

extract_args $*

## main

register_options
build_chroot ${chroot_dir}
