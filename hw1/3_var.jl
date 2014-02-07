#!/usr/bin/env julia


# 3a
function var_1pass(y::Array)
    n = length(y)

    sum = zero(y[1])
    sumsq = zero(sum)

    for i in 1:n
        sum = sum + y[i]
        sumsq = sumsq + y[i]^2
    end

    return sumsq / (n - 1) - sum^2 / (n * (n - 1))
end


# 3b
function var_2pass(y::Array)
    n = length(y)

    sum = zero(y[1])
    for i in 1:n
        sum = sum + y[i]
    end
    m = sum / n

    diffsum = zero(y[1])
    for i in 1:n
        diffsum += (y[i] - m)^2
    end

    return diffsum / (n - 1)
end


# 3c
srand(42)
N = 10^6
true_mean = 10.^6
y = true_mean + randn(N)

println(var(y))
println(var_1pass(y))
println(var_2pass(y))

# output is:
#    1.0015684445727868
#    0.9095458984375
#    1.001568444572786

# 3d
# Clearly, the 1-pass algorithm that requires subtraction of two large numbers
# is much less accurate. However, it is likely faster.



# 3e
function var_online(y::Array)
    n = length(y);
    sum1 = zero(y[1]);
    mean = zero(y[1]);
    M2 = zero(y[1]);
    for i in 1:n
        diff_by_i = (y[i]-mean)/i;
        mean = mean +diff_by_i;
        M2 = M2 + (i-1)*diff_by_i*diff_by_i+(y[i]-mean)*(y[i]-mean); 
    end;  
    variance = M2/(n-1);
end

println(var_online(y))

# This seems to be a fairly good choice under a wide range of circumstances as
# it keeps the numbers in a similar range at all steps in the computation.
