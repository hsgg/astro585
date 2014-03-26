#!/usr/global/julia/121613/usr/bin/julia
## First line specifies what program (e.g. bash, tcsh, julia) will be used to process this script.  
## When using julia specify full path to julia, since it's normally loaded as a module 

#PBS -l nodes=3            # this requests 3 processor cores which may be spread across multiple nodes
###PBS -l nodes=1:ppn=3    # if uncommented, this requests 8 processor cores on a single node
#PBS -l walltime=0:05:00   # specifies a maximum run time in format of hh:mm:ss
#PBS -l pmem=1gb           # this requests 1GB of memory per process
#PBS -j oe                 # combine the stdout and stderr into one file
#PBS -m abe                # send email on abort, begin or exit
#PBS -M hsg113@psu.edu     # send email to this address
 
# module load julia        # since we've already started julia directly, no point

println("# Julia started in directory: ",pwd())
# cd $PBS_O_WORKDIR
cd(ENV["PBS_O_WORKDIR"])   # change into the directory from which the script was submitted
                           # if doing significant disk I/O, remember to use a local or scratch disk
println("# Julia is now in directory: ",pwd())

include("/gpfs/home/ebf11/public/pbs.jl")   # Some functions to help with pbs jobs

# setup for a parallel  job
check_pbs_tasknum_one()
proclist = addprocs_pbs()
print_node_status()

# test that can use tasks on all workers
println("# Julia says welcome from master proc ",myid()," w/ hostname ",gethostname() ) 
for proc in proclist
  println("# Julia says welcome from worker proc ",proc," w/ hostname ",fetch(@spawnat(proc,gethostname())) ) 
  flush_cstdio()
end


# OK, start in earnest
include(string(ENV["PBS_O_WORKDIR"], "/HW7_Q1_funcs.jl"))

timeloop, timemap = time_int_normal_pdf_functions()

println("timeloop: ", timeloop, " seconds")
println("timemap:  ", timemap, " seconds")
