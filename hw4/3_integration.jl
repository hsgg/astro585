#!/usr/bin/env julia

using Base.Test
using Devectorize

gaussian(x) = exp(-0.5 * x.^2) / sqrt(2 * pi)


# integrate_loop():
#    - Calculates the integal from 'a' to 'b' of the function 'fn(x)', using no
#      more than 'maxevals' function evaluations.
#    - Returns a pair (I, E) similar to 'quadgk()', where I is the integral,
#      and E an estimation of the error.
function integrate_loop(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    sum = 0.0
    dx = (b-a)/(N+1)
    for i in 1:N
        sum += fn(a + i * dx)
    end
    I = sum * (b-a) / N

    # no idea of this is right, but it is in the right ballpark for the test
    # below
    E = I / N

    return I, E
end


function integrate_vector(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    x = linspace(a, b, N)
    y = gaussian(x)
    I = sum(y) * (b-a) / N
    E = I / N
    return I, E
end


function integrate_mapthenreduce(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    x = linspace(a, b, N)
    y = map(gaussian, x)
    I = reduce(+, y) * (b-a) / N
    E = I / N
    return I, E
end


function integrate_mapreduce(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    x = linspace(a, b, N)
    s = mapreduce(gaussian, +, x)
    I = s * (b-a) / N
    E = I / N
    return I, E
end


function integrate_devectorize(fn, a, b; maxevals=10^7)
    # Hm, to install Devectorize package, julia wants to use the
    # --single-branch option to git clone, which git learned in version 1.7.10.
    # The Davey computers only have 1.7.9. We are almost there!
    # Doing this on my laptop now...
    @assert maxevals >= 0
    N = maxevals
    x = linspace(a, b, N)
    @devec s = sum(exp(-0.5 .* x.^2) ./ sqrt(2 .* pi))
    I = s * (b-a) / N
    E = I / N
    return I, E
end


function test_integral(intfn; maxevals=10^7)
    a = 0.5
    numerically, ntol = intfn(gaussian, -a, a, maxevals=maxevals)
    analytically = erf(a/sqrt(2))
    @test_approx_eq_eps numerically analytically ntol
    if maxevals >= 10^3
        @test_approx_eq_eps ntol 0.0 1e-4
    elseif maxevals >= 10^6
        @test_approx_eq_eps ntol 0.0 1e-8
    end
end


function test_integral_function(intfn)
    # test at least one odd case
    @test_throws intfn(-0.3, 0.4, maxevals=-1)

    # test the results
    test_integral(intfn, maxevals=0)
    test_integral(intfn, maxevals=1)
    test_integral(intfn, maxevals=2)
    test_integral(intfn, maxevals=3)
    test_integral(intfn, maxevals=10^4)
    test_integral(intfn, maxevals=10^6)
end

function time_integral_func(intfn, integrandfn;
        maxcalls=10^2, maxevals=10^4)
    a = -0.3
    b = 0.6
    time = @elapsed for i in 1:maxcalls
        numerically, tol = intfn(integrandfn, a, b, maxevals=maxevals)
    end
    return time
end

function run_timing_test(name, intfn, integrandfn)
    time1 = time_integral_func(intfn, integrandfn, maxcalls=10^2, maxevals=10^4)
    time2 = time_integral_func(intfn, integrandfn, maxcalls=10^4, maxevals=10^2)
    s = ^(" ", 13 - length(name)) # 13 is the longest name
    println(name, ": ", s, time1, " sec each heavy,\t",
                time2, " sec called often")
end


println("Run tests...")
test_integral_function(integrate_loop)
test_integral_function(quadgk)
test_integral_function(integrate_vector)
test_integral_function(integrate_mapthenreduce)
test_integral_function(integrate_mapreduce)
test_integral_function(integrate_devectorize)
println("All tests passed.")


run_timing_test("loop", integrate_loop, gaussian)
run_timing_test("quadgk", quadgk, gaussian)
run_timing_test("vector", integrate_vector, gaussian)
run_timing_test("mapthenreduce", integrate_mapthenreduce, gaussian)
run_timing_test("mapreduce", integrate_mapreduce, gaussian)
run_timing_test("devectorize", integrate_devectorize, gaussian)


# Result before optimizing anything:
#
#   Testing...
#   All tests passed.
#   loop:          0.595304462 sec each heavy,	0.629019717 sec called often
#   quadgk:        0.002727372 sec each heavy,	0.342643327 sec called often
#   vector:        0.375237349 sec each heavy,	0.381191879 sec called often
#   mapthenreduce: 0.954187077 sec each heavy,	0.964943613 sec called often
#   mapreduce:     0.796831646 sec each heavy,	0.70804807 sec called often
#   devectorize:   0.296372564 sec each heavy,	0.370756402 sec called often
#
# Most functions are a little slower when called often as opposed to having
# long loops in them. Interestingly, the mapreduce version is faster, however.
# The comparison with 'quadgk()' is unfair, as it terminates whenever the
# desired tolerance is reached.
