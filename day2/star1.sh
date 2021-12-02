#!/bin/bash

depth=0
total_distance=0

while read direction distance; do
    case "$direction" in
    forward)
	total_distance=$(( $total_distance + $distance )) ;;
    up)
	depth=$(( $depth - $distance )) ;;
    down)
	depth=$(( $depth + $distance )) ;;
    *)
    	echo "Weird direction... $direction" ;;
    esac
done

echo $(( $depth * $total_distance ))
