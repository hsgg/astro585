#!/Applications/Julia.app/Contents/Resources/julia/bin/julia
# yeah, haven't added julia to my path on this computer
#!/usr/bin/env julia



# 2a
srand(42)
v = rand(2^10)

time = @elapsed println(v)
println("Print to stdout takes ", time, " seconds")


# 2b,c
time = @elapsed writedlm("torvalds.dat", v, '\t')
println("Writing: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading: ", time, " seconds")
# Writing to a file is about 10 times faster.
# Initial reading is slow, but subsequent ones is amazingly fast.

v = rand(2^20)
time = @elapsed writedlm("torvalds.dat", v, '\t')
println("Writing2^20: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading2^20: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading2^20: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading2^20: ", time, " seconds")
# With 1024*1024 floats in an array, there is much less a difference between
# subsequent readings. Presumably the array is now large enough to not be
# cached in any way.
