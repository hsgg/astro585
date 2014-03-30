extern "C"   // ensure function name to be left alone
{

    __global__ void normal_pdf_gpu(const double *x, double *y, unsigned int n)
    {
	// assumes a 2-d grid of 1-d blocks
	unsigned int i = (blockIdx.y * gridDim.x + blockIdx.x) * blockDim.x + threadIdx.x;
        if(i<n)  y[i] = exp(-0.5*x[i]*x[i])*rsqrt(2.0*M_PI);
    }

    __global__ void sum_gpu(double *y, double *sumptr, unsigned int n,
            unsigned int n_subsums, unsigned int percore)
    {
        // assumes a 2-d grid of 1-d blocks
        unsigned int i = (blockIdx.y * gridDim.x + blockIdx.x) * blockDim.x
            + threadIdx.x;
        unsigned int j = i * percore; // first element that this thread will take care of
        unsigned int k;

        if (i >= n_subsums)
            return;

        sumptr[i] = 0.0;
        for (k = 0; k < percore; k++) {
            if (j + k < n)
                sumptr[i] += y[j + k];
        }
    }

    __global__ void get_sum_gpu(double *y, double *sumptr)
        // copy the result into a smaller array
    {
        sumptr[0] = y[0];
    }
}


/* vim: set sw=4 sts=4 et : */
