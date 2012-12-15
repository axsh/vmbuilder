# -*-Shell-script-*-
#
# description:
#  Various utility functions
#
# requires:
#  bash
#  pwd, stat, chroot
#  cat, xargs, cut,sed
#
# imports:
#

function extract_args() {
  CMD_ARGS=
  local arg=
  for arg in ${*}; do
    case "${arg}" in
    --*=*)
      key=${arg%%=*}; key=${key##--}; key=${key//-/_}
      value=${arg##--*=}
      eval "${key}=\"${value}\""
      ;;
    --*)
      key=${arg##--}; key=${key//-/_}
      eval "${key}=1"
      ;;
    *)
      CMD_ARGS="${CMD_ARGS} ${arg}"
      ;;
    esac
  done
  unset arg key value
  # trim
  CMD_ARGS=${CMD_ARGS%% }
  CMD_ARGS=${CMD_ARGS## }
}

function extract_dirname() {
  local filepath=$1
  [[ -a "${filepath}" ]] || { echo "[ERROR] file not found: ${filepath} (utils:${LINENO})" >&2; return 1; }

  cd $(dirname ${filepath}) && pwd
}

function expand_path() {
  local filepath=$1
  [[ -a "${filepath}" ]] || { echo "[ERROR] file not found: ${filepath} (utils:${LINENO})" >&2; return 1; }

  echo $(extract_dirname ${filepath})/$(basename ${filepath})
}

function extract_path() {
  local filepath=$1
  [[ -a "${filepath}" ]] || { echo "[ERROR] file not found: ${filepath} (utils:${LINENO})" >&2; return 1; }

  local tmp_path=${filepath}
  local tmp_dirname=$(extract_dirname ${filepath})

  [[ -L "${filepath}" ]] && {
    tmp_path=$(readlink ${filepath})
    tmp_path=$(extract_dirname ${tmp_dirname}/${tmp_path})/$(basename ${tmp_path})
  } || {
    tmp_path=${tmp_dirname}/$(basename ${tmp_path})
  }

  # nested symlink?
  [[ -L "${tmp_path}" ]] && {
    extract_path ${tmp_path}
  } || {
    echo ${tmp_path}
  }
}

function run_cmd() {
  #
  # Runs a command.
  #
  # Locale is reset to C to make parsing error messages possible.
  #
  export LANG=C
  export LC_ALL=C
  eval $*
}

function run_in_target() {
  local chroot_dir=$1; shift; local args="$*"
  [[ -d "${chroot_dir}" ]] || { echo "[ERROR] directory not found: ${chroot_dir} (utils:${LINENO})" >&2; return 1; }

  chroot ${chroot_dir} bash -e -c "${args}"
}

function checkroot() {
  #
  # Check if we're running as root, and bail out if we're not.
  #
  [[ "${UID}" -ne 0 ]] && {
    echo "[ERROR] Must run as root." >&2
    return 1
  } || :
}

function load_config() {
  local config_path=$1
  [[ -a "${config_path}" ]] || { echo "[ERROR] file not found: ${config_path} (utils:${LINENO})" >&2; return 1; }

  . ${config_path}
}

function shlog() {
  echo "\$ $*"
  eval $*
}

function dump_process_args() {
  cat | xargs echo | cut -d' ' -f9- | sed "s, ,\n,g"
}

function beautify_process_args() {
  while read arg; do
    case "${arg}" in
    -*) echo -n "${arg}"  ;;
     *) echo    " ${arg}" ;;
    esac
  done < <(cat | dump_process_args)
}
