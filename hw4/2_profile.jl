#!/usr/bin/env julia

function make_data(Nobs::Int)
    srand(42)
    z = zeros(Nobs)
    sigma = 2. * ones(Nobs)
    y = z + sigma .* randn(Nobs)
    return y, sigma, z
end


log_deMoivre(z, y, sigma) = -0.5 * ((y-z)/sigma)^2 - log(sqrt(2*pi) * sigma)

function log_likelihood(log_pdf, y::Array, sigma::Array, z::Array)
    n = length(y)
    @assert n == length(sigma)
    @assert n == length(z)
    sum = @profile zero(y[1])
    for i in 1:n
        @profile sum += log_pdf(y[i], z[i], sigma[i])
    end
    
    return sum
end

function run_m_times(func, log_pdf, Nobs::Int, M::Int)
    y, sigma, z = make_data(Nobs)
    sum = 0.0
    for i in 1:M
        sum += func(log_pdf, y, sigma, z)
    end
    return sum # return something
end

println("Time taken: ", @elapsed run_m_times(log_likelihood, log_deMoivre, iround(3e3), 10^4))

Profile.print()
Profile.clear()
