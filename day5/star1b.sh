#!/bin/bash

# Uses an associative array to represent only the points with nonzero values

declare -A POINTS

mark_point() {
    local x=$1
    local y=$2
    local pos="$x,$y"

    val=${POINTS[$pos]}
    if test -z "$val"; then
	POINTS[$pos]=1
    else
	let POINTS[$pos]++
    fi
}

count_points() {
    local print=false
    if test -n "$1" -a "$1" = "true"; then
        print=true
    fi
    count=0
    total_points=0
    for point in "${!POINTS[@]}"; do
	val=${POINTS[$point]}
	if test $val -gt 1; then
	    let count++
	fi
	let total_points++
    done
    echo $count of $total_points
}

while read start placeholder end; do
	x1=${start%%,*}
	y1=${start##*,}
	x2=${end%%,*}
	y2=${end##*,}
	xdist=0
	ydist=0
	if test "$x1" = "$x2"; then
            x=$x1
            incr=1
            if test "$y2" -lt "$y1"; then
                incr=-1
            fi
            for y in $(seq $y1 $incr $y2); do
                mark_point $x1 $y
            done

	elif test "$y1" = "$y2"; then
            y=$y1
            incr=1
            if test "$x2" -lt "$x1"; then
                incr=-1
            fi
            for x in $(seq $x1 $incr $x2); do
                mark_point $x $y1
            done
	else
            continue
	fi
done

count_points
