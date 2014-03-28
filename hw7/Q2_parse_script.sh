#!/bin/sh


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
		if test $column = 5; then
			column=0
			echo
		fi
	done
}


parser < q2.out > q2.dat
