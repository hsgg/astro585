function int_normal_gpu(a::Real, b::Real, n::Integer = 1000000)

@assert(typeof(a)==typeof(b)==Float64)

# generate random arrays 
dx = (b-a)/n
x_cpu = linspace( convert(Float64,a+0.5*dx), convert(Float64,b-0.5*dx), n) 

println("Timing the upload of inputs from CPU to GPU and memory allocation on GPU.")
tic()
# load input array onto GPU
x_gpu = CuArray( x_cpu )

# create an array on GPU to store results
y_gpu = CuArray(Float64, (n))
toc()

# choose the block and grid sizes based on the problem size
block_size = choose_block_size(n)
grid_size = choose_grid_size(n,block_size)

stream1 = CUDA.null_stream()

println("Timing the gpu calculations.")
tic()
# run the kernel 
# syntax: launch(kernel, grid_size, block_size, arguments)
# here, grid_size and block_size could be an integer or a tuple of integers
launch(normal_pdf_kernel, grid_size, block_size, (x_gpu, y_gpu, n), stream=stream1)
synchronize(stream1)
toc()

println("Timing the summation being performed on the GPU")
tic()
percore = 16
n_sums = n
n_subsums = iceil(n_sums / percore)
nonsum_gpu = y_gpu
subsum_gpu = CuArray(Float64, (n_subsums))
sumtmp_gpu = subsum_gpu  # keep for later freeing
result_gpu = CuArray(Float64, (1))

while n_sums > 1
    sum_block_size = choose_block_size(n_subsums)
    sum_grid_size = choose_grid_size(n_subsums, sum_block_size)
    launch(sum_gpu_kernel, sum_grid_size, sum_block_size, (nonsum_gpu, subsum_gpu, n_sums, n_subsums, percore), stream=stream1)
    synchronize(stream1)  # Hm, Darve says global synchronization is unreliable...

    # setup next
    n_sums = n_subsums
    n_subsums = iceil(n_sums / percore)
    tmp = nonsum_gpu
    if n_sums == n  # then nonsum_gpu = y_gpu
        # Don't overwrite y_gpu, but we can recycle x_gpu
        tmp = x_gpu
    end
    nonsum_gpu = subsum_gpu
    subsum_gpu = tmp
end

# get result
launch(put_sum_kernel, 1, 1, (nonsum_gpu, result_gpu), stream=stream1)  # copy into small array
synchronize(stream1)
thesum = to_host(result_gpu)[1] * (b-a)/n

free(sumtmp_gpu)
free(result_gpu)
toc()
println("The sum is: ", thesum)

println("Timing the download of results from GPU to CPU")
tic()
# download the results from GPU
y_cpu = to_host(y_gpu)   # c is a Julia array on CPU (host)
toc()

# release GPU memory
free(x_gpu)
free(y_gpu)

println("Timing the summation being performed on the CPU")
tic()
result = sum(y_cpu) * (b-a)/n
toc()
println("No, the sum is: ", result)

return result
end



