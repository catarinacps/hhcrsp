module SimulatedAnnealing

# using SimpleWeightedGraphs
using ..Utils: ProblemInstance, ProblemSolution

"""
    solve(instance[, verbose])

Solves an instance of the HHCRSP problem utilizing the Simulated Annealing
heuristic.

Receives an `instance` instance of the problem, containing all initial system
data, and can be verbose about its progress when given an `verbose` flag.

# Arguments
- `instance::ProblemInstance`: the instance to be solved
- `verbose::Bool=false`: the verbosity flag

See also: [`parse_instance`](@ref)
"""
function solve(instance::ProblemInstance ; verbose::Bool = false)::ProblemSolution
    println("hi!")

    return ProblemSolution()
end

end # module
