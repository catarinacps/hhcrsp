#!/usr/bin/env julia

include("./Utils/Utils.jl")
include("./SimulatedAnnealing/SimulatedAnnealing.jl")
include("./MathSolver/MathSolver.jl")

using .Utils: parse_commandline, parse_instance, ProblemInstance, ProblemSolution
using .SimulatedAnnealing
using .MathSolver

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    parsed_args = parse_commandline(ARGS)

    instance = parse_instance(parsed_args["instance"])
    verbose = parsed_args["verbose"]

    if verbose
        println("Parsed args:")
        for (arg, value) in parsed_args
            println("  $arg -> $value::$(typeof(value))")
        end
    end

    verbose && show(instance)

    if parsed_args["%COMMAND%"] == "math"
        # gather either defined or default values
        lambdas = parsed_args["lambda"]
        max_time = parsed_args["max-time"]
        output = parsed_args["output"]

        # call the solver with said values

        ret = MathSolver.solve(instance,
                               lambdas,
                               max_time,
                               output,
                               verbose = verbose)

        ret && verbose && println("Success modeling!")

    elseif parsed_args["%COMMAND%"] == "sa"
        # gather either defined or default values
        lambdas = parsed_args["lambda"]
        temperature = parsed_args["temperature"]
        strategy = parsed_args["strategy"]
        factor = parsed_args["factor"]
        iterations = parsed_args["iterations"]

        ret = SimulatedAnnealing.solve(instance,
                                       lambdas,
                                       temperature,
                                       strategy,
                                       factor,
                                       iterations,
                                       verbose = verbose)

        println("Score: $(ret.second)")
    end

    return 0
end

if get(ENV, "COMPILE_BUILD", "false") == "false"
    julia_main(ARGS)
end
