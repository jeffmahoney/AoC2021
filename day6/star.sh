#!/bin/bash

fish=(0 0 0 0 0 0 0 0 0)

days=$1

if test -z "$days"; then
   echo "Need days" >&2
   exit 1
fi

let days--

oIFS=$IFS
IFS=,
read -a initial_fish
IFS=$oIFS

for n in ${initial_fish[@]}; do
    let fish[$n]++
done

for day in $(seq 0 $days); do
    zero=${fish[0]}
    fish=(${fish[@]:1})
    let fish[8]=$zero
    let fish[6]+=$zero
done

count=0
for n in $(seq 0 8); do
    let count+=${fish[$n]}
done

echo $count
