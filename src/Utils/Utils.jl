module Utils

include("./Parsing.jl")
include("./Instance.jl")
include("./Solution.jl")

export parse_commandline, parse_instance, ProblemInstance, ProblemSolution

end
