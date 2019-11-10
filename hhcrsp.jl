include("src/MathSolver.jl")
include("src/SimulatedAnnealing.jl")

using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "instance"
        help = "path to an instance of the problem"
        arg_type = String
        required = true
    end

    add_arg_group(s, "math solver (GLPK)")

    @add_arg_table s begin
        "math"
        help = "solve using the GLPK solver"
        action = :command
    end

    add_arg_group(s, "simulated annealing")

    @add_arg_table s begin
        "sa"
        help = "solve using the simulated annealing heuristic"
        action = :command

        "--temperature", "-t"
        help = "initial temperature for simulated annealing"
        arg_type = Float64
        default = 30.0
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()

    println("Parsed args:")
    for (arg, value) in parsed_args
        println("  $arg -> $value")
    end
end

main()
