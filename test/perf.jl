#import Base.Sort: QuickSort, MergeSort, InsertionSort
include("perfutil.jl")

# Just in case any BLAS calls are made.
blas_set_num_threads(1);

ntrials = 10;

# Do some sort tests
randstr_fn!(str_len::Int) =
    d -> (for i = 1:length(d); d[i] = randstring(str_len); end; d)
typename = "String_10";
randfn! = randstr_fn!(10);
for size in [2^6,2^16]
    data = Array(String, size)
    gc()

    ## Random
    #s = QuickSort;
    # name = "$(typename)_$(size)_$(string(s)[1:end-5])_random"
    # desc = "$(string(s)) run on $(size) $(typename) elements in random order"
    # @cputimeit_init(sort!(data), randfn!(data), name, "", "sort")
    name = "sort_$(size)_nogctime"
    desc = "NoGC timed sort on $(size) $(typename) list in random order"
    @noGCtimeit_init(sort!(data), randfn!(data), name, desc, "sortNoGC")
    name = "sort_$(size)_usertime"
    desc = "user-timed sort on $(size) $(typename) list in random order"
    @usertimeit_init(sort!(data), randfn!(data), name, desc, "sortUSER")
    name = "sort_$(size)_cputime"
    desc = "cpu-timed sort on $(size) $(typename) list in random order"
    @cputimeit_init(sort!(data), randfn!(data), name, desc, "sortCPU")
    name = "sort_$(size)_clktime"
    desc = "clock-timed sort on $(size) $(typename) list in random order"
    @timeit_init(sort!(data), randfn!(data), name, desc, "sort")
end

# for size in [2^6,2^16]
#     gc()
#     name = "fft_$(size)_cputime"
#     desc = "cpu-timed fft on $(size) vector of randn"
#     @cputimeit_init(fft(randn(size,1)), fft(randn(size,1)), name, desc, "fftCPU")
#     name = "fft_$(size)_clktime"
#     desc = "clock-timed fft on $(size) vector of randn"
#     @timeit_init(fft(randn(size,1)), fft(randn(size,1)), name, desc, "fftclk")
# end
for size in [2^5,2^7]
    gc()
    name = "matMul_$(size)_nogctime"
    desc = "NoGC time for matrix multiply on $(size)x$(size) random matrices"
    @noGCtimeit_init(randn(size,size)*randn(size,size), 1, name, desc, "matMulNoGC")
    name = "matMul_$(size)_usrtime"
    desc = "user time for matrix multiply on $(size)x$(size) random matrices"
    @usertimeit_init(randn(size,size)*randn(size,size), 1, name, desc, "matMulUSR")
    name = "matMul_$(size)_cputime"
    desc = "cpu time for matrix multiply on $(size)x$(size) random matrices"
    @cputimeit_init(randn(size,size)*randn(size,size), 1, name, desc, "matMulCPU")
    name = "matMul_$(size)_clktime"
    desc = "clock time for matrix multiply on $(size)x$(size) random matrices"
    @timeit_init(randn(size,size)*randn(size,size), 1, name, desc, "matMulclk")
end

# @cputimeit_init(sleep(0.01),[],"sleep_p01_cput","CPU time of sleep for .01s","sleep")
# @timeit_init(sleep(0.01),   [],"sleep_p01_time","time of sleep for .01s","sleep")
# @cputimeit_init(sleep(1.0),[],"sleep_1_cput", "CPU time of sleep for 1s","sleep")
# @timeit_init(sleep(1.0),   [],"sleep_1_time", "time of sleep for 1s","sleep")

# Send other data to codespeed
@output_timings(nprocs(),"Sys.nprocs","number of cores used by Julia","")

# Send system data to codespeed
@output_timings(Sys.CPU_CORES,          "Sys.cores","number of CPU cores","")
@output_timings(Sys.cpu_info()[1].speed,"Sys.cpuMHz","cpu speed (MHz)","")
@output_timings(Sys.WORD_SIZE,          "Sys.wordSize","word size","")
@output_timings(Sys.free_memory()/1e9,  "Sys.freeMem", "free memory (Gb)","")
@output_timings(Sys.total_memory()/1e9, "Sys.totalMem","total memory (Gb)","")
@output_timings(Sys.loadavg()[3], "Sys.load15min","load averaged over 15 minutes","")
@output_timings(Sys.loadavg()[1], "Sys.load1min","load averaged over 1 minute","")

