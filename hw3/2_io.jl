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
println("\nWriting to a file is about 10 times faster than to writing to
stdout. Initial reading is slow, but subsequent ones are amazingly fast,
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
seems odd. Possibly the 'read()' call does some buffer management that the HDF5
library can avoid with more information.")

# 2f
println("\n# 2f")
println("The ASCII format will have to read all elements, because each element
has a different length, and we need to find the delimiters. The pure binary
format will probably be fastest, since I would just calculate the position of
the relevant element (i * sizeof(Float64)) and then seek to it. HDF5 might be
as fast as the pure binary format, but I imagine that it would first read the
beginning of the file to find out the structure of the file, and then seek to
the relevant position.")

# 2g
println("\n# 2g")
println("ASCII is human readable, and human editable. However, the simple
version used in this homework I would never use in any serious work, as it is
too easy to confuse what each number means. ASCII in general is not useful for
storing large amounts of data, as it takes more than twice as much space, and
is significantly slower. It may also loose some precision when converting to a
decimal representation. However, it may be useful for small data tables.

Using a pure binary file is simple, but not so great, since the precise format
is easily forgotten, and may change depending on which machine you run it.

HDF5 seems nice for large data sets, but as for the pure binary format you will
need a program to read and edit it, so I would not use it for configuration or
parameter files. It is likely precisely enough defined to be the same no matter
what machine you run your program on.")

# 2h
# Interesting stuff first...
println("\n# 2h")
using YAML
println("The file 'knuth.yaml' was created with './2_makeyaml.py > knuth.yaml',
because yaml for julia cannot yet write a YAML file at this time.")
time = @elapsed YAML.load(open("knuth.yaml"))
println("Reading2^10 in YAML: ", time, " seconds")
time = @elapsed YAML.load(open("knuth.yaml"))
println("Reading2^10 in YAML: ", time, " seconds")

println("\nAt this time, YAML is not a serious contender for storing any amount
of data. Besides the first read time being, uhm, slow, the table is not really
human readable. However, it looks like a really nice configuration file
format.")
