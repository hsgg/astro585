#!/usr/bin/env julia

if nprocs() < 2
  @time addprocs(2) # 13 seconds
end

# Why does it take a minute just to load these? I hope they fix it in
# julia-0.3!
@time @everywhere using Distributions # 44 seconds
@time @everywhere using PyPlot        # 47 seconds
@everywhere const days_in_year = 365.2425;
@time @everywhere include("HW6_Q2_planet_populations.jl")


@everywhere function eval_model_on_grid_parallel(etas::Array, shapes::Array,
    scales::Array, num_stars = 1600; num_evals = 1, true_eta = 0.2,
    true_shape = 0.1, true_scale = 1.0)
  const solar_radius_in_AU = 0.00464913034
  minP = (2.0*solar_radius_in_AU)^1.5
  maxP = 4*days_in_year/3
  data_obs = generate_transiting_planet_sample(true_eta, true_shape, true_scale, num_stars;
      minP=minP, maxP=4*days_in_year/3)
  stats_obs = compute_stats(data_obs)

  # This is ridiculous. Surely there is a better way to do this so that pmap()
  # or similar can create a grid from the three arrays 'etas', 'scales', and
  # 'shapes', and I don't need to do that on my own?
  parameterspace = Array((Float64, Float64, Float64), length(etas) * length(shapes) * length(scales))
  for k in 1:length(scales)
    for j in 1:length(shapes)
      for i in 1:length(etas)
        idx = (k-1) * length(etas) * length(shapes) + (j-1) * length(etas) + (i-1)
        parameterspace[idx + 1] = (etas[i], shapes[j], scales[k])
      end
    end
  end

  result = pmap(pars -> evaluate_model(stats_obs, pars[1], pars[2], pars[3], num_stars;
            minP=minP, maxP=maxP, num_evals=num_evals), parameterspace)

  #result = Array(Float64, length(etas) * length(shapes) * length(scales))
  #for i in 1:length(result)
  #  x = parameterspace[i][1]
  #  y = parameterspace[i][2]
  #  z = parameterspace[i][3]
  #  println(i, ' ', x, ' ', y, ' ', z)
  #  result[i] = evaluate_model(stats_obs, x, y, z, num_stars; minP=minP, maxP=maxP, num_evals=num_evals)
  #end

  println(result)

  dist = Array(Float64, (length(etas), length(shapes), length(scales)))
  for k in 1:length(scales)
    for j in 1:length(shapes)
      for i in 1:length(etas)
        idx = (k-1) * length(etas) * length(shapes) + (j-1) * length(etas) + (i-1)
        dist[i, j, k] = result[idx + 1]
      end
    end
  end

  return dist
end



min_eta = 0.0
max_eta = 1.0
min_shape = 0.0001
max_shape = 1.0
min_log_scale = log10(0.3)
max_log_scale = log10(3.0)  
num_eta = 4
num_shape = 4
num_scale = 4
num_evals = 1
etas = linspace(min_eta,max_eta,num_eta)
scales = 10.0.^linspace(min_log_scale,max_log_scale,num_scale)
shapes = linspace(min_shape,max_shape,num_shape)
num_stars = 16000
eta = 0.2
shape = 0.1
scale = 1.0

srand(42)
@time result = eval_model_on_grid_parallel(etas,shapes,scales,num_stars;
    num_evals = num_evals, true_eta = eta, true_shape = shape, true_scale = scale);

PyPlot.contour(log10(scales),shapes,[minimum(result[:,j,k]) for j in 1:num_scale, k in 1:num_shape])
plot(log10([scale]),[shape],"ro")  # Put dot where true values of parameters are
xlabel(L"$\log_{10}(\mathrm{scale})$");  ylabel("shape");
show()


# vim: set sw=2 sts=2 et :
