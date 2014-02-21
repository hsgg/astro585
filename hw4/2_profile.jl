#!/usr/bin/env julia

function log_deMoivre(z, y, sigma)
    tmp = y - z
    tmp /= sigma
    tmp = tmp^2
    tmp *= -0.5
    tmp2 = sqrt(2 * pi)
    tmp2 *= sigma
    tmp2 = log(tmp2)
    tmp -= tmp2
    return tmp
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
        sum += log_pdf(a, b, c)
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
time = @elapsed @profile (for i in 1:10^5; log_likelihood(log_deMoivre, y, sigma, z); end)
println("Time elapsed: ", time, " seconds")
Profile.print()
