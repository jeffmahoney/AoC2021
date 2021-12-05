#!/bin/bash

# Uses a square grid of points, all defined.
# A 2d array represented as a 1d array of $SIZE**2 elements.
# It is slow.

SIZE=1000
MAX=$(( $SIZE - 1 ))

declare -a GRID

for n in $(seq 0 $(( $SIZE ** 2 ))); do
    GRID[$n]=0
done

mark_point() {
    local x=$1
    local y=$2
    local pos=$(( $y * $SIZE + $x ))
    let GRID[$pos]++
}

tabulate_grid() {
    local print=false
    if test -n "$1" -a "$1" = "true"; then
        print=true
    fi
    count=0
    for y in $(seq 0 $MAX); do
        for x in $(seq 0 $MAX); do
            pos=$(( $y * $SIZE + $x))
            val=${GRID[$pos]}
            if test $val -ne 0; then
                $print && echo -n $val
                if test $val -gt 1; then
                    let count++
                fi
            else
                $print && echo -n .
            fi
        done
        $print && echo
    done

    echo "$count with > 2"
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

tabulate_grid
