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
function solve(instance::ProblemInstance, 
                lambdas::Array{Float16} ; 
                verbose::Bool = false)::Tuple{ProblemSolution, Float64}

    # what should i use? => wsiu
    T = Float32(100.0) #wsiu
    cooling_factor = Float32(0.9) # recall the reference that said to use a value between [0.88 and 0.99] 
    max_outer_iterations = 100  #wsiu
    max_inner_iterations = 10   #wsiu
    # note: total iterations = max outer * max inner


    s0 = generate_initial_solution(instance)
    s0_score = compute_score(instance, s0, lambdas)
    s_best = deepcopy(s0)
    s_best_score = deepcopy(s0_score)
    

    for i in 1:max_outer_iterations
        for j in 1:max_inner_iterations
            s1 = generate_neighbor(instance, s0)
            s1_score = compute_score(instance, s1, lambdas)
        
            delta = s1_score - s0_score

            if delta < 0
                s0 = s1
                s0_score = s1_score
                
                if s0_score < s_best_score
                    s_best = deepcopy(s0)
                    s_best_score = deepcopy(s0_score)
                end

            else
                x = rand()
                if x < (exp(-delta / T))
                    s0 = s1
                    s0_score = s1_score
                end
            end

            if verbose
                println("\n\n")
                println("SA iteration: ", j + ((i-1)*10))
                println("Temperature: ", T)
                println("Best score overall: ", s_best_score)
                println("Current score: ", s0_score)
            end

        end
        T = update_temperature(T, cooling_factor)
    end

    if s_best_score > s0_score
        return (s_best, s_best_score)
    end

    return (s0, s0_score)
end



function generate_initial_solution(instance::ProblemInstance)::ProblemSolution
    
    patient_service_list = generate_patient_service_list(instance)
    patient_service_list = sort_patients_by_ending_time(instance, patient_service_list)
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


function generate_patient_service_list(instance::ProblemInstance)::Array{Pair{Int16, Int16}}
    
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


function sort_patients_by_ending_time(  instance::ProblemInstance, 
    patient_service_list::Array{Pair{Int16, Int16}})::Array{Pair{Int16, Int16}}

    sortable_patient_service_list = []

    for patient_service in patient_service_list
        push!(sortable_patient_service_list, build_sortable_tuple(instance, patient_service))
    end

    sorted_patient_service_list = sort_patient_service(sortable_patient_service_list)
    return sorted_patient_service_list
end


function sort_patient_service(sortable_patient_service_list)::Array{Pair{Int16, Int16}}
   
    sort!(sortable_patient_service_list, by = x -> x[2])
    
    # Remove ending time window from data structure
    sorted_patient_service_list = []
    for (patient_service, ending_time) in sortable_patient_service_list
        push!(sorted_patient_service_list, patient_service)
    end
    return sorted_patient_service_list
end

# Tuple: ((Patient => Service), Patient Ending Time Window)
function build_sortable_tuple(instance::ProblemInstance, 
            patient_service::Pair{Int16, Int16})::Tuple{Pair{Int16, Int16}, Int16}

    patient = patient_service.first
    ending_time_window = instance.time_windows[2, patient] 
    return (patient_service, ending_time_window)
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
        for (patient, service) in o_matrix[vehicle, :]
            
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

            merge!(t_dict, Dict((patient => service) => TimeSolution(starting_time, ending_time, tardiness)))     

            previous_ending_time = ending_time
            previous_visited = patient
        end  
    end
    
    return t_dict
end



function compute_score( instance::ProblemInstance, 
                        solution::ProblemSolution, 
                        lambdas::Array{Float16,1})::Float32
    
    total_distance = compute_total_distance_traveled(instance, solution)
    
    total_tardiness = 0
    max_tardiness = 0
    for (patient_service, time_solution) in solution.t
    
        total_tardiness += time_solution.tardiness
        if time_solution.tardiness > max_tardiness
            max_tardiness = time_solution.tardiness
        end
    end
    
    score = ((lambdas[1]*total_distance) +
            (lambdas[2]*total_tardiness) +
            (lambdas[3]*max_tardiness))
    
    return score
end


function compute_total_distance_traveled(instance::ProblemInstance, 
                                        solution::ProblemSolution)::Float32

    total_distance = 0
    for vehicle in 1:instance.number_vehicles
       
        previous_location = 1
        for (location, service) in solution.o[vehicle, :]
            
            if location == -1
                continue 
            end
            
            total_distance += get_time_distance(instance, previous_location, location)
            previous_location = location
            
        end
    end
    
    return total_distance
end


# there are two random ways which can generate a neighbor
# 1: swapping two columns from the o matrix
# 2: changing row of a (patient, service) pair in the o matrix
function generate_neighbor(instance::ProblemInstance, solution::ProblemSolution)::ProblemSolution
    
    neighbor = deepcopy(solution)
    
    way = rand([1,2])
    if way == 1
        swap_columns(neighbor)
        
    else # change row (if it's changeable)
        
        (patient, service), (x, y) = rand(neighbor.indexes)
        possible_rows = get_possible_rows(instance, service, x)
        
        if isempty(possible_rows)
            swap_columns(neighbor)
            
        else
            change_to_row = rand(possible_rows)
            neighbor.o[x,y] = (Int16(-1) => Int16(-1)) 
            neighbor.o[change_to_row, y] = (patient => service)
        end
    end
    
    return neighbor
end


function swap_columns(neighbor::ProblemSolution)
    
    col1 = rand(1:length(neighbor.o[1, :]))
    col2 = rand(1:length(neighbor.o[1, :]))
        
    temp_col_content = neighbor.o[:, col2]
    neighbor.o[:, col2] = neighbor.o[:, col1]
    neighbor.o[:, col1] = temp_col_content
end


function get_possible_rows(instance::ProblemInstance, service::Int16, row::Int16)::Array{Int16,1}
    
    possible_rows = []
    for vehicle in 1:instance.number_vehicles
        if instance.qualifications[vehicle, service] && vehicle != row
            push!(possible_rows, vehicle)
        end
    end

    return possible_rows
end


function update_temperature(temperature::Float32, cooling_factor::Float32)::Float32
    # The following implementation is based on the handout of the course,
    # but this is the simplest way to reduce the temperature.
    # On Goldberg et. al. (2016, p. 111) there are several other sophisticated
    # ways of doing that.
    return temperature * cooling_factor
end

end # module
