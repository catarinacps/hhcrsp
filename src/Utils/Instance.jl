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
    solution_matrix::Array{Int16, 2}
    """
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

    service_start_times::Array{Int16, 2}
    """
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
