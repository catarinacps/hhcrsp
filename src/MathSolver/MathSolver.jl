module MathSolver

using JuMP
using Cbc
using MathOptFormat
using ..Utils: ProblemInstance, ProblemSolution

"""
    solve(instance, lambdas, time_limit[, verbose])

Solves an instance of the HHCRSP problem utilizing the GLPK mathematical solver.
Receives an `instance` instance of the problem, containing all initial system
data, and can be verbose about its progress when given an `verbose` flag.

# Arguments
- `instance::ProblemInstance`: the instance to be solved
- `lambdas::Array{Float16}`: weights to the objective function performance measure
- `time_limit::Int32`: time limit to the solver
- `verbose::Bool=false`: the verbosity flag

See also: [`parse_instance`](@ref)
"""
function solve(instance::ProblemInstance,
               lambdas::Array{Float16},
               time_limit::Int32
               ; verbose::Bool = false)::ProblemSolution
    # we'll be using GLPK here, as it's free
    model = Model(with_optimizer(Cbc.Optimizer, seconds = time_limit))

    # all problem sets
    C0 = 1:(instance.number_locations - 1)
    C = 2:(instance.number_locations - 2)
    S = 1:instance.number_services
    V = 1:instance.number_vehicles

    # println(C0)

    # all problem instance data
    d = instance.distances
    a = instance.qualifications
    r = instance.requirements
    p = instance.processing_times
    w = instance.time_windows

    # garage (office) indexes
    g = 1

    # binary variable
    # defines if vehicle v moves from i to j to provide service s
    # order of indexes: x[i, j, v, s]
    @variable(model, x[C0, C0, V, S], binary = true)

    # linear variable
    # defines the start time of service s provided by vehicle v on i
    # order of indexes: t[i, v, s]
    @variable(model, t[C0, V, S] >= 0)

    # linear variable
    # defines the "lateness" of the start time of service s on i
    @variable(model, z[C0, S] >= 0)

    # performance measures
    @variable(model, D >= 0)
    @variable(model, T >= 0)
    @variable(model, T_max >= 0)

    # objective function
    # according to the lambda values, try to minimize restrictions 2, 3 and 4
    @objective(model, Min, lambdas[1] * D + lambdas[2] * T + lambdas[3] * T_max)

    # constraint (2)
    # the total distance traveled by the vehicles
    @constraint(model,
                sum(d[i, j] * x[i, j, v, s] for i in C0, j in C0, v in V, s in S)
                == D)

    # constraint (3)
    # the total tardiness of all services
    @constraint(model,
                sum(z[i, s] for i in C, s in S)
                == T)

    # constraint (4)
    # the maximum tardiness observed
    @constraint(model, [i in C, s in S],
                T_max >= z[i, s])

    # constraint (5.1)
    # guarantee that we'll start at the office
    @constraint(model, [v in V],
                sum(x[g, j, v, s] for j in C0, s in S)
                == 1)

    # constraint (5.2)
    # guarantee that we'll end at the office
    @constraint(model, [v in V],
                sum(x[i, g, v, s] for i in C0, s in S)
                == 1)

    # constraint (6)
    # inflow-outflow conditions: vehicle v who visits i must leave
    @constraint(model, [i in C, v in V],
                sum(x[i, j, v, s] for j in C0, s in S)
                ==
                sum(x[j, i, v, s] for j in C0, s in S))

    # constraint (7)
    # defines that every service will be conducted by one qualified caregiver
    @constraint(model, [i in C, s in S],
                sum(a[v, s] * x[j, i, v, s] for j in C0, v in V if i != j)
                == r[i, s])

    # constraint (8)
    # determines the start times of services in respect to durations and
    # traveling times
    @constraint(model, [i in C0, j in C, v in V, s1 in S, s2 in S],
                t[i, v, s1] + p[i, v, s1] + d[i, j]
                <=
                t[j, v, s2] + 1e6 * (1 - x[i, j, v, s2]))

    # constraint (9)
    # compliance with the start time
    @constraint(model, [i in C, v in V, s in S],
                t[i, v, s] >= w[1, i])

    # constraint (10)
    # compliance with the end time
    @constraint(model, [i in C, v in V, s in S],
                t[i, v, s] <= w[2, i] + z[i, s])

    # domain (13)
    # garantees that x is binary and only 1 when we are qualified and required
    # to provide said service
    @constraint(model, [i in C0, j in C0, v in V, s in S],
                x[i, j, v, s] <= a[v, s] * r[j, s])

    lp_model = MathOptFormat.LP.Model()

    MOI.copy_to(lp_model, backend(model))

    MOI.write_to_file(lp_model, "modelo.lp")

    # JuMP.optimize!(model)

    # if verbose
    #     println("Objective is: ", JuMP.objective_value(model))
    # end

    return ProblemSolution(Dict{Pair{Int16, Int16}, Pair{Int16, Int16}}(),
                           Array{Pair{Int16, Int16}}(undef, 1, 1),
                           zeros(Int16, 1, 1))
end

end # module
