# -*-Shell-script-*-
#
# description:
#  Hypervisor lxc
#
# requires:
#  bash, cat
#
# imports:
#  utils: shlog
#  hypervisor: configure_container, viftabproc
#

function add_option_hypervisor_lxc() {
  name=${name:-rhel6}

  image_format=${image_format:-raw}
  image_file=${image_file:-${name}.${image_format}}
  image_path=${image_path:-${image_file}}

  brname=${brname:-br0}

  mem_size=${mem_size:-1024}
  cpu_num=${cpu_num:-1}

  vif_num=${vif_num:-1}
  viftab=${viftab:-}

  vendor_id=${vendor_id:-52:54:00}
}

function configure_hypervisor() {
  local chroot_dir=$1
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] no such directory: ${chroot_dir} (hypervisor/lxc:${LINENO})" >&2; return 1; }

  echo "[INFO] ***** Configuring lxc-specific *****"
  configure_container ${chroot_dir}

 #run_in_target ${chroot_dir} chkconfig udev-post off
 #run_in_target ${chroot_dir} chkconfig network on
}

function render_lxc_config() {
	cat <<-EOS
	lxc.utsname = ${hostname:-localhost}
	lxc.tty = 6
	#lxc.pts = 1024
	lxc.network.type = veth
	lxc.network.flags = up
	lxc.network.link = ${brname}
	lxc.network.name = eth0
	lxc.network.mtu = 1500
	lxc.network.hwaddr = $(gen_macaddr)
	lxc.rootfs = ${rootfs_dir}

	#lxc.mount.entry = devpts ${rootfs_dir}/dev/pts                devpts  gid=5,mode=620  0 0
	lxc.mount.entry = proc   ${rootfs_dir}/proc                   proc    defaults        0 0
	lxc.mount.entry = sysfs  ${rootfs_dir}/sys                    sysfs   defaults        0 0
	
	# /dev/null and zero
	lxc.cgroup.devices.allow = c 1:3 rwm
	lxc.cgroup.devices.allow = c 1:5 rwm
	
	# consoles
	lxc.cgroup.devices.allow = c 5:1 rwm
	lxc.cgroup.devices.allow = c 5:0 rwm
	lxc.cgroup.devices.allow = c 4:0 rwm
	lxc.cgroup.devices.allow = c 4:1 rwm

	# /dev/{,u}random
	lxc.cgroup.devices.allow = c 1:9 rwm
	lxc.cgroup.devices.allow = c 1:8 rwm
	lxc.cgroup.devices.allow = c 136:* rwm
	lxc.cgroup.devices.allow = c 5:2 rwm
	
	# rtc
	lxc.cgroup.devices.allow = c 254:0 rwm
	EOS
}

## controll lxc process

function lxc_create() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  local lxc_config_path=$(pwd)/lxc.conf
  render_lxc_config > ${lxc_config_path}
  shlog lxc-create -f ${lxc_config_path} -n ${name}
}

function lxc_start() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-start -n ${name} -d -l DEBUG -o $(pwd)/lxc.log
}

function lxc_stop() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-stop -n ${name}
}

function lxc_destroy() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/kvm:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-destroy -n ${name}
}

function lxc_info() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/lxc:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-info --name ${name}
}

function lxc_console() {
  local name=$1
  [[ -n "${name}" ]] || { echo "[ERROR] Invalid argument: name:${name} (hypervisor/lxc:${LINENO})" >&2; return 1; }
  checkroot || return 1

  shlog lxc-console --name ${name}
}