#!/bin/sh

maxcol=5
if test $# = 1; then
	maxcol=6
fi

parser() {
	column=0
	while read line; do
		# getting size?
		tmp="`echo "$line" | grep ===`"
		if test $? == 0; then
			x="`echo $line | cut -d' ' -f2`"
			column="`echo $column + 1 | bc`"
			echo -n $x
		fi

		# get times
		tmp="`echo $line | grep "elapsed time:"`"
		if test $? == 0; then
			column="`echo $column + 1 | bc`"
			y="`echo $line | cut -d' ' -f3`"
			echo -n "	$y"
		fi

		# end line
		if test $column = $maxcol; then
			column=0
			echo
		fi
	done
}

awkscript='{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" ($2 + $3 + $4 + $5)}'
awkscript_gpu='{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" ($2 + $3 + $4)}'
if test $# = 1; then
	awkscript="$awkscript_gpu"
fi

parser | awk "$awkscript"
