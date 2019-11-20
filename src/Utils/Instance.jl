import Base.show

struct ProblemInstance
    # numeric quantities for bookkeeping
    number_patients::Int16
    number_vehicles::Int8
    number_services::Int8

    # an array (2d) representing the needs of each patient
    requisitions::Array{Bool, 2}

    # an array (2d) indicating which services each vehicle can provide
    vehicle_services::Array{Bool, 2}

    # an array (2d) containing the distance between patients
    distances::Array{Float32, 2}

    # an array (3d) containing the time necessary to a vehicle perform each
    # service in each patient
    durations::Array{Float16, 3}
end

function Base.show(io::IO, inst::ProblemInstance)
    # loads of prints

    println(io, "an instance of the HHCRSP problem")
    println(io)
    println(io, "$(inst.number_patients) patients")
    println(io, "$(inst.number_vehicles) vehicles")
    println(io, "$(inst.number_services) services provided")
    println(io)
    println(io, "requisitions:")
    Base.print_matrix(io, inst.requisitions)
    println(io)
    println(io, "vehicle capabilities:")
    Base.print_matrix(io, inst.vehicle_services)
    println(io)
    println(io, "distances between patients:")
    Base.print_matrix(io, inst.distances)
    println(io)
    println(io, "duration of appointment")
    for i in 1:inst.number_patients
        println(io, "for patient $(i)")
        Base.print_matrix(io, inst.durations[i, :, :])
    end
end
