#!/bin/bash

declare -a WINDOW

last=
count=0
while read reading; do
    index=${#WINDOW[@]}
    WINDOW[$index]=$reading
    if test "$index" -lt 3; then
	if test "$index" -eq 2; then
	    last=$(( ${WINDOW[0]} + ${WINDOW[1]} + ${WINDOW[2]} ))
	fi
	continue
    fi

    WINDOW=(${WINDOW[@]:1})
    current=$(( ${WINDOW[0]} + ${WINDOW[1]} + ${WINDOW[2]} ))
    
    if test "$current" -gt "$last"; then
	let count++
    fi
    last="$current"
done

echo $count
