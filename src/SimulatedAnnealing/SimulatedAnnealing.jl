module SimulatedAnnealing

# using SimpleWeightedGraphs
using ..Utils: ProblemInstance, ProblemSolution

"""
    solve(instance[, verbose])

Solves an instance of the HHCRSP problem utilizing the Simulated Annealing
heuristic.

The algorithm here implemented is based on the Simulated Annealing proposed by Downsland (1995, p.26).

Receives an `instance` instance of the problem, containing all initial system
data, and can be verbose about its progress when given an `verbose` flag.

# Arguments
- `instance::ProblemInstance`: the instance to be solved
- `verbose::Bool=false`: the verbosity flag

See also: [`parse_instance`](@ref)
"""
function solve(instance::ProblemInstance ; verbose::Bool = false)::ProblemSolution
    
    # Parameters (i'll just leave 'em here cause idk what to do)
    T = 1 #what should i use? =>wsiu
    cooling_factor = 1 #wsiu
    s0 = generate_initial_solution(instance)
    s0_score = compute_score(s0)
    max_outer_iterations = 10  #wsiu
    max_inner_iterations = 5   #wsiu



    for i in 1:max_outer_iterations

        for j in 1:max_inner_iterations
            s1 = generate_neighbor(s0)
            s1_score = compute_score(s1)
            delta = s1_score - s0_score


            if delta < 0    # "if s1 minimizes more the function" -- temp comment
                s0 = s1
                s0_score = s1_score

            else 
                x = rand()
                if x < (exp(-delta / T))
                    s0 = s1
                    s0_score = s1_score
                end
            end

        end
        T = update_temperature(T)
    end


    return ProblemSolution(1)
end


#TODO
function generate_initial_solution(instance::ProblemInstance)::ProblemSolution

    return ProblemSolution(42)

end

#TODO
function compute_score(solution::ProblemSolution)::Float32

    return 42.0 + solution.ps

end

#TODO
function generate_neighbor(solution::ProblemSolution)::ProblemSolution

    return ProblemSolution(solution.ps + 1)

end

#TODO
function update_temperature(temperature)::Float32

    return temperature + 2

end

end # module
