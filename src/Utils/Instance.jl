import Base.show

struct ProblemInstance
    # numeric quantities for bookkeeping
    number_locations::Int16
    number_vehicles::Int8
    number_services::Int8

    # an array (2d) representing the needs of each patient
    requirements::Array{Bool, 2}

    # an array (2d) indicating which services each vehicle can provide
    qualifications::Array{Bool, 2}

    # an array (2d) containing the distance between patients
    distances::Array{Float32, 2}

    # an array (3d) containing the time necessary to a vehicle perform each
    # service in each patient
    processing_times::Array{Float16, 3}

    # an array (2d) containing time values with the start and end f each patient
    # time window
    time_windows::Array{Int16, 2}
end

struct ProblemSolution
    
    ps::Int64

end

function Base.show(io::IO, inst::ProblemInstance)
    # loads of prints

    println(io, "an instance of the HHCRSP problem")
    println(io)
    println(io, "$(inst.number_locations) patients")
    println(io, "$(inst.number_vehicles) vehicles")
    println(io, "$(inst.number_services) services provided")
    println(io)
    println(io, "requirements:")
    Base.print_matrix(io, inst.requirements)
    println(io)
    println(io)
    println(io, "vehicle capabilities (qualifications):")
    Base.print_matrix(io, inst.qualifications)
    println(io)
    println(io)
    println(io, "distances between patients:")
    Base.print_matrix(io, inst.distances)
    println(io)
    println(io)
    println(io, "duration of appointment")
    for i in 1:inst.number_locations
        println(io, "for location $(i)")
        Base.print_matrix(io, inst.processing_times[i, :, :])
        println(io)
    end
    println(io)
    println(io, "time windows for appointments:")
    Base.print_matrix(io, inst.time_windows)
    println(io)
    println(io)
end
