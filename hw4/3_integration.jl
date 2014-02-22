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

    # no idea if this is right, but it is in the right ballpark for the tests
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
#   loop:          0.484841521 sec each heavy,	0.603287741 sec called often
#   quadgk:        0.002404426 sec each heavy,	0.300752033 sec called often
#   vector:        0.335771084 sec each heavy,	0.350315113 sec called often
#   mapthenreduce: 0.904367259 sec each heavy,	0.917444621 sec called often
#   mapreduce:     0.703033884 sec each heavy,	0.655952055 sec called often
#   devectorize:   0.169991816 sec each heavy,	0.249352334 sec called often
#
# Most functions are a little slower when called often as opposed to having
# long loops in them. However, the mapreduce version is slightly faster. The
# comparison with 'quadgk()' is unfair, as it terminates whenever the desired
# tolerance is reached (and it's a different algorithm).

# Profiling devectorize version:
println()
Profile.clear()
@profile time_integral_func(integrate_devectorize, gaussian, maxcalls=10^1, maxevals=10^5)
Profile.print()
#
# 170 boot.jl; include; line: 238
#     170 profile.jl; anonymous; line: 14
#           170 ...4/3_integration.jl; time_integral_func; line: 110
#                 80 ...3_integration.jl; integrate_devectorize; line: 71
#                  80 array.jl; linspace; line: 238
#                 90 ...3_integration.jl; integrate_devectorize; line: 72
#
# Lines 71 and 72 take most of the time. 71 just allocates memory: it is the
# call to 'linspace()'. Line 72 performs the loop. I don't see much potential
# for optimizing the loop, but getting rid of the allocation via 'linspace()'
# would make sense if the function gets called often.

# Profiling vector version:
println()
Profile.clear()
@profile time_integral_func(integrate_vector, gaussian, maxcalls=10^1, maxevals=10^5)
Profile.print()
#
# 306 boot.jl; include; line: 238
#     306 profile.jl; anonymous; line: 14
#           306 ...4/3_integration.jl; time_integral_func; line: 110
#                 82  ...3_integration.jl; integrate_vector; line: 34
#                  1  array.jl; linspace; line: 237
#                  81 array.jl; linspace; line: 238
#                 218 ...3_integration.jl; integrate_vector; line: 35
#                  218 ...3_integration.jl; gaussian; line: 6
#                   9   array.jl; .*; line: 135
#                   1   array.jl; .*; line: 136
#                   1   array.jl; .*; line: 938
#                   41  array.jl; ./; line: 135
#                   3   array.jl; ./; line: 136
#                   1   array.jl; ./; line: 945
#                   45  array.jl; .^; line: 920
#                   117 operators.jl; exp; line: 236
#                 6   ...3_integration.jl; integrate_vector; line: 36
#                  6 abstractarray.jl; sum; line: 1487
#                   6 abstractarray.jl; sum_pairwise; line: 1481
#                    6 abstractarray.jl; sum_pairwise; line: 1481
#                     6 abstractarray.jl; sum_pairwise; line: 1481
#                      6 abstractarray.jl; sum_pairwise; line: 1481
#                       6 abstractarray.jl; sum_pairwise; line: 1481
#                        6 abstractarray.jl; sum_pairwise; line: 1481
#                         6 abstractarray.jl; sum_pairwise; line: 1481
#                          1 ...ractarray.jl; sum_pairwise; line: 1480
#                          5 ...ractarray.jl; sum_pairwise; line: 1481
#                           5 ...ractarray.jl; sum_pairwise; line: 1481
#                            5 ...actarray.jl; sum_pairwise; line: 1481
#                             4 ...actarray.jl; sum_pairwise; line: 135
#                             1 ...actarray.jl; sum_pairwise; line: 1475
#
# Some of the time is spent in 'linspace()' again, but much more time is spent
# in 'gaussian()'. This is likely due to there being some temporary arrays
# copied for intermediate results.
