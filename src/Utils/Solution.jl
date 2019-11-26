"""
    ProblemSolution(Dict, Array, Array)

# Attributes:

    solution_matrix is an array (2d) containing the problem solution
    (rows: qualifications; columns: patients)

    solution_matrix example
    - 3 qualifications
    - 7 patients

    qual/pat  |  1  | 2  |  3  |  4  |  5  |  6  |  7 |
    ----------|-----|----|-----|-----|-----|-----|----|
        1     |  7  | 4  |     |     |     |  5  |    |
    ----------|-----|----|-----|-----|-----|-----|----|
        2     |     |    |  2  |     |     |     |  1 |
    ----------|-----|----|-----|-----|-----|-----|----|
        3     |     |    |     |  3  |  6  |     |    |
    ----------|-----|----|-----|-----|-----|-----|----|

    In this solution_matrix:
    - the first vehicle attends patients 7, 4 and 5
    - the second vehicle attends patients 2 and 1
    - the third vehicle attends patients 3 and 6


"""

struct TimeSolution
    starting::Float32
    ending::Float32
    tardiness::Float32
end

struct ProblemSolution
    # dictionary containing:
    # (patient, service) => (x, y)
    indexes::Dict{Pair{Int16, Int16}, Pair{Int16, Int16}}

    o::Array{Pair{Int16, Int16}, 2}

    # the key represents the patient/service pair
    # the value is a time struct with starting time, ending time and tardiness
    t::Dict{Pair{Int16, Int16}, TimeSolution}
end

struct DecisionVariables
    x::Array{Bool, 4}
    t::Array{Float16, 3}
    z::Array{Float16, 2}
end

function solution_to_variables(solution::ProblemSolution,
                               instance::ProblemInstance)::DecisionVariables
    vars = DecisionVariables(zeros(Bool,
                                   instance.number_locations,
                                   instance.number_locations,
                                   instance.number_vehicles,
                                   instance.number_services),
                             zeros(Float16,
                                   instance.number_locations,
                                   instance.number_vehicles,
                                   instance.number_services),
                             zeros(Float16,
                                   instance.number_locations,
                                   instance.number_services))

    for (vehicle, visits) in enumerate(eachrow(solution.o))
        visits = visits[visits .> Pair(-1, -1)]

        last_location = 1 # we start at the garage
        for (patient, service) in visits
            vars.x[last_location, patient, vehicle, service] = true
            last_location = patient
        end

        # and end at the garage
        vars.x[last_location, instance.number_locations, vehicle, 1] = true
    end

    vars.t = copy(solution.t)

    return vars
end
