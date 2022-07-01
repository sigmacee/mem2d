(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using Mem2d
push!(Base.modules_warned_for, Base.PkgId(Mem2d))
Mem2d.main()
