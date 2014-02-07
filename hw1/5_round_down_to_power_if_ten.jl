# 5
# - Get rid of loops.
# - Repeated multiplication/division will introduce roundoff errors in z, so
#   testing for equal no longer works, and the result may not be a power of
#   10.
# - The second while loop could underflow and return 0.
# - Check for negative x to prevent an infinite loop.
# - Do it right:
round_down_to_power_of_ten(x::Real) = 10.0^ifloor(log10(x))
