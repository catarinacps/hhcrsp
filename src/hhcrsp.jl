#!/usr/bin/env julia

include("./Utils/Utils.jl")
include("./SimulatedAnnealing/SimulatedAnnealing.jl")
include("./MathSolver/MathSolver.jl")

using .Utils: parse_commandline, parse_instance, ProblemInstance
using .SimulatedAnnealing
using .MathSolver

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    parsed_args = parse_commandline()

    println("Parsed args:")
    for (arg, value) in parsed_args
        println("  $arg -> $value")
    end

    if parsed_args["%COMMAND%"] == "math"

        MathSolver.solve(verbose = parsed_args["verbose"])

        # do smth
    elseif parsed_args["%COMMAND%"] == "sa"

        SimulatedAnnealing.solve(verbose = parsed_args["verbose"])

        # do smth
    end

    return 0
end

if get(ENV, "COMPILE_BUILD", "false") == "false"
    julia_main(ARGS)
end
