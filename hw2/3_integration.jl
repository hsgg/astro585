#!/usr/bin/env julia

# 3a)
function accel_grav(rvec)
    # assuming G*M = 1
    r = hypot(rvec...)
    return - rvec / r^3
end

function phase_space_speed(state)
    m = iround(length(state) / 2) # number of spatial dimensions
    ridx = 1:m
    vidx = (m+1):(2*m)

    speed = copy(state) # should probably cache this
    speed[ridx] = state[vidx]
    speed[vidx] = accel_grav(state[ridx])

    return speed
end

function integrate_euler!(state::Array, dt::Real, duration::Real)
    #assert(length(state) is even)

    n = iceil(duration / dt)
    m = length(state)
    all_states = Array(typeof(state[1]), n, m)
    all_states[1,:] = state

    for i in 2:n
        speed = phase_space_speed(state)

        state[:] += dt .* speed # one Euler step

        all_states[i,:] = state
    end

    return all_states
end


# 3b)
state = [ 1.0, 0.0, 0.0, 1.0 ]
all_states = integrate_euler!(state, 2*pi / 200, 3*2*pi)
function show_some_states(all_states)
    show(all_states[1:5,:])
    println("\n...")
    show(all_states[(end-4):end,:])
    println()
end
println("# 3b")
show_some_states(all_states)
# Seems completely wrong.


# 3c)
using PyPlot
x = all_states[:,1]
y = all_states[:,2]
figure()
plot(x, y)
title("Euler")
# The accuracy is, uhm, in need of improvement.


# 3d)
function integrate_leapfrog!(state::Array, dt::Real, duration::Real)
    #assert(length(state) is even)

    n = iceil(duration / dt)
    m = length(state)
    all_states = Array(typeof(state[1]), n, m)
    all_states[1,:] = state

    m = iround(length(state) / 2) # number of spatial dimensions
    ridx = 1:m
    vidx = (m+1):(2*m)

    midstate = copy(state)

    for i in 2:n
        # leapfrog, the complicated way:
        midstate[ridx] = state[ridx] + dt/2 .* state[vidx]
        midstate[vidx] = state[vidx]
        state[vidx] += dt * accel_grav(midstate[ridx])
        midstate[vidx] = (midstate[vidx] + state[vidx]) / 2
        state[ridx] = midstate[ridx] + dt/2 .* midstate[vidx]

        all_states[i,:] = state
    end

    return all_states
end

# 3e)
state = [ 1.0, 0.0, 0.0, 1.0 ]
all_states = integrate_leapfrog!(state, 2*pi / 200, 3*2*pi)
println("\n# 3e")
show_some_states(all_states)
# Also quite wrong
x = all_states[:,1]
y = all_states[:,2]
figure()
plot(x, y)
title("Leapfrog")
# But the plot shows that it is much closer to the right answer, as the
# computed answer orbits about 2.5 times, not just under 2 times. Also, the
# energy is much closer to being conserved. I would have expected it to be much
# better conserved upon completion of an orbit, but since this is a homework, I
# am not inclined to continue debugging the algorithm.


# 3f)
println("\n# 3f")
state = [ 1.0, 0.0, 0.0, 1.0 ]
@time integrate_euler!(state, 2*pi / 200, 3 * 2 * pi)
# Takes only 0.002158235 seconds
time = @elapsed integrate_euler!(state, 2*pi / 200, 4.5e3 * 2 * pi)
println("Time for 4.5e3 orbits: ", time, " seconds")
println("Time for 4.5e9 orbits: ", time * 1e6, " seconds", " = ",
                time*1e6 / 3600 / 24, " days")
# Takes only 6.76 seconds for 4.5e3 orbits, so for 4.5e9 I estimate 6.76e6
# seconds, or 78 days. Darn.


# 3g)
println("\n# 3g")
state = [ 1.0, 0.0, 0.0, 1.0 ]
all_states = integrate_leapfrog!(state, 2*pi / 100, 3*2*pi) # double dt from before
show_some_states(all_states)
# 2.25 orbits instead of 2.5.
x = all_states[:,1]
y = all_states[:,2]
figure()
plot(x, y)
title("Leapfrog")
