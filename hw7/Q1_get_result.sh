#!/bin/sh

MAX=8

get_nworkers() {
	local fname="$1"
	grep nworkers "$fname" | awk '{print $3}'
}

get_timeloop() {
	local fname="$1"
	grep timeloop "$fname" | awk '{print $2}'
}

get_timemap() {
	local fname="$1"
	grep timemap "$fname" | awk '{print $2}'
}


retrieve_diffnodes() {
	for i in `seq 1 $MAX`; do
		fname="q1_${i}_1.out"
		procs=`get_nworkers "$fname"`
		timeloop=`get_timeloop "$fname"`
		timemap=`get_timemap "$fname"`
		echo $procs $timeloop $timemap
	done
}

retrieve_samenode() {
	for i in `seq 1 $MAX`; do
		fname="q1_1_${i}.out"
		procs=`get_nworkers "$fname"`
		timeloop=`get_timeloop "$fname"`
		timemap=`get_timemap "$fname"`
		echo $procs $timeloop $timemap
	done
}

retrieve_anynode() {
	for i in `seq 1 $MAX`; do
		fname="q1_${i}.out"
		procs=`get_nworkers "$fname"`
		timeloop=`get_timeloop "$fname"`
		timemap=`get_timemap "$fname"`
		echo $procs $timeloop $timemap
	done
}

retrieve_diffnodes > q1_diffnodes.dat
retrieve_samenode > q1_samenode.dat
retrieve_anynode > q1_anynode.dat
