
@printf("Entering startup.jl in toySims\n")

Pkg.add("CPUTime")
Pkg.add("JSON")
Pkg.add("HTTPClient")
Pkg.add("LibGit2")
Pkg.add("Dates")
try    Pkg.installed("USERTime")
catch  Pkg.clone("git://github.com/christianpeel/USERTime.jl.git")
end

using CPUTime
using USERTime
