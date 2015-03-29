
@printf("Entering startup.jl in toySims\n")

Pkg.add("CPUTime")
Pkg.add("JSON")
Pkg.add("HTTPClient")
Pkg.add("LibGit2")
Pkg.add("Dates")
Pkg.clone("git://github.com/christianpeel/USERTime.jl.git")

using CPUTime
using USERTime
