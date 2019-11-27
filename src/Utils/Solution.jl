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