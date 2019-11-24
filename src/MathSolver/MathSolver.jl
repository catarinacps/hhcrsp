module MathSolver

using JuMP
using GLPK
using ..Utils: ProblemInstance, ProblemSolution

# just an example
# i still need to look into the parsing of a file and the passage of parameters
# use ritt's example solutions!

"""
    solve(instance[, verbose])

Solves an instance of the HHCRSP problem utilizing the GLPK mathematical solver.
Receives an `instance` instance of the problem, containing all initial system
data, and can be verbose about its progress when given an `verbose` flag.

# Arguments
- `instance::ProblemInstance`: the instance to be solved
- `verbose::Bool=false`: the verbosity flag

See also: [`parse_instance`](@ref)
"""
function solve(instance::ProblemInstance ; verbose::Bool = false)::ProblemSolution
    m = Model(with_optimizer(GLPK.Optimizer))

    # @variable(m, x1 >= 0)
    # @variable(m, x2 >= 0);

    # @objective(m,Max,10*x1+20*x2)

    # @constraints(m, begin
    #              0.1*x1+0.1*x2 <= 200
    #              0.125*x2 <= 800
    #              2*x1+3*x2 <= 5*40*60
    #              end)

    # optimize!(m)

    # verbose && println("A solucao otima e vender $(value(x1)) paes e ",
    #                    "$(value(x2)) baurus completos com um lucro total de $(objective_value(m)).")

    return ProblemSolution()
end

end # module
