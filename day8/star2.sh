#!/bin/bash

set -e

dump_mapping() {
    echo "Current mapping:"
    printf "1: %s=%x\n" $rep1 $val1
    printf "2: %s=%x\n" $rep2 $val2
    printf "3: %s=%x\n" $rep3 $val3
    printf "4: %s=%x\n" $rep4 $val4
    printf "5: %s=%x\n" $rep5 $val5
    printf "6: %s=%x\n" $rep6 $val6
    printf "7: %s=%x\n" $rep7 $val7
    printf "8: %s=%x\n" $rep8 $val8
    printf "9: %s=%x\n" $rep9 $val9
    printf "0: %s=%x\n" $rep0 $val0
}

cleanup() {
    echo "failed at ${LINES[$n]}" 1>&2

    dump_mapping
}

trap cleanup ERR

IFS='
'
readarray LINES
unset IFS

error=false

declare -A segmap=(a 0x1 b 0x2 c 0x4 d 0x8 e 0x10 f 0x20 g 0x40)

declare -a revmap
for v in ${!segmap[@]}; do
    k=${segmap[$v]}
    revmap[$k]=$v
done

map_to_bitmap() {
    set -e
    local input=$1
    local value=0
    for l in $(seq 0 $(( ${#input} - 1))); do
	c="${input:$l:+1}"
	let value="$value|${segmap[$c]}"
    done
    echo $value
}

bitmap_to_map() {
    set -e
    local input=$1
    local value=
    for n in $(seq 0 7); do
	k=$(( 1 << $n ))
	v=$(($input & $k))
	if test $v -ne 0; then
	    value="$value${revmap[$k]}"
	fi
    done
    echo $value
    return 0
}

reorder_segs() {
    bitmap_to_map $(map_to_bitmap $1)
}

count=0
lines=0
for n in $(seq 0 $(( ${#LINES[@]} - 1 ))); do
    set -- ${LINES[$n]}

    unset val5s
    unset val6s
    unset rep0 rep1 rep2 rep3 rep4 rep5 rep6 rep7 rep8 rep9
    unset val0 val1 val2 val3 val4 val5 val6 val7 val8 val9

    declare -a val5s
    declare -a val6s

    while test "$#" -gt 0; do
	item=$1
	if test "$item" = "|"; then
	    shift
	    break
	fi

	# 1, 7, 4, and 8 all have unique segment counts
	# The 5 and 6 segment numbers go into array for later disambiguation
	case ${#item} in
	    2)
		val1=$(map_to_bitmap $item)
		rep1=$(bitmap_to_map $val1)
		;;
	    3)
		val7=$(map_to_bitmap $item)
		rep7=$(bitmap_to_map $val7)
		;;
	    4)	val4=$(map_to_bitmap $item)
		rep4=$(bitmap_to_map $val4)
		;;
	    7)	val8=$(map_to_bitmap $item)
		rep8=$(bitmap_to_map $val8)
		;;
	    5) val5s+=($(map_to_bitmap $item)) ;;
	    6) val6s+=($(map_to_bitmap $item)) ;;
	*) ;;
	esac

	shift
    done

    # The 3 is the only 5-segment number that also contains 7
    unset tmpa
    declare -a tmpa
    for item in ${val5s[@]}; do
	v=$(( $item & $val7 ))
	if test "$v" -eq "$val7"; then
	    rep3=$(bitmap_to_map $item)
	    val3=$item
	    continue
	fi
	tmpa+=($item)
    done
    val5s=(${tmpa[@]})

    # The 9 is the only 6-segment number that also contains 3
    # The difference is that the 9 contains the b segment so we can pull
    # that out
    unset tmpa
    declare -a tmpa
    for item in ${val6s[@]}; do
	v=$(( $item & $val3 ))
	if test "$v" -eq "$val3"; then
	    rep9=$(bitmap_to_map $item)
	    val9=$item
	    b=$(bitmap_to_map $(( $val9 & ~$val3 )))
	    continue
	fi
	tmpa+=($item)
    done
    val6s=(${tmpa[@]})

    # The 0 is the only remaining 6-segment number that also contains 1
    unset tmpa
    declare -a tmpa
    for item in ${val6s[@]}; do
	v=$(( $item & $val1 ))
	if test "$v" -eq "$val1"; then
	    rep0=$(bitmap_to_map $item)
	    val0=$item
	    continue
	fi
	tmpa+=($item)
    done
    val6=${tmpa[0]}
    rep6=$(bitmap_to_map $val6)

    # The 5 is the only remaining 5-segment number that uses the b-segment 
    unset tmpa
    declare -a tmpa
    for item in ${val5s[@]}; do
	valb=$(map_to_bitmap $b)
	v=$(( $item & $valb ))
	if test "$v" -eq "$valb"; then
	    rep5=$(bitmap_to_map $item)
	    val5=$item
	    continue
	fi
	tmpa+=($item)
    done

    # The 2 is all that remains
    val2=${tmpa[0]}
    rep2=$(bitmap_to_map $val2)

    unset final_map
    declare -A final_map=($val0 0 $val1 1 $val2 2 $val3 3 $val4 4 $val5 5 $val6 6 $val7 7 $val8 8 $val9 9)

    number=
    for display in "$@"; do
	val=$(map_to_bitmap $display)
	number="$number${final_map[$val]}"
    done

    if test -z "$number"; then
	error=true
    fi

    if $error; then
	for k in ${!final_map[@]}; do
	    printf "%x=%d " $k ${final_map[$k]}
	done
	echo

	for seg in "$@"; do
	    sorted=$(reorder_segs $seg)
	    val=$(map_to_bitmap $sorted)
	    printf "%s %x -> %d\n" $sorted $val ${final_map[$val]}
	done
    fi

    let "count+=10#$number"

    let lines+=1
done
echo total: $count
echo lines: $lines
