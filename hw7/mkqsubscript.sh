#!/bin/sh

MAX=8

elementary_script() {
	echo '#!/bin/sh'
	echo
	for i in `seq 1 $MAX`; do
		echo "qsub -l nodes=$i:ppn=1 -o q1_${i}_1.out HW7_Q1.jl"
	done
	echo
	for i in `seq 1 $MAX`; do
		echo "qsub -l nodes=1:ppn=$i -o q1_1_${i}.out HW7_Q1.jl"
	done
	echo
	for i in `seq 1 $MAX`; do
		echo "qsub -l nodes=$i -o q1_${i}.out HW7_Q1.jl"
	done
}


elementary_script | sort -u | awk 'NF'
