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

declare -a fuelmap
fuelmap[0]=0
max=${sorted[-1]}
for n in $(seq 1 $max); do
    let fuelmap[$n]=${fuelmap[$(( $n - 1 ))]}+$n
done

calculate_fuel_use() {
    local target=$1

    total_fuel=0
    for n in ${initial[@]}; do
	move=0
	if test $n -lt $target; then
	    let move=$(( $target - $n ))

	elif test $n -gt $target; then
	    let move=$(( $n - $target ))
	fi
	let fuel=${fuelmap[$move]}
	let total_fuel+=$fuel
    done
    echo $total_fuel
}

mean=$(( $total / $count ))
floor=$(calculate_fuel_use $mean)
ceil=$(calculate_fuel_use $((mean + 1)))

if test "$floor" -gt "$ceil"; then
    echo "$(( $mean + 1 )): $ceil"
else
    echo "$mean: $floor"
fi
