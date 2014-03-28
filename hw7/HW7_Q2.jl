#!/usr/bin/env julia


include("HW7_Q2_setup.jl")
include("HW7_Q2_funcs.jl")

ctx = init_cuda()
md = load_functions()


function run(n::Integer = 128)
	println("=== 128")
	int_normal_gpu(-1.0, 1.0, 128)
end


run(128)
run(1024)
run(16 * 1024)
run(128 * 1024)
run(1024 * 1024)
run(16 * 1024 * 1024)


unload_functions(md)
close_cuda(ctx)
