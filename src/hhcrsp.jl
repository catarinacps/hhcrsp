#!/usr/bin/env julia

include("./Utils/Utils.jl")
include("./MathSolver/MathSolver.jl")
include("./SimulatedAnnealing/SimulatedAnnealing.jl")

using ArgParse
using .MathSolver
using .SimulatedAnnealing
using .Utils

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    parsed_args = parse_commandline()

    println("Parsed args:")
    for (arg, value) in parsed_args
        println("  $arg -> $value")
    end

    return 0
end

if get(ENV, "COMPILE_BUILD", "false") == "false"
    julia_main(ARGS)
end
