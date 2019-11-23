#!/usr/bin/env julia

include("./Utils/Utils.jl")
include("./SimulatedAnnealing/SimulatedAnnealing.jl")
include("./MathSolver/MathSolver.jl")

using .Utils: parse_commandline, parse_instance, ProblemInstance, ProblemSolution
using .SimulatedAnnealing
using .MathSolver

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    parsed_args = parse_commandline()

    println("Parsed args:")
    for (arg, value) in parsed_args
        println("  $arg -> $value::$(typeof(value))")
    end

    instance = parse_instance(parsed_args["instance"])
    verbose_flag = parsed_args["verbose"]

    verbose_flag && show(instance)

    if parsed_args["%COMMAND%"] == "math"

        MathSolver.solve(instance, verbose = verbose_flag)

        # do smth
    elseif parsed_args["%COMMAND%"] == "sa"

        SimulatedAnnealing.solve(instance, verbose = verbose_flag)

        # do smth
    end

    return 0
end

if get(ENV, "COMPILE_BUILD", "false") == "false"
    julia_main(ARGS)
end
