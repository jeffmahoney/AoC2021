#!/bin/bash

IFS='
'
readarray LINES
unset IFS

count=0
for n in $(seq 0 $(( ${#LINES[@]} - 1 ))); do
    set -- ${LINES[$n]}
    while test "$#" -gt 0; do
	item=$1
	if test "$item" = "|"; then
	    shift
	    break
	fi
	shift
    done

    for display in "$@"; do
	case "${#display}" in
	2|3|4|7) let count++ ;;
	*) ;;
	esac
    done
done
echo total: $count
