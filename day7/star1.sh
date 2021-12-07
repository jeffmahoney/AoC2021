#!/bin/bash

oIFS=$IFS
IFS=,
read -a initial
IFS=$oIFS

total=0
count=0
for n in ${initial[@]}; do
    let count++
    let total+=$n
done

IFS=$'\n'
sorted=($(sort -n <<<"${initial[*]}"))
IFS=$oIFS

median=${sorted[$(( $count / 2 ))]}

fuel=0
for n in ${initial[@]}; do
    if test $n -lt $median; then
	let fuel+=$(( $median - $n ))

    elif test $n -gt $median; then
	let fuel+=$(( $n - $median ))
    fi
done

echo $fuel
