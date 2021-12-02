#!/bin/bash

last=
count=0
while read reading; do
    if test -n "$last"; then
	if test "$reading" -gt "$last"; then
	    let count++
	fi
    fi
    last="$reading"
done

echo $count
