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

clear_board() {
    local start=$(( ($1 / 10) * 10 ))

    for rownum in $(seq $start $(( $start + 9 ))); do
	WINNERS[$rownum]=
    done

    let boardnum--
}

while read_board; do
    echo -n
done
count=0
for num in ${numbers[@]}; do
    n=$(printf "%02d" $num)
    cleared=false
    for rownum in $(seq 0 $(( ${#WINNERS[@]} - 1 ))); do
	if $cleared; then
	    if test $(( $rownum % 10)) -ne 0; then
		continue
	    fi 
	    cleared=false
	fi

	row=${WINNERS[$rownum]}
	if test $(( $rownum % 10 )) -eq 0; then
	    if test -z "$row"; then
		col=${WINNERS[$(( $rownum + 5 ))]}
		if test -z "$col"; then
		    cleared=true
		    continue
		fi
	    fi
	fi

	row=${row/$n/}
	WINNERS[$rownum]=$row
	row=${row// }
	if test -z "$row"; then
	    board=$(( ($rownum / 10) ))
	    echo "Board $board won a round on $num"
	    if test "$boardnum" -eq 1; then
		WINNUM=$num
		break 2
	    fi
	    clear_board $rownum
	    cleared=true
	fi
    done
    let count++
done

total=0
for rownum in $(seq 0 $(( ${#WINNERS[@]} - 1 ))); do
    row=${WINNERS[$rownum]}
    if test -z "$row"; then
	continue
    fi
    end=$(( ($rownum / 10) * 10 + 5 ))
    if test $rownum -eq $end; then
	break
    fi
    for num in $row; do
	let "num = 10#$num"
	total=$(( $total + $num ))
    done
done
echo "Sum: $total"
echo "Winning number: $WINNUM"
echo "Puzzle result: $(( $total * $WINNUM ))"
