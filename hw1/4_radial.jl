#!/usr/bin/env julia


# 4a
function make_data(N, sigma_i)
    srand(42)
    sigma = sigma_i * ones(Float64, N)
    z = zeros(Float64, N)
    y = z + sigma .* randn(N)
    return y, sigma, z
end

# 4b
prob(y, s, z) = exp(-(y - z)^2 / (2. * s^2)) / sqrt(2. * pi * s^2)

# 4c and 4e
function loglikelihood(y::Array, sigma::Array, z::Array)
    loglik = -(y .- z).^2 ./ (2 .* sigma.^2)
    loglik += -0.5 .* log(2 .* pi .* sigma.^2)
    return sum(loglik)
end
likelihood(y, sigma, z) = exp(loglikelihood(y, sigma, z))

# 4d
y, sigma, z = make_data(100, 2.0)
println("likelihood_100 = ", likelihood(y, sigma, z))

y, sigma, z = make_data(600, 2.0)
println("likelihood_600 = ", likelihood(y, sigma, z))

# result is:
#    likelihood_100 = 5.5062907091007076e-95
#    likelihood_600 = 0.0
# This makes sense. Each data point has probability ~0.1, so 100 of them
# are ~10^(-100), and 600 of them ~10^(-600), which underflows the Float64.

# 4e
function nongauss_loglikelihood(y, probfunc, probfunc_args, z)
    loglik = 0.0
    n = length(y)
    for i in 1:n
        loglik += log(probfunc(y[i], probfunc_args[i], z[i]))
    end
    return loglik
end
println("loglikelihood_100 = ", loglikelihood(make_data(100, 2.0)...))
println("loglikelihood_600 = ", loglikelihood(make_data(600, 2.0)...))
println("loglikelihood_100 = ", log(likelihood(make_data(100, 2.0)...)))
println("loglikelihood_600 = ", log(likelihood(make_data(600, 2.0)...)))
# output is
#    loglikelihood_100 = -217.03969263050607
#    loglikelihood_600 = -1292.3930617222845
#    loglikelihood_100 = -217.03969263050607
#    loglikelihood_600 = -Inf
# As expected, only some precision loss when exp() underflows.

# Let's check out the general formula:
y, sigma, z = make_data(100, 2.0)
println("loglikelihood_100 = ", nongauss_loglikelihood(y, prob, sigma, z))
y, sigma, z = make_data(600, 2.0)
println("loglikelihood_600 = ", nongauss_loglikelihood(y, prob, sigma, z))
# output:
#    loglikelihood_100 = -217.03969263050604
#    loglikelihood_600 = -1292.393061722285
# which is essentially the same as before.

# 4f
# Logarithms are awesome. Probability calculations is one area where one
# must be careful with underflow.
