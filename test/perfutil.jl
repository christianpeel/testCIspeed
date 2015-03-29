const mintrials = 10
const mintime = 2000.0
if length(ARGS)>0
    executable = ARGS[1]
else
    executable = "Test"
end
executable = executable*"Exe"

#
# Fill common JSON fields
#
begin
    using JSON
    using HTTPClient.HTTPC
    using LibGit2
    using Dates

    repo = GitRepo(".");

    println("executable: $(executable)")
    println("Sys.Machine: $(Sys.MACHINE)")
    println("Julia $VERSION")
    Sys.cpu_summary()

    # Setup codespeed data dict for submissions to codespeed's JSON
    # endpoint.  These parameters are constant across all benchmarks, so
    # we'll just let them sit here for now
    csdata = Dict()
    csdata["commitid"] = hex(LibGit2.revparse(repo,"HEAD"))
    csdata["project"] = "Julia $VERSION"
    #csdata["project"] = "Julia0"
    # to-do: branch for this repo (LibGit2), rather than from Base
    csdata["branch"] = Base.GIT_VERSION_INFO.branch

#    csdata["executable"] = Sys.cpu_info()[1].model
    csdata["executable"] = executable
    # csdata["executable"] = "TestExe"
# csdata["environment"] = chomp(readall(`hostname`))
# csdata["environment"] = Sys.MACHINE
    csdata["environment"] = "TestEnv2"
    aa = now();
    dateAndTime = @sprintf("%d-%d-%d %d:%d:%d",year(aa),month(aa),day(aa),
                                               hour(aa),minute(aa),second(aa))
    csdata["result_date"] = dateAndTime
    # to-do: get date/time of LibGit2 commit, rather than current date/time

    close(repo)
    LibGit2.free!(repo)
end

# Takes in the raw array of values in vals, along with the benchmark name,
# description, unit and whether less is better
function submit_to_codespeed(vals,name,desc,unit,test_group,lessisbetter=true)
    # Points to the server
    #codespeed_host = "julia-codespeed.csail.mit.edu"
    codespeed_host = "codespeed.herokuapp.com"

    csdata["benchmark"] = name
    csdata["description"] = desc
    csdata["result_value"] = mean(vals)
    csdata["std_dev"] = length(vals)==1? 0.0: std(vals)
    csdata["min"] = minimum(vals)
    csdata["max"] = maximum(vals)
    csdata["units"] = unit
    csdata["units_title"] = test_group
    csdata["lessisbetter"] = lessisbetter

    println( "$name: $(mean(vals))" )
    # v0.4?
    # ret = post( "http://$codespeed_host/result/add/json/", Dict("json" => json([csdata])) )
    # v0.3?
    ret = post( "http://$codespeed_host/result/add/json/", {"json" => json([csdata])} )
    println( json([csdata]) )
    if ret.http_code != 200 && ret.http_code != 202
        error("Error submitting $name [HTTP code $(ret.http_code)], dumping headers and text: $(ret.headers)\n$(bytestring(ret.body))\n\n")
        return false
    end
    return true
end

macro output_timings(t,name,desc,group)
    quote
        # If we weren't given anything for the test group, infer off of file path!
        test_group = length($group) == 0 ? basename(dirname(Base.source_path())) : $group[1]
        submit_to_codespeed( $t, $name, $desc, "seconds", test_group )
        gc()
    end
end

macro timeit(ex,name,desc,group...)
    quote
        t = Float64[]
        tot = 0.0
        i = 0
        while i < mintrials || tot < mintime
            e = 1000*(@elapsed $(esc(ex)))
            tot += e
            if i > 0
                # warm up on first iteration
                push!(t, e)
            end
            i += 1
        end
        @output_timings t $name $desc $group
    end
end

macro cputimeit(ex,name,desc,group...)
    quote
        t = Float64[]
        tot = 0.0
        i = 0
        while i < mintrials || tot < mintime
            e = 1000*(@CPUelapsed $(esc(ex)))
            tot += e
            if i > 0
                # warm up on first iteration
                push!(t, e)
            end
            i += 1
        end
        @output_timings t $name $desc $group
    end
end

macro timeit_init(ex,init,name,desc,group...)
    quote
        t = zeros(ntrials)
        for i=0:ntrials
            $(esc(init))
            e = 1000*(@elapsed $(esc(ex)))
            if i > 0
                # warm up on first iteration
                t[i] = e
            end
        end
        @output_timings t $name $desc $group
    end
end

macro cputimeit_init(ex,init,name,desc,group...)
    quote
        t = zeros(ntrials)
        for i=0:ntrials
            $(esc(init))
            e = 1000*(@CPUelapsed $(esc(ex)))
            if i > 0
                # warm up on first iteration
                t[i] = e
            end
        end
        @output_timings t $name $desc $group
    end
end

macro usertimeit_init(ex,init,name,desc,group...)
    quote
        t = zeros(ntrials)
        for i=0:ntrials
            $(esc(init))
            e = 1000*(@USERelapsed $(esc(ex)))
            if i > 0
                # warm up on first iteration
                t[i] = e
            end
        end
        @output_timings t $name $desc $group
    end
end

function maxrss(name)
    @linux_only begin
        rus = Array(Int64, div(144,8))
        fill!(rus, 0x0)
        res = ccall(:getrusage, Int32, (Int32, Ptr{Void}), 0, rus)
        if res == 0
            mx = rus[5]/1024
            @printf "julia,%s.mem,%f,%f,%f,%f\n" name mx mx mx 0
        end
    end
end


# seed rng for more consistent timings
srand(1776)
