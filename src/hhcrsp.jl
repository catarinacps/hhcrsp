#!/usr/bin/env julia

include("MathSolver/MathSolver.jl")
include("SimulatedAnnealing/SimulatedAnnealing.jl")

using ArgParse

function parse_commandline()
    s = ArgParseSettings("solve an instance of the HHCRSP problem using either a math solver or a heuristic",
                         commands_are_required = true,
                         version = "0.1",
                         add_version = true)

    @add_arg_table s begin
        "instance"
        help = "path to an instance of the problem"
        arg_type = String
        required = true

        "--verbose", "-v"
        help = "turn on verbosity"
        action = :store_true

        "--seed", "-s"
        help = "seed to be used in pseudo random number generation"
        arg_type = Int16
        default = rand(Int16)
    end

    add_arg_group(s, "math solver (GLPK)")

    @add_arg_table s begin
        "math"
        help = "solve using the GLPK solver"
        action = :command

        "--max-time", "-m"
        help = "maximum time to let the solver run in seconds"
        arg_type = Int32
        default = Int32(1200)
    end

    add_arg_group(s, "simulated annealing")

    @add_arg_table s begin
        "sa"
        help = "solve using the simulated annealing heuristic"
        action = :command

        "--temperature", "-t"
        help = "initial temperature for simulated annealing"
        arg_type = Float16
        default = Float16(30.0)
    end

    return parse_args(s)
end

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
