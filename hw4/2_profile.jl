#!/usr/bin/env julia

# Calculate a normalized Gaussian. Write it in this odd way, so we can see the
# profiler output better
function log_Gaussian(z, y, sigma)
    tmp1 = y - z
    tmp1 ./= sigma
    tmp1 = tmp1.^2
    tmp1 .*= -0.5
    tmp2 = sqrt(2 * pi)
    tmp2 .*= sigma
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
Nobs = 1000
srand(42)
z = zeros(Nobs)
sigma = 2. * ones(Nobs)
y = z + sigma .* randn(Nobs)

# profile:
Profile.clear()
t = @elapsed @profile (for i in 1:10^4;
        log_likelihood(log_Gaussian, y, sigma, z);
    end)
println("Time elapsed: ", t, " seconds")
Profile.print()
println()

# I expect the function calls to take the most time, and so that's where the
# profile is most often, 5800 times calling the function "log_Gaussian()", and
# 1715 times 'log()':

# julia> include("2_profile.jl")
# Time elapsed: 8.564663583 seconds
# 7690 boot.jl; include; line: 238
#     7690 util.jl; anonymous; line: 42
#       20   ...mp/hw4/2_profile.jl; log_likelihood; line: 21
#       15   ...mp/hw4/2_profile.jl; log_likelihood; line: 22
#       172  ...mp/hw4/2_profile.jl; log_likelihood; line: 23
#       16   ...mp/hw4/2_profile.jl; log_likelihood; line: 24
#       36   ...mp/hw4/2_profile.jl; log_likelihood; line: 25
#       5800 ...mp/hw4/2_profile.jl; log_likelihood; line: 26
#         17   ...mp/hw4/2_profile.jl; log_Gaussian; line: 11
#          13   ...p/hw4/2_profile.jl; log_Gaussian; line: 7
#          32   ...p/hw4/2_profile.jl; log_Gaussian; line: 11
#          1715 ...p/hw4/2_profile.jl; log_Gaussian; line: 12
#          18   ...p/hw4/2_profile.jl; log_Gaussian; line: 14
#            3    inference.jl; typeinf_ext; line: 1092
#               1 inference.jl; typeinf; line: 1196
#               1 inference.jl; typeinf; line: 1382
#                 1 inference.jl; inlining_pass; line: 1956
#                   1 inference.jl; inlining_pass; line: 1972
#                     1 inference.jl; inlining_pass; line: 2014
#                       1 inference.jl; inlineable; line: 1832
#               1 inference.jl; typeinf; line: 1385
#                1 inference.jl; tuple_elim_pass; line: 2244
#                 1 inference.jl; find_sa_vars; line: 2181
#       1589 ...mp/hw4/2_profile.jl; log_likelihood; line: 27
#         13   float.jl; +; line: 132
#          8  inference.jl; typeinf_ext; line: 1092
#             4 inference.jl; typeinf; line: 1259
#               2 inference.jl; abstract_interpret; line: 958
#                 2 inference.jl; abstract_eval; line: 814
#                  2 inference.jl; abstract_eval_call; line: 789
#                    2 inference.jl; abstract_call; line: 701
#                      2 inference.jl; abstract_call_gf; line: 576
#                         2 reflection.jl; _methods; line: 77
#                            2 reflection.jl; _methods; line: 97
#                               2 reflection.jl; _methods; line: 97
#                                  2 reflection.jl; _methods; line: 80
#               2 inference.jl; abstract_interpret; line: 966
#                1 inference.jl; abstract_eval; line: 814
#                 1 inference.jl; abstract_eval_call; line: 788
#                 1 inference.jl; abstract_eval; line: 814
#                  1 inference.jl; abstract_eval_call; line: 756
#                   1 array.jl; getindex; line: 296
#                    1 array.jl; copy!; line: 51
#                     1 array.jl; unsafe_copy!; line: 37
#             1 inference.jl; typeinf; line: 1379
#               1 inference.jl; type_annotate; line: 1508
#                 1 inference.jl; eval_annotate; line: 1471
#                   1 inference.jl; eval_annotate; line: 1483
#             3 inference.jl; typeinf; line: 1382
#               3 inference.jl; inlining_pass; line: 1956
#                 2 inference.jl; inlining_pass; line: 1972
#                   1 inference.jl; inlining_pass; line: 1990
#                     1 inference.jl; exprtype; line: 1662
#                       1 inference.jl; abstract_eval; line: 798
#                         1 inference.jl; abstract_eval_symbol; line: 910
#                          1 inference.jl; abstract_eval_global; line: 898
#                            1 inference.jl; abstract_eval_constant; line: 875
#                   1 inference.jl; inlining_pass; line: 2014
#                     1 inference.jl; inlineable; line: 1772
#                        1 reflection.jl; _methods; line: 77
#                           1 reflection.jl; _methods; line: 97
#                              1 reflection.jl; _methods; line: 97
#                                 1 reflection.jl; _methods; line: 80
#                 1 inference.jl; inlining_pass; line: 2014
#                   1 inference.jl; inlineable; line: 1910
#                     1 inference.jl; sym_replace; line: 1560
#                       1 inference.jl; sym_replace; line: 1560
#                         1 inference.jl; sym_replace; line: 1560
# 8    float.jl; +; line: 132


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
    su = sum(s)
    return su
end

Profile.clear()
t = @elapsed @profile (for i in 1:10^4;
        log_likelihood_vec(log_Gaussian, y, sigma, z);
    end)
println("Time elapsed: ", t, " seconds")
Profile.print()

# Nice, more thatn 2 times increase in speed:

# Time elapsed: 3.672488957 seconds
# 3205 boot.jl; include; line: 238
#     3205 util.jl; anonymous; line: 72
#       3143 ...mp/hw4/2_profile.jl; log_likelihood_vec; line: 65
#         97   ...mp/hw4/2_profile.jl; log_Gaussian; line: 6
#          73 array.jl; -; line: 135
#          3  array.jl; -; line: 136
#          8  array.jl; -; line: 926
#          13 array.jl; -; line: 927
#         1121 ...mp/hw4/2_profile.jl; log_Gaussian; line: 7
#          901 broadcast.jl; ##broadcast_T_/#233; line: 187
#             4   broadcast.jl; broadcast_shape; line: 27
#               2 broadcast.jl; longer_size; line: 21
#                 1 broadcast.jl; longer_size; line: 20
#             6   broadcast.jl; broadcast_shape; line: 29
#              3 array.jl; fill!; line: 183
#             8   broadcast.jl; broadcast_shape; line: 42
#          14  broadcast.jl; ##broadcast_T_/#233; line: 188
#          204 broadcast.jl; ##broadcast_T_/#233; line: 189
#            13  broadcast.jl; broadcast_args; line: 87
#             1 array.jl; sizehint; line: 709
#             5 broadcast.jl; calc_loop_strides; line: 63
#             2 broadcast.jl; calc_loop_strides; line: 64
#             1 broadcast.jl; calc_loop_strides; line: 66
#              1 array.jl; sizehint; line: 709
#             2 broadcast.jl; calc_loop_strides; line: 77
#             2 broadcast.jl; calc_loop_strides; line: 83
#            3   broadcast.jl; broadcast_args; line: 88
#              10  broadcast.jl; ##/_inner!#235; line: 129
#               1 tuple.jl; ==; line: 81
#               6 tuple.jl; ==; line: 84
#                 1 promotion.jl; ==; line: 188
#              1   broadcast.jl; ##/_inner!#235; line: 131
#              27  broadcast.jl; ##/_inner!#235; line: 136
#              138 broadcast.jl; ##/_inner!#235; line: 166
#         573  ...mp/hw4/2_profile.jl; log_Gaussian; line: 8
#          572 array.jl; .^; line: 920
#         100  ...mp/hw4/2_profile.jl; log_Gaussian; line: 9
#          71 array.jl; .*; line: 135
#          9  array.jl; .*; line: 136
#          5  array.jl; .*; line: 944
#          15 array.jl; .*; line: 945
#         1    ...mp/hw4/2_profile.jl; log_Gaussian; line: 10
#         92   ...mp/hw4/2_profile.jl; log_Gaussian; line: 11
#          60 array.jl; .*; line: 135
#          12 array.jl; .*; line: 136
#          8  array.jl; .*; line: 937
#          11 array.jl; .*; line: 938
#          1  array.jl; .*; line: 941
#         1058 ...mp/hw4/2_profile.jl; log_Gaussian; line: 12
#          1058 operators.jl; log; line: 236
#         88   ...mp/hw4/2_profile.jl; log_Gaussian; line: 13
#          57 array.jl; -; line: 135
#          3  array.jl; -; line: 136
#          18 array.jl; -; line: 926
#          10 array.jl; -; line: 927
#            3 inference.jl; typeinf_ext; line: 1092
#               1 inference.jl; typeinf; line: 1169
#               2 inference.jl; typeinf; line: 1382
#                 2 inference.jl; inlining_pass; line: 1956
#                   2 inference.jl; inlining_pass; line: 1972
#                     2 inference.jl; inlining_pass; line: 2014
#                       1 inference.jl; inlineable; line: 1808
#                       1 inference.jl; inlineable; line: 1908
#                         1 inference.jl; resolve_globals; line: 1624
#                           1 inference.jl; resolve_globals; line: 1624
#                             1 inference.jl; resolve_globals; line: 1624
#       44   ...mp/hw4/2_profile.jl; log_likelihood_vec; line: 66
#          43 abstractarray.jl; sum; line: 1487
#           43 abstractarray.jl; sum_pairwise; line: 1481
#            43 abstractarray.jl; sum_pairwise; line: 1481
#             43 abstractarray.jl; sum_pairwise; line: 1481
#              24 abstractarray.jl; sum_pairwise; line: 135
#              17 abstractarray.jl; sum_pairwise; line: 1475
#              2  abstractarray.jl; sum_pairwise; line: 1478
#          3  inference.jl; typeinf_ext; line: 1092
#             1 inference.jl; typeinf; line: 1259
#               1 inference.jl; abstract_interpret; line: 966
#                1 inference.jl; abstract_eval; line: 814
#                 1 inference.jl; abstract_eval_call; line: 788
#             2 inference.jl; typeinf; line: 1382
#               2 inference.jl; inlining_pass; line: 1956
#                 1 inference.jl; inlining_pass; line: 1943
#                  1 inference.jl; is_known_call; line: 2120
#                 1 inference.jl; inlining_pass; line: 1994
# 1    range.jl; colon; line: 36
# 1    range.jl; colon; line: 38
