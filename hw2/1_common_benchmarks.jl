#!/usr/bin/env julia

# 1
N = 10^7;
println("rand: ", 1./(@elapsed x = rand(N)));
println(".+:   ", 1./(@elapsed x.+x));
println(".*:   ", 1./(@elapsed x.*x));
println("./:   ", 1./(@elapsed x./x));
println("log:  ", 1./(@elapsed log(x)));
println("log10:", 1./(@elapsed log10(x)));
println("sin:  ", 1./(@elapsed sin(x)));
println("cos:  ", 1./(@elapsed cos(x)));
println("tan:  ", 1./(@elapsed tan(x)));
println("atan: ", 1./(@elapsed atan(x)));
round_down_to_power_of_ten(x) = 10.0.^floor(log10(x))
round_down_to_power_of_iten(x) = 10.0.^ifloor(log10(x))
println("rdtpot:  ", 1./(@elapsed round_down_to_power_of_ten(x)));
println("rdtopit: ", 1./(@elapsed round_down_to_power_of_iten(x)));
println("rdtpot:  ", 1./(@elapsed round_down_to_power_of_ten(x)));
println("rdtopit: ", 1./(@elapsed round_down_to_power_of_iten(x)));
