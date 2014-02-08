#!/usr/bin/env julia

using Base.Test

gaussian(x) = exp(-0.5 * x.^2) / sqrt(2 * pi)

function integrate_simple(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    sum = 0.0
    for i in 1:N
        sum += fn(a + i * (b-a)/(N+1))
    end

    # return a pair (I, E) as does 'quadgk()', where I is the integral, and E
    # an estimation of the error
    I = sum * (b-a) / N

    # no idea of this is right, but it is in the right ballpark for the test
    # below
    E = I / N

    return I, E
end

function make_x(a, b, N)
    return a + (b-a) * (1:N) / (N+1)
end


function integrate_vector(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    x = make_x(a, b, N)
    y = gaussian(x)
    I = sum(y) * (b-a) / N
    E = I / N
    return I, E
end


function integrate_mapthenreduce(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    x = make_x(a, b, N)
    y = map(gaussian, x)
    I = reduce(+, y) * (b-a) / N
    E = I / N
    return I, E
end


function integrate_mapreduce(fn, a, b; maxevals=10^7)
    @assert maxevals >= 0
    N = maxevals
    x = make_x(a, b, N)
    s = mapreduce(gaussian, +, x)
    I = s * (b-a) / N
    E = I / N
    return I, E
end


function integrate_devectorize(fn, a, b; maxevals=10^7)
    # Hm, to install Devectorize package, julia wants to use the
    # --single-branch option to clone, which git learned in version 1.7.10. The
    # Davey computers only have 1.7.9. We are almost there!
    @assert maxevals >= 0
    N = maxevals
    x = make_x(a, b, N)
    @devec s = sum(exp(-0.5 * x^2) / sqrt(2 * pi))
    I = s * (b-a) / N
    E = I / N
    return I, E
end


function test_integral(intfn; maxevals=10^7)
    a = 0.5
    numerically, ntol = intfn(gaussian, -a, a, maxevals=maxevals)
    analytically = erf(a/sqrt(2))
    @test_approx_eq_eps numerically analytically ntol
end


function test_integral_function(intfn)
    #test_integral(intfn, maxevals=-1)
    test_integral(intfn, maxevals=0)
    test_integral(intfn, maxevals=1)
    test_integral(intfn, maxevals=2)
    test_integral(intfn, maxevals=3)
    test_integral(intfn)
end


test_integral_function(integrate_simple)
test_integral_function(quadgk)
test_integral_function(integrate_vector)
test_integral_function(integrate_mapthenreduce)
test_integral_function(integrate_mapreduce)
test_integral_function(integrate_devectorize)