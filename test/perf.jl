#import Base.Sort: QuickSort, MergeSort, InsertionSort
include("perfutil.jl")

# Just in case any BLAS calls are made.
blas_set_num_threads(1);

ntrials = 5;

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
    name = "sort_$(size)_cputime"
    desc = "cpu-timed sort on $(size) $(typename) list in random order"
    @cputimeit_init(sort!(data), randfn!(data), name, desc, "sortCPU")
    name = "sort_$(size)_clktime"
    desc = "clock-timed sort on $(size) $(typename) list in random order"
    @timeit_init(sort!(data), randfn!(data), name, desc, "sort")
end

for size in [2^6,2^16]
    gc()
    name = "fft_$(size)_cputime"
    desc = "cpu-timed fft on $(size) vector of randn"
    @cputimeit_init(fft(randn(size,1)), fft(randn(size,1)), name, desc, "fftCPU")
    name = "fft_$(size)_clktime"
    desc = "clock-timed fft on $(size) vector of randn"
    @cputimeit_init(fft(randn(size,1)), fft(randn(size,1)), name, desc, "fftclk")
end

@cputimeit_init(sleep(0.01),[],"sleep_p01_cput","CPU time of sleep for .01s","sleep")
@timeit_init(sleep(0.01),   [],"sleep_p01_time","time of sleep for .01s","sleep")
@cputimeit_init(sleep(10.0),[],"sleep_10_cput", "CPU time of sleep for 10s","sleep")
@timeit_init(sleep(10.0),   [],"sleep_10_time", "time of sleep for 10s","sleep")

# Send system data to codespeed
@output_timings(Sys.CPU_CORES,          "Sys.cores","number of CPU cores","")
@output_timings(Sys.cpu_info()[1].speed,"Sys.cpuMHz","cpu speed (MHz)","")
@output_timings(Sys.WORD_SIZE,          "Sys.wordSize","word size","")
@output_timings(Sys.free_memory()/1e9,  "Sys.freeMem", "free memory (Gb)","")
@output_timings(Sys.total_memory()/1e9, "Sys.totalMem","total memory (Gb)","")
@output_timings(Sys.loadavg()[3], "Sys.load15min","load averaged over 15 minutes","")
@output_timings(Sys.loadavg()[1], "Sys.load1min","load averaged over 1 minute","")

# Send other data to codespeed
@output_timings(nprocs(),"Sys.nprocs","number of cores used by Julia","")
