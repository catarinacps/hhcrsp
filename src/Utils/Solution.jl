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


    service_start_times is an array (2d) containing the starting times for each service

    service_start_times example (for the above solution)
        - i(s): patient i, service s
        - t(i,v,s): starting time for service s at patient i with vehicle v

         pat  |  1  | 2  |  3  |  4  |  5  |  6  |  7 |
    ----------|-----|----|-----|-----|-----|-----|----|
      i(s)    | 7(1)|4(1)| 2(2)| 3(3)| 6(3)| 5(1)|7(2)|
    ----------|-----|----|-----|-----|-----|-----|----|
    t(i,1,s)  | 23  |84  |     |     |     |112  |    |
    ----------|-----|----|-----|-----|-----|-----|----|
    t(i,2,s)  |     |    | 82  |     |     |     |124 |
    ----------|-----|----|-----|-----|-----|-----|----|
    t(i,3,s)  |     |    |     | 15  |107  |     |    |
    ----------|-----|----|-----|-----|-----|-----|----|

    t(i,v,s) is calculated as follows:

    t(i,v,s) = max( e(i), b(i,v) )
        - e(i): begin time window of patient i
        - b(i,v): t(k,v,s) +  p(k,s) + d(k,i)
            - p(k,s): processing time of service s at patient k
            - d(k,i): traveling distance between k and i
"""
struct ProblemSolution
    # dictionary containing:
    # (patient, service) => (x, y)
    indexes::Dict{Pair{Int16, Int16}, Pair{Int16, Int16}}

    o::Array{Pair{Int16, Int16}, 2}

    t::Array{Int16, 2}
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
