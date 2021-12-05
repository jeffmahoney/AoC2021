#!/bin/bash

declare -a WINNERS	# indexed as boardnum * 10 + row

oIFS=$IFS
IFS=,
read -a numbers
IFS=$oIFS

boardnum=0
read_board() {
    local allnums=
    local cols=()
    local winners=()
    local base=$(( $boardnum * 10 ))

    for row in $(seq 0 4); do
	vals=
	while test -z "$vals"; do
	    read -a vals || return 1
	done
	for col in $(seq 0 $(( ${#vals[@]} - 1 ))); do
	    vals[$col]=$(printf "%02d" ${vals[$col]})
	    cols[$col]="${cols[$col]} ${vals[$col]}"
	done

	WINNERS[$(( $base + $row ))]=${vals[@]}
    done
    for col in $(seq 0 4); do
	row=$(( $base + $col + 5 ))
	WINNERS[$row]="${cols[$col]}"
    done
    let boardnum++
    return 0
}

while read_board; do
    echo -n
done
count=0
for num in ${numbers[@]}; do
    n=$(printf "%02d" $num)
    for rownum in $(seq 0 $(( ${#WINNERS[@]} - 1 ))); do
	row=${WINNERS[$rownum]}
	row=${row/$n/}
	WINNERS[$rownum]=$row
	row=${row// }
	if test -z "$row"; then
	    WINNER=$rownum
	    WINNUM=$num
	    break 2
	fi
    done
    let count++
done

if test -n "$WINNER"; then
    start=$(( ($WINNER / 10) * 10 ))
    echo "Board $(( $start / 10 )) wins!"
    total=0
    for rownum in $(seq $start $(( $start + 4 ))); do
	for num in ${WINNERS[$rownum]}; do
	    let "num = 10#$num"
	    total=$(( $total + $num ))
	done
    done
    echo "Sum: $total"
    echo "Winning number: $WINNUM"
    echo "Puzzle result: $(( $total * $WINNUM ))"
fi
