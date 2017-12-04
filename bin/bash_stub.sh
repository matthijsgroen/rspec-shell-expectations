#!/usr/bin/env bash
function json-encode {
  echo -n "${1}." |
    awk '
      BEGIN {RS=""}
      {
        gsub(/\\/, "\\\\")
        gsub(/\"/, "\\\"")
        gsub(/\t/, "\\t")
        gsub(/\r/, "\\r")
        gsub(/\b/, "\\b")
        gsub(/\n/, "\\n")
        print substr($0, 1, length($0)-1)
      }
    '
}

function json-decode {
  echo "${1}" |
    awk '
      {
        gsub(/\\"/, "\"")
        print $0
      }
    '
}

function create-call-log {
  command_name=${1}; shift
  command_port=${1}; shift
  raw_stdin=$([[ -t 0 ]] && echo -n '' || cat -)

  argument_list=( "${@}" )
  command=$(
    echo "\"command\":\"${command_name}\","
  )
  stdin=$(
    echo "\"stdin\":\"$(json-encode "${raw_stdin}")\","
  )
  arguments=$(
    for index in "${!argument_list[@]}"; do
      arg="${argument_list[${index}]}"
      echo "\"args.${index}\":\"$(json-encode "${arg}")\","
    done
  )

  echo "{"
  echo "${command}"
  [[ -n "${arguments}" ]] && echo "${stdin}" || echo "${stdin%,}"
  [[ -n "${arguments}" ]] && echo "${arguments%,}"
  echo "}"
}

function send-to-server {
  echo -n "${2}" | nc localhost ${1}
}

function extract-properties {
  echo "${1}" | sed -En "s/^\"${2}\":\"?([^,\"]*)\"?,?$/\1/gp"
}

function print-output {
  case ${1} in
    stdout)
      echo -en "${2}"
      ;;
    stderr)
      echo -en "${2}" >&2
      ;;
    *)
      echo -en "${2}" > ${1}
      ;;
  esac
}
function main {
  client_message=$(create-call-log "${@}")
  server_message=$(send-to-server "${2}" "${client_message}")
  IFS=$'\n'
  target_list=( $(extract-properties "${server_message}" "outputs\..*\.target") )
  content_list=( $(extract-properties "${server_message}" "outputs\..*\.content") )
  exit_code=$(extract-properties "${server_message}" "exitcode")

  for index in "${!target_list[@]}"; do
    target=${target_list[${index}]}
    content=$(json-decode "${content_list[${index}]}")
    print-output "${target}" "${content}"
  done

  exit ${exit_code}
}

[[ ${0} == ${BASH_SOURCE} ]] && main "${@}"
