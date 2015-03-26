import Base.Sort: QuickSort, MergeSort, InsertionSort
include("perfutil.jl")

ntrials = 5;

# Do some sort tests
randstr_fn!(str_len::Int) =
    d -> (for i = 1:length(d); d[i] = randstring(str_len); end; d)
typename = "String_10";
randfn! = randstr_fn!(10);
for size in [2^6,2^16]
    data = Array(String, size)
    gc()
    s = QuickSort;

    ## Random
    # name = "$(typename)_$(size)_$(string(s)[1:end-5])_random"
    # desc = "$(string(s)) run on $(size) $(typename) elements in random order"
    # @cputimeit_init(sort!(data), randfn!(data), name, "", "sort")
    name = "sort_cputime_$(size)"
    desc = "cpu-timed sort on $(size) $(typename) list in random order"
    @cputimeit_init(sort!(data), randfn!(data), name, desc, "sortCPU")
    name = "sort_clktime_$(size)"
    desc = "clock-timed sort on $(size) $(typename) list in random order"
    @timeit_init(sort!(data), randfn!(data), name, desc, "sort")
end

@cputimeit_init(sleep(0.01),[],"cput_sleep_p01","CPU time of sleep for .01s","sleep")
@timeit_init(sleep(0.01),   [],"time_sleep_p01","time of sleep for .01s","sleep")
@cputimeit_init(sleep(10.0),[],"cput_sleep_10", "CPU time of sleep for 10s","sleep")
@timeit_init(sleep(10.0),   [],"time_sleep_10", "time of sleep for 10s","sleep")

# Send system data to codespeed
@output_timings(Sys.CPU_CORES,          "cores","number of CPU cores","")
@output_timings(Sys.cpu_info()[1].speed,"cpuMHz","cpu speed (MHz)","")
@output_timings(Sys.WORD_SIZE,          "wordSize","word size","")
@output_timings(Sys.free_memory()/1e9,  "freeMem", "free memory (Gb)","")
@output_timings(Sys.total_memory()/1e9, "totalMem","total memory (Gb)","")
@output_timings(Sys.loadavg()[3],     "load15min","load averaged over 15 minutes","")
@output_timings(Sys.loadavg()[1],     "load1min","load averaged over 1 minute","")

# Send other data to codespeed
@output_timings(nprocs(),"nprocs","number of cores used by Julia","")
