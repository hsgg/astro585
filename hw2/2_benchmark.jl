#!/usr/bin/env julia
# To see the plots, this must be run interactively, i.e. include("filename")

# <codecell>

# 2
function calc_time_log_likelihood(Nobs::Int, M::Int = 1)
    srand(42);
    z = zeros(Nobs);
    sigma = 2. * ones(Nobs);
    y = z + sigma .* randn(Nobs);
    normal_pdf(z, y, sigma) = exp(-0.5 * ((y-z)/sigma)^2) / (sqrt(2*pi) * sigma);

    function log_likelihood(y::Array, sigma::Array, z::Array)
        n = length(y);
        @assert n == length(sigma);
        @assert n == length(z);
        sum = zero(y[1]);
        for i in 1:n
            sum += log(normal_pdf(y[i], z[i], sigma[i]));
        end;
        
        return sum;
    end;
    
    function m_times(y::Array, sigma::Array, z::Array, M::Int)
        sum = zero(y[1]);
        for i in 1:M
            sum += log_likelihood(y, sigma, z);
        end;
        
        return sum;
    end;
    
    return @elapsed m_times(y, sigma, z, M);
end;

function print_llik_MOPS(M::Int)
    println("log_likelihood ", M, " times: ",
                M * 1./calc_time_log_likelihood(10^6, M));
end;

print_llik_MOPS(1);
print_llik_MOPS(2);
print_llik_MOPS(10);

# <codecell>

# First time is always slower, probably since it must compile it first,
# but for subsequent runs it has the compilation cached.

# <codecell>

# 2c
#using PyCall
#pygui(true)
using PyPlot
n_list = [ 2^i for i = 1:10 ];
elapsed_list = map(calc_time_log_likelihood, n_list);
plot(log10(n_list), log10(elapsed_list), color="red", linewidth=2, marker="+",
                markersize=12);
xlabel("log N"); ylabel("log(Times/s)");

# <codecell>

# Initially, this is not linear for small array sizes, but for large
# ones it becomes fairly linear. For the future it is important to
# know what size of arrays will be expected.

# <codecell>

# 2e
println("log_likelihood 100 times without asserts: ",
                calc_time_log_likelihood(10^2, 10000));

# <codecell>

println("log_likelihood 100 times with asserts: ",
                calc_time_log_likelihood(10^2, 10000));

# <codecell>

# Barely a difference! (Even faster in this instance.)

# <codecell>

# 2f
normal_pdf(z, y, sigma) = exp(-0.5 * ((y-z)/sigma)^2) / (sqrt(2*pi) * sigma);

function calc_time_log_likelihood2(Nobs::Int, M::Int = 1, fn = normal_pdf)
    srand(42);
    z = zeros(Nobs);
    sigma = 2. * ones(Nobs);
    y = z + sigma .* randn(Nobs);

    function log_likelihood2(y::Array, sigma::Array, z::Array, fn)
        n = length(y);
        @assert n == length(sigma);
        @assert n == length(z);
        sum = zero(y[1]);
        for i in 1:n
            sum += log(fn(y[i], z[i], sigma[i]));
        end;
        
        return sum;
    end;
    
    function m_times2(y::Array, sigma::Array, z::Array, M::Int, fn)
        sum = zero(y[1]);
        for i in 1:M
            sum += log_likelihood2(y, sigma, z, fn);
        end;
        
        return sum;
    end;
    
    return @elapsed m_times2(y, sigma, z, M, fn);
end;

println("log_likelihood 100 times with function: ",
                calc_time_log_likelihood2(10^2, 10000, normal_pdf));

# <codecell>

# This is a little slower.

