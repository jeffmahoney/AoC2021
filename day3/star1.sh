#!/bin/bash

declare -a BITS

count=0
gamma=0
highbit=0
bitcount=0

while read reading; do
    let "num = 2#$reading"
    if test $highbit -eq 0; then
	bitcount=$(( ${#reading} ))
	highbit=$(( $bitcount - 1 ))
    fi
    for bit in $(seq 0 $highbit); do
	if test $(( $num & (1 << $bit) )) -ne 0; then
	    let BITS[$bit]++
	fi
    done
    let count++
done

half=$(( $count / 2 ))
for bit in $(seq 0 $highbit); do
    if test ${BITS[$bit]} -gt $half; then
	gamma=$(( $gamma | ( 1 << $bit ) ))
    fi
done

ones=$(( (2 ** $bitcount) - 1 ))
epsilon=$(( $ones ^ $gamma ))

echo $(( $gamma * $epsilon ))
