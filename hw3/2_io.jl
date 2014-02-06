#!/usr/bin/env julia
#!/Applications/Julia.app/Contents/Resources/julia/bin/julia
# yeah, haven't added julia to my path on mac



# 2a
srand(42)
v = rand(2^10)

time = @elapsed println(v)
println("# 2a")
println("Print to stdout takes ", time, " seconds")


# 2b,c
println("\n# 2b,c")
time = @elapsed writedlm("torvalds.dat", v, '\t')
println("Writing: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading: ", time, " seconds")
println("\nWriting to a file is about 10 times faster than to writing to stdout.
Initial reading is slow, but subsequent ones are amazingly fast,
probably because julia (and the OS) caches the read.\n")

v = rand(2^20)
time = @elapsed writedlm("torvalds.dat", v, '\t')
println("Writing2^20: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading2^20: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading2^20: ", time, " seconds")
time = @elapsed readdlm("torvalds.dat", '\t', Float64)
println("Reading2^20: ", time, " seconds")
println("\nYeah, cache ain't big enough no more.")


# 2d
println("\n# 2d")
function writebin(filename::String, v::Array)
    # ignore error handling
    stream = open(filename, "w")
    write(stream, v)
    close(stream)
end
function readbin!(filename::String, v::Array)
    stream = open(filename, "r")
    v[:] = read(stream, typeof(v[0]), length(v))
    close(stream)
    return v
end

time = @elapsed writebin("wozniak.bin", v)
println("Writing2^20 in binary: ", time, " seconds")
time = @elapsed readbin!("wozniak.bin", v)
println("Reading2^20 in binary: ", time, " seconds")
time = @elapsed readbin!("wozniak.bin", v)
println("Reading2^20 in binary: ", time, " seconds")
time = @elapsed readbin!("wozniak.bin", v)
println("Reading2^20 in binary: ", time, " seconds")

println("\nASCII file size: ", stat("torvalds.dat").size / 2^20, " MB")
println("Binary file size: ", stat("wozniak.bin").size / 2^20, " MB")

println("\nSmaller, meaner, faster!")


# 2e
println("\n# 2e")
using HDF5, JLD
@load "holy.jld"
time = @elapsed @save "holy.jld" v
println("Writing2^20 in hdf5: ", time, " seconds")
time = @elapsed @save "holy.jld" v
println("Writing2^20 in hdf5: ", time, " seconds")
time = @elapsed @load "holy.jld"
println("Reading2^20 in hdf5: ", time, " seconds")
time = @elapsed @load "holy.jld"
println("Reading2^20 in hdf5: ", time, " seconds")
time = @elapsed @load "holy.jld"
println("Reading2^20 in hdf5: ", time, " seconds")

println("\nHDF5 file size: ", stat("holy.jld").size / 2^20, " MB")

println("\nWriting is slower than pure binary, but reading is faster, which
seems odd. Possibly the 'read()' call does some buffer management
that the HDF5 library can avoid with more information.")
