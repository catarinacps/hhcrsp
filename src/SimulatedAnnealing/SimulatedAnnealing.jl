module SimulatedAnnealing

using ..Utils: ProblemInstance, 
                TimeSolution, 
                ProblemSolution,
                get_start_time_window,
                get_end_time_window,
                get_time_distance,
                get_processing_time

"""
    solve(instance[, verbose])

Solves an instance of the HHCRSP problem utilizing the Simulated Annealing
heuristic.

The algorithm here implemented is based on the Simulated Annealing proposed by
Dowsland (1995, p.26).

Receives an `instance` instance of the problem, containing all initial system
data, and can be verbose about its progress when given an `verbose` flag.

# Arguments
- `instance::ProblemInstance`: the instance to be solved
- `verbose::Bool=false`: the verbosity flag

See also: [`parse_instance`](@ref)
"""
function solve(instance::ProblemInstance ; verbose::Bool = false)::ProblemSolution
    # Parameters (i'll just leave 'em here cause idk what to do)
    # what should i use? => wsiu

    T = 100.0 #wsiu
    cooling_factor = 0.9
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
        T = update_temperature(T, cooling_factor)
    end

    return s0
end



function generate_initial_solution(instance::ProblemInstance)::ProblemSolution
    
    patient_service_list = generate_patient_service_list(instance)
    patient_service_list = sort_patients_by_ending_time(patient_service_list)
    indexes = Dict{Pair{Int16, Int16}, Pair{Int16, Int16}}()
    
    x = length(patient_service_list)
    y = instance.number_vehicles
    
    o_matrix = Array{Any,2}(undef, y, x)
    fill!(o_matrix, -1=>-1)
    
    for (index, patient_service) in enumerate(patient_service_list)
            
            vehicle = get_vehicle(patient_service.second, instance)
            o_matrix[vehicle, index] = patient_service
            merge!(indexes, Dict((patient_service) => (vehicle => index)))
    end
    
    time_solutions = compute_time_solutions(instance, o_matrix)
    
    return ProblemSolution(indexes, o_matrix, time_solutions)
end


function generate_patient_service_list(instance::ProblemInstance)
    
    patient_service_list = []
    
    # The first and last requirements are ignored because they are not patients
    for patient in 2:instance.number_locations-1
        
        patient_requirements = instance.requirements[patient, :]
        for (index, requirement) in enumerate(patient_requirements)
            
            if requirement
                push!(patient_service_list, patient=>index)
            end
        end
    end
        
    return patient_service_list
end


#TODO
function sort_patients_by_ending_time(patient_service_list)
    
    return patient_service_list

end


function get_vehicle(service, instance)
   
    possible_vehicles = []
    for vehicle in 1:instance.number_vehicles
        
        vehicle_qualifications = instance.qualifications[vehicle, :]
        if vehicle_qualifications[service] == 1
            push!(possible_vehicles, vehicle)
        end
        
    end
    
    return rand(possible_vehicles)
end


function compute_time_solutions(instance, o_matrix)::Dict{Pair{Int16, Int16}, TimeSolution}
   
    t_dict = Dict{Pair{Int16, Int16}, TimeSolution}()

    for vehicle in 1:instance.number_vehicles
    
        previous_ending_time = 0
        previous_visited = 1
        for patient_service in o_matrix[vehicle, :]
            
            patient = patient_service.first
            service = patient_service.second
            
            if patient == -1
                continue 
            end
            
            beginning_time_window = get_start_time_window(instance, patient)
            arrival_time = (previous_ending_time + 
                            + get_time_distance(instance, previous_visited, patient))
            
            starting_time = max(beginning_time_window, arrival_time)
            ending_time = starting_time + get_processing_time(instance, patient, vehicle, service)
            
            end_time_window = get_end_time_window(instance, patient)
            if ending_time > end_time_window
                tardiness = ending_time - end_time_window
            else
                tardiness = 0
            end

            merge!(t_dict, Dict((patient_service) => TimeSolution(starting_time, ending_time, tardiness)))     
        end  
    end
    
    return t_dict
end



#TODO
function compute_score(solution::ProblemSolution, lambdas::Array{Float16})::Float32
    return 42.0 + solution.solution_matrix[1]
end

#TODO
function generate_neighbor(solution::ProblemSolution)::ProblemSolution
    return ProblemSolution(zeros(Int16, 3, 7), zeros(Int16, 3, 7))
end

function update_temperature(temperature::Float32, cooling_factor::Float32)::Float32
    # The following implementation is based on the handout of the course,
    # but this is the simplest way to reduce the temperature.
    # On Goldberg et. al. (2016, p. 111) there are several other sophisticated
    # ways of doing that.
    return temperature * cooling_factor
end

end # module
