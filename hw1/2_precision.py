# -*- coding: utf-8 -*-
# <nbformat>3.0</nbformat>

# <codecell>

# 2a
srand(42);
N = 10000;
true_mean = 10000.;
y = true_mean + randn(N);

# <codecell>

sample_mean = mean(y);
sample_var = var(y);
(sample_mean, sample_var)

# <codecell>

# OK, 2a done

# <codecell>

# 2b
y32bit = convert(Array{Float32,1},y);
m32 = mean(y32bit);
v32 = var(y32bit);
(m32, v32)

# <codecell>

y16bit = convert(Array{Float16,1},y);
m16 = mean(y16bit);
v16 = var(y16bit);
(m16, v16)

# <codecell>

# mean() cannot calculate the mean within 16bit floating point
# range.
# Difference of 64 bit to 32 bit is
(m32 - sample_mean, v32 - sample_var)

# <codecell>

# 2c
# If N=10^5, then maximum number to compute is roughly 10^9,
# which a 32 bit float should easily handle, but precision
# should suffer.
# Same for N=10^4, true_mean=10^5, although with much more
# precision loss for the variance.

# <codecell>

# 2d
srand(42);
N = 100000;
true_mean = 10000.;
y = true_mean + randn(N);
sample_mean = mean(y);
sample_var = var(y);
(sample_mean, sample_var)

# <codecell>

y32bit = convert(Array{Float32,1},y);
m32 = mean(y32bit);
v32 = var(y32bit);
(m32, v32)

# <codecell>

y16bit = convert(Array{Float16,1},y);
m16 = mean(y16bit);
v16 = var(y16bit);
(m16, v16)

# <codecell>

(m32 - sample_mean, v32 - sample_var)

# <codecell>

# Yes, less precision in the mean, but no bug difference in the
# variance.

# <codecell>

srand(42);
N = 10000;
true_mean = 100000.;
y = true_mean + randn(N);
sample_mean = mean(y);
sample_var = var(y);
(sample_mean, sample_var)

# <codecell>

y32bit = convert(Array{Float32,1},y);
m32 = mean(y32bit);
v32 = var(y32bit);
(m32, v32)

# <codecell>

y16bit = convert(Array{Float16,1},y);
m16 = mean(y16bit);
v16 = var(y16bit);
(m16, v16)

# <codecell>

(m32 - sample_mean, v32 - sample_var)

# <codecell>

# With a higher true_mean the precision has indeed suffered much
# more, since the small random changes are relatively smaller.
# Interestingly, the 16 bit version now has a NaN for the variance.
# This seems odd, and I cannot explain it satisfactorily by the fact
# that 10^5 doesn fit in a 16 bit float:
float16(66000.)

# <codecell>

# 2e
# First, beware of the number of bits, particularly when subtracting two
# similarly-sized large numbers.
# Second, don't save too much memory by choosing a small floating
# point type. You must know the range of numbers that your type
# can hold. This is especially important as it is not always clear
# what intermediate results functions such as mean() or var() need.

