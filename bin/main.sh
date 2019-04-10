#!/usr/bin/env bash

declare current_dir=$(pwd)
declare proxy=""
declare scan_dev_dependencies=""
declare full_report=""

function usage() {
	cat <<END
  komatora [-h] [-p proxy] [-d] [-f]

  Runs patch management tool komatora on local directories
    -h: show this help message
    -p: set the proxy (example: https_proxy=http://proxy.url.com:8080)
    -f: show full report
    -d: includes devDependencies during the scan
END
}

function error() {
	echo "Error: $1"
	usage
	exit $2
} >&2

function get_options() {
  while getopts ":hp:fd" opt; do
    case $opt in
    	d)
        scan_dev_dependencies="yes"
        ;;
      p)
        proxy="${OPTARG}"	
        ;;
      f)
        full_report="--json"
        ;;        
      h)
        usage
        exit 0
        ;;
      :) 
        error "Option -${OPTARG} is missing an argument" 2
        ;;
      \?)
        error "Unknown option: -${OPTARG}" 3
        ;;
    esac
  done

  shift $(( OPTIND -1 ))
}

function check_prereqs() {
  if ! type jq > /dev/null 2>&1; then
    error "Please install jq and run this script again" 0
  fi
}

function backup() {
  declare -a files_to_backup=("package.json" "package-lock.json" ".npmrc")

  if [[ ! -e "${current_dir}/package.json" ]]; then
    error "File package.json does not exist. Exiting the script" 0
  fi

  for file_name in "${files_to_backup[@]}"
  do
    if [[ -e ${current_dir}/${file_name} ]]; then
      cp ${current_dir}/${file_name} ${current_dir}/original-${file_name}
    fi
  done

  if [[ -e "${current_dir}/.npmrc" ]]; then
    rm -f ${current_dir}/.npmrc
  fi
}

function parse_package_json() {
  tmp_keys=
  if [[ -e ${current_dir}/komatora.json ]]; then
    exceptions_file="${current_dir}/komatora.json"
    declare -a tmp_keys=$(cat $exceptions_file | jq -r 'keys[]' | xargs)
  fi

  IFS=' ' read -ra key_to_delete <<< "${tmp_keys}"
  if [[ ${scan_dev_dependencies} = "yes" ]]; then 
    to_delete=''
  else 
    to_delete='.devDependencies,'
  fi

  if [[ ${to_delete} || ${#key_to_delete[@]} > 0 ]]; then
    for key_name in "${key_to_delete[@]}"
    do
      to_delete=$to_delete' .dependencies."'$key_name'",'
    done

    to_delete=${to_delete%?}

    to_delete='del('$to_delete')'

    cat "${current_dir}/package.json" | jq "${to_delete}" > ${current_dir}/temp-package.json

    mv -f ${current_dir}/temp-package.json ${current_dir}/package.json
  fi
}

function get_package_lock(){
  npm i --package-lock-only > /dev/null
}

function run_npm_audit() {
  ${proxy} npm audit ${full_report} --registry=https://registry.npmjs.org
}

function cleanup() {
  declare -a files_to_roolback=("package.json" "package-lock.json" ".npmrc")

  rm -f ${current_dir}/package-lock.json || true

  for file_name in "${files_to_roolback[@]}"
  do
    if [[ -e ${current_dir}/original-${file_name} ]]; then
      mv -f ${current_dir}/original-${file_name} ${current_dir}/${file_name}
    fi
  done
}

function main() {
  get_options $@
  check_prereqs

  backup
  parse_package_json
  get_package_lock
  run_npm_audit
  cleanup

  exit 0
}

main $@
