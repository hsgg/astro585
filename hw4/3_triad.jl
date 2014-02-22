#!/usr/bin/env julia

# I predict that the last twisted one would be fastest as it avoids branches
# ('abs()' better be implemented branch-less). Twist1 is likely the slowest, as
# the branch could go either way, with little predicting being possible. I
# don't expect too much variability depending on the vector size, except for
# twist2, as it needs to loop through them twice, and so would be much slower
# for large sizes.
#
# For 50% positive/negative: Little prediction possible, twist3 fastest.
# For all positive: Branch prediction should work well, twist2 slowest, not
# much difference otherwise.
# For all negative: The same as all positive.
# For 90% positive: Twist2 probably wouldn't be too bad, but not the fastest
# either.
#
# I predict twist3 to be the best in almost all situations, provided that
# 'abs()' does not incur a function call, and that it is implemented without
# branches.

function triad(b::Vector, c::Vector, d::Vector)
    assert(length(b)==length(c)==length(d))
    a = similar(b)
    for i in 1:length(a)
        a[i] = b[i] + c[i] * d[i]
    end
    return a
end

function triad_twist1(b::Vector, c::Vector, d::Vector)
    assert(length(b)==length(c)==length(d))
    a = similar(b)
    for i in 1:length(a)
        if c[i]<0. 
            a[i] = b[i] - c[i] * d[i]
        else 
            a[i] = b[i] + c[i] * d[i]
        end
    end
    return a
end

function triad_twist2(b::Vector, c::Vector, d::Vector)
    assert(length(b)==length(c)==length(d))
    a = similar(b)
    for i in 1:length(a)
        if c[i]<0. 
            a[i] = b[i] - c[i] * d[i]
        end
    end
    for i in 1:length(a)
        if c[i]>0. 
            a[i] = b[i] + c[i] * d[i]
        end
    end
    return a
end

function triad_twist3(b::Vector, c::Vector, d::Vector)
    assert(length(b)==length(c)==length(d))
    a = similar(b)
    for i in 1:length(a)
        cc = abs(c[i])
        a[i] = b[i] + cc * d[i]
    end
    return a
end


###### benchmark stuff
function make_data(Nobs::Int)
    srand(4242424242)
    b = randn(Nobs)
    c = randn(Nobs)
    d = randn(Nobs)
    return b, c, d
end

function time_func(name, fn, b, c, d)
    t = @elapsed fn(b, c, d)
    s = ^(" ", 13 - length(name)) # 13 is the longest name
    println(name, ": ", s, t, " sec")
end


data = make_data(10^7)

time_func("triad", triad, data...)
time_func("triad_twist1", triad_twist1, data...)
time_func("triad_twist2", triad_twist2, data...)
time_func("triad_twist3", triad_twist3, data...)

# triad:         0.28133741 sec
# triad_twist1:  0.413410574 sec
# triad_twist2:  0.635552881 sec
# triad_twist3:  0.283048662 sec
#
# ...as predicted.


###### profile stuff
function profile_func(name, fn, b, c, d)
    Profile.clear()
    @profile fn(b, c, d)
    println()
    println(name, ":")
    Profile.print()
end

profile_func("triad", triad, data...)
profile_func("triad_twist1", triad_twist1, data...)
profile_func("triad_twist2", triad_twist2, data...)
profile_func("triad_twist3", triad_twist3, data...)

# triad:
# 263 boot.jl; include; line: 238
#          263 ...comp/hw4/3_triad.jl; profile_func; line: 14
#            35  ...omp/hw4/3_triad.jl; triad; line: 24
#            228 ...omp/hw4/3_triad.jl; triad; line: 25
# 
# triad_twist1:
# 380 boot.jl; include; line: 238
#          380 ...comp/hw4/3_triad.jl; profile_func; line: 14
#            25  ...omp/hw4/3_triad.jl; triad_twist1; line: 33
#            20  ...omp/hw4/3_triad.jl; triad_twist1; line: 34
#            111 ...omp/hw4/3_triad.jl; triad_twist1; line: 35
#            224 ...omp/hw4/3_triad.jl; triad_twist1; line: 37
# 
# triad_twist2:
# 594 boot.jl; include; line: 238
#          594 ...comp/hw4/3_triad.jl; profile_func; line: 14
#            55  ...omp/hw4/3_triad.jl; triad_twist2; line: 46
#            47  ...omp/hw4/3_triad.jl; triad_twist2; line: 47
#            225 ...omp/hw4/3_triad.jl; triad_twist2; line: 48
#            66  ...omp/hw4/3_triad.jl; triad_twist2; line: 51
#            52  ...omp/hw4/3_triad.jl; triad_twist2; line: 52
#            136 ...omp/hw4/3_triad.jl; triad_twist2; line: 53
#            13  ...omp/hw4/3_triad.jl; triad_twist2; line: 56
# 
# triad_twist3:
# 263 boot.jl; include; line: 238
#          263 ...comp/hw4/3_triad.jl; profile_func; line: 14
#            23  ...omp/hw4/3_triad.jl; triad_twist3; line: 62
#            28  ...omp/hw4/3_triad.jl; triad_twist3; line: 63
#            212 ...omp/hw4/3_triad.jl; triad_twist3; line: 64
#
# The computation line generally is hit the same number of times for each,
# except for the twist1 and twist2 implementations, where the sum of the two
# computational lines is much greater. This could be explained by the fact that
# branch mis-prediction by the CPU could have the processor spend time in that
# line even when it is not being executed. That's the best explanation I have
# right now.
