#!/bin/bash

depth=0
aim=0
total_distance=0

while read direction distance; do
    case "$direction" in
    forward)
	total_distance=$(( $total_distance + $distance ))
	depth=$(( $depth + ( $aim * $distance ) ))
	;;
    up)
	aim=$(( $aim - $distance )) ;;
    down)
	aim=$(( $aim + $distance )) ;;
    *)
    	echo "Weird direction... $direction" ;;
    esac
done

echo $(( $depth * $total_distance ))
