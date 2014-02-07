#!/usr/bin/env julia

require("2_io.jl")
using Base.Test
using HDF5, JLD

# Test different numbers on each run. Be sure to provide the computer with
# entropy, e.g. by moving the mouse.
println("Get entropy...")
srand("/dev/random")
v = rand(2^10)

# test_rw():
#    - This functions tests whether the function 'readfn' reads the data
#      written by 'writefn' faithfully. That is, is it the same, and is it
#      represented the same?
#    - 'v' is any data used for the testing, typically a vector of floats.
#    - 'filename' is the name of a file to write to. It will be left on the
#      disk.
#    - 'approx' determines if small round-off errors are OK.
function test_rw(writefn, readfn, v, filename; approx=false)
    # make absolutely sure we don't just overwrite the array
    vcopy = deepcopy(v)
    writefn(filename, v)
    vread = readfn(filename, vcopy)
    if approx == true
        @test_approx_eq vread v
    else
        @test vread == v
    end
end


function test_iofn(writefn, readfn, v, filename; approx=false, handle_scalars=false)
    shortfn(x) = test_rw(writefn, readfn, x, filename, approx=approx)
    shortfn(v)
    test_rw(writefn, readfn, v, filename, approx=approx)
    if handle_scalars == true
        test_rw(writefn, readfn, 1.0, filename, approx=approx)
    else
        @test_throws test_rw(writefn, readfn, 1.0, filename, approx=approx)
    end
    @test_throws test_rw(writefn, readfn, None, filename, approx=approx)
end

asciiwritefn(filename, v) = writedlm(filename, v, '\t')
asciireadfn(filename, v) = readdlm(filename, '\t', Float64)

# 3a
println("# 3a")
test_iofn(asciiwritefn, asciireadfn, v, "torvalds.dat", approx=true, handle_scalars=true)
println("ASCII success! (with approximation)")

test_iofn(writebin, readbin!, v, "wozniak.bin", approx=false)
println("Binary success! (exact)")

hdf5writefn(filename, v) = @save filename v
function hdf5readfn(filename::String, v)
    using HDF5, JLD
    # The following line doesn't like me. Why? Because the function
    # 'jdlopen(Symbol)', which is called inside '@load', does not exist. It
    # seems to be something about the fact that the argument to 'jdlopen()' is
    # a 'Symbol', but I am not sure why this would suddenly make a difference.
    # I already said that 'filename' is a String?
    @load filename
end

test_iofn(hdf5writefn, hdf5readfn, v, "holy.jld")
println("HDF5 success! (exact)")
