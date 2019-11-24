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
function solve(instance::ProblemInstance,
               lambdas::Array{Float16},
               time_limit::Int32
               ; verbose::Bool = false)::ProblemSolution
    # we'll be using GLPK here, as it's free
    model = Model(with_optimizer(GLPK.Optimizer, tm_lim = time_limit))

    # binary variable
    # defines if vehicle v moves from i to j to provide service s
    # order of indexes: x[i, j, v, s]
    @variable(model,
              x[1:instance.number_locations,
                1:instance.number_locations,
                1:instance.number_vehicles,
                1:instance.number_services],
              binary = true)

    # linear variable
    # defines the start time of service s provided by vehicle v on i
    # order of indexes: t[i, v, s]
    @variable(model,
              t[1:instance.number_locations,
                1:instance.number_vehicles,
                1:instance.number_services] >= 0)

    # linear variable
    # defines the "lateness" of the start time of service s on i
    @variable(model,
              z[1:instance.number_locations,
                1:instance.number_services] >= 0)

    # performance measures
    @variable(model, D >= 0)
    @variable(model, T >= 0)
    @variable(model, T_max >= 0)

    # objective function
    # according to the lambda values, try to minimize restrictions 2, 3 and 4
    @objective(model,
               Min,
               lambdas[1] * D + lambdas[2] * T + lambdas[3] * T_max)

    # constraint (2)
    # the total distance traveled by the vehicles
    @constraint(model,
                sum(instance.distances[i, j] * x[i, j, v, s] for
                    i in 1:instance.number_locations,
                    j in 1:instance.number_locations,
                    v in 1:instance.number_vehicles,
                    s in 1:instance.number_services) == D)

    # constraint (3)
    # the total tardiness of all services
    @constraint(model,
                sum(z[i, s] for
                    i in 2:(instance.number_locations - 1),
                    s in 1:instance.number_services) == T)

    # constraint (4)
    # the maximum tardiness observed
    @constraint(model, [i in 2:(instance.number_locations - 1),
                        s in 1:instance.number_services],
                T_max >= z[i, s])

    # constraint (5.1)
    # guarantee that we'll start at the office
    @constraint(model, [v in 1:instance.number_vehicles],
                sum(x[1, j, v, s] for
                    j in 1:instance.number_locations,
                    v in 1:instance.number_vehicles,
                    s in 1:instance.number_services) == 1)

    # constraint (5.2)
    # guarantee that we'll end at the office
    @constraint(model, [v in 1:instance.number_vehicles],
                sum(x[i, instance.number_locations, v, s] for
                    i in 1:instance.number_locations,
                    v in 1:instance.number_vehicles,
                    s in 1:instance.number_services) == 1)

    # constraint (6)
    # inflow-outflow conditions: vehicle v who visits i must leave
    @constraint(model, [i in 2:(instance.number_locations - 1),
                        v in 1:instance.number_vehicles],
                sum(x[i, j, v, s] for
                    j in 1:instance.number_locations,
                    s in 1:instance.number_services) ==
                sum(x[j, i, v, s] for
                    j in 1:instance.number_locations,
                    s in 1:instance.number_services))

    # constraint (7)
    # defines that every service will be conducted by one qualified caregiver
    @constraint(model, [i in 2:(instance.number_locations - 1),
                        s in 1:instance.number_services],
                sum(instance.qualifications[v, s] * x[j, i, v, s] for
                    j in 1:instance.number_locations,
                    v in 1:instance.number_vehicles) == instance.requirements[i, s])

    # constraint (8)
    #
    @constraint(model, [i in 1:instance.number_locations,
                        j in 2:(instance.number_locations - 1),
                        v in 1:instance.number_vehicles,
                        s1 in 1:instance.number_services,
                        s2 in 1:instance.number_services],
                t[i, v, s1] + instance.processing_times[i, v, s1] + instance.distances[i, j] <=
                t[j, v, s2] + (1 - x[i, j, v, s2]))

    # constraint (9)
    # compliance with the start time
    @constraint(model, [i in 2:(instance.number_locations - 1),
                        v in 1:instance.number_vehicles,
                        s in 1:instance.number_services],
                t[i, v, s] >= instance.time_windows[1, i])

    # constraint (10)
    # compliance with the end time
    @constraint(model, [i in 2:(instance.number_locations - 1),
                        v in 1:instance.number_vehicles,
                        s in 1:instance.number_services],
                t[i, v, s] <= instance.time_windows[2, i] + z[i, s])

    # domain (13)
    # garantees that x is binary and only 1 when we are qualified and required
    # to provide said service
    @constraint(model, [i in 1:instance.number_locations,
                        j in 1:instance.number_locations,
                        v in 1:instance.number_vehicles,
                        s in 1:instance.number_services],
                x[i, j, v, s] <= instance.qualifications[v, s] * instance.requirements[j, s])

    JuMP.optimize!(model)

    if verbose
        println("Objective is: ", JuMP.objective_value(model))
    end

    return ProblemSolution()
end

end # module
