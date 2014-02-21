#!/usr/bin/env julia

# Calculate a normalized Gaussian. Write it in this odd way, so we can see the
# profiler output better
function log_Gaussian(z, y, sigma)
    tmp1 = y - z
    tmp1 /= sigma
    tmp1 = tmp1.^2
    tmp1 *= -0.5
    tmp2 = sqrt(2 * pi)
    tmp2 *= sigma
    tmp2 = log(tmp2)
    tmp1 -= tmp2
    return tmp1
end

function log_likelihood(log_pdf, y::Array, sigma::Array, z::Array)
    n = length(y)
    @assert n == length(sigma)
    @assert n == length(z)
    sum = zero(y[1])
    for i in 1:n
        a = y[i]
        b = z[i]
        c = sigma[i]
        tmp = log_pdf(a, b, c)
        sum += tmp
    end
    return sum
end

# make data:
Nobs = 100
srand(42)
z = zeros(Nobs)
sigma = 2. * ones(Nobs)
y = z + sigma .* randn(Nobs)

# profile:
Profile.clear()
time = @elapsed @profile (for i in 1:10^5;
        log_likelihood(log_Gaussian, y, sigma, z);
    end)
println("Time elapsed: ", time, " seconds")
Profile.print()

# I expect the function calls to take the most time, and so they are called the
# most often by the profiler:

# Unfortunately, the the julia does not appear to inline the call to
# 'log_Gaussian()'. This would be nice. Indeed, inlineing it by hand results in
# a 5x speedup.
# 
# Another way to speed it up would be to not loop in 'log_likelihood()', but
# use vectors in 'log_Gaussian()'. This might work, and also reduce the number
# of function calls to 'log()', but it could lead to many spurious memory
# allocations.
# 
# Let's try that:
function log_likelihood_vec(log_pdf, y::Array, sigma::Array, z::Array)
    n = length(y)
    @assert n == length(sigma)
    @assert n == length(z)
    s = log_pdf(y, z, sigma)
    sum = sum(s)
    return sum
end

Profile.clear()
time = @elapsed @profile (for i in 1:10^5;
        log_likelihood_vec(log_Gaussian, y, sigma, z);
    end)
println("Time elapsed: ", time, " seconds")
Profile.print()
