module Utils

include("./Parsing.jl")
include("./Instance.jl")
include("./Solution.jl")

export parse_commandline, 
        parse_instance,
        get_start_time_window,
        get_end_time_window,
        get_time_distance,
        get_processing_time, 
        ProblemInstance, 
        TimeSolution, 
        ProblemSolution
        
end
