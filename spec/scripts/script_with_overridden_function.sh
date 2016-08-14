#!/usr/bin/env bash
function overridden_function {
  echo 'i was not overridden'
}
overridden_function "$1" "$2"

echo 'standard error output' 1>&2
