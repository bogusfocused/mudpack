#!/bin/bash

SRC_NAME=${BASH_SOURCE[1]}

function die {
    local message="$1"
    if [ -z "$message" ]; then
        printf >&2 '%s: line %s: %s: exited unexpectedly.' ${BASH_SOURCE[1]} ${BASH_LINENO[0]} ${FUNCNAME[1]}
    else
        printf >&2 '%s\n' "$message"
    fi
    exit 1
}

function DEBUG_PRINT() {
    [ $MUDPACK_DEBUG ] || return 1
    if [ $# == 0 ]; then
        # read input
        while IFS= read -r line || [ -n "$line" ]; do
            printf >&2 "\033[0;36m[%s] %s\033[0m\n" ${SRC_NAME##*/} "$line"
        done
    elif [ $# == 1 ]; then
        # read string
        printf >&2 '\033[0;36m[%s] %s\033[0m\n' ${SRC_NAME##*/} "$1"
    else
        # read format and args
        printf >&2 "\033[0;36m$1\033[0m" ${@:2}
    fi
}

function DEBUG_PRINT_VAR() {
    [ $MUDPACK_DEBUG ] || return 1
    local -n var=$1
    if [[ ${#var[*]} > 1 ]]; then
        for x in "${!var[@]}"; do DEBUG_PRINT "$1[${x@Q}]=${var[$x]@Q}"; done
    else
        DEBUG_PRINT "$1=${var@Q}"
    fi

}
