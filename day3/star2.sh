#!/bin/bash

bitcount=0
readings=

while read reading; do
    if test $bitcount -eq 0; then
	bitcount=$(( ${#reading} ))
	highbit=$(( $bitcount - 1 ))
    fi
    let "num = 2#$reading"
    readings="$readings $num"
done

filter() {
    local value=$1
    local bit=$2
    shift 2

    local count0=0
    local count1=0
    local filtered=
    local ones=
    local zeroes=
    local count=0

    if test $bit -lt 0; then
	echo "Well this is broken..." >&2
	return
    fi

    for num in "$@"; do
	if test $(( ($num >> $bit) & 1 )) -eq 1; then
	    ones="$ones $num"
	    let count1++
	else
	    zeroes="$zeroes $num"
	    let count0++
	fi
    done

    if test $count1 -ge $count0; then
	if test $value -eq 1; then
	    filtered=$ones
	    count=$count1
	else
	    filtered=$zeroes
	    count=$count0
	fi
    else
	if test $value -eq 1; then
	    filtered=$zeroes
	    count=$count0
	else
	    filtered=$ones
	    count=$count1
	fi
    fi

    if test $count -le 1; then
	echo $filtered
	return
    fi
    filter $value $(( $bit - 1 )) $filtered
}

oxygen=$(filter 1 $highbit $readings)
co2=$(filter 0 $highbit $readings)

echo o2: $oxygen co2: $co2 rating: $(( $oxygen * $co2 ))
