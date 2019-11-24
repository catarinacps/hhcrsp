using ArgParse

function parse_commandline(arguments_list::Vector{String})
    s = ArgParseSettings(
        "solve an instance of the HHCRSP problem using either a math solver or a heuristic",
        commands_are_required = true)

    @add_arg_table s begin
        "instance"
        help = "path to an instance of the problem"
        arg_type = String
        required = true

        "--verbose", "-v"
        help = "turn on verbosity"
        action = :store_true

        "--seed", "-s"
        help = "seed to be used in pseudo random number generation"
        arg_type = Int16
        default = abs(rand(Int16))

        "--lambda", "-l"
        help = "lambda preference values to objective function"
        nargs = 3
        arg_type = Float16
        default = [Float16(1/3), Float16(1/3), Float16(1/3)]
    end

    add_arg_group(s, "math solver (GLPK)")

    @add_arg_table s begin
        "math"
        help = "solve using the GLPK solver"
        action = :command

        "--max-time", "-m"
        help = "maximum time to let the solver run (in seconds)"
        arg_type = Int32
        default = Int32(1200)
    end

    add_arg_group(s, "simulated annealing")

    @add_arg_table s begin
        "sa"
        help = "solve using the simulated annealing heuristic"
        action = :command

        "--temperature", "-t"
        help = "initial temperature for simulated annealing"
        arg_type = Float16
        default = Float16(30.0)
    end

    return parse_args(arguments_list, s)
end

function parse_instance(path_to_instance::String ; verbose::Bool = false)::ProblemInstance
    if !isfile(path_to_instance)
        println(stderr, "Instance file not found...")
        exit(1)
    end

    verbose && println("Opening instance file!")

    open(path_to_instance) do file
        if readline(file) == "nbNodes"
            num_nodes = parse(Int16, readline(file))
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "nbVehi"
            num_vehi = parse(Int8, readline(file))
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "nbServi"
            num_servi = parse(Int8, readline(file))
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "r"
            requisitions = zeros(Bool, num_nodes, num_servi)
            for row in 1:num_nodes
                requisitions[row, :] .= parse.(Bool, split(readline(file), " "))
            end
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "DS"
            # do we need to consider double service patients?
            readline(file)
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "a"
            possible_servi = zeros(Bool, num_vehi, num_servi)
            for row in 1:num_vehi
                possible_servi[row, :] .= parse.(Bool, split(readline(file), " "))
            end
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "x"
            # why should we need the distance?
            readline(file)
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "y"
            # why should we need the distance?
            readline(file)
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "d"
            dists = zeros(Float32, num_nodes, num_nodes)
            for row in 1:num_nodes
                dists[row, :] .= parse.(Float32, split(readline(file), " "))
            end
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "p"
            times = zeros(Float16, num_nodes, num_vehi, num_servi)
            for patient in 1:num_nodes
                for row in 1:num_vehi
                    times[patient, row, :] .= parse.(Float32, split(readline(file), " "))
                end
            end
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "mind"
            # do we need to consider double service patients?
            readline(file)
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "maxd"
            # do we need to consider double service patients?
            readline(file)
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "e"
            window = zeros(Int16, 2, num_nodes)
            window[1, :] .= parse.(Int16, split(readline(file), " "))
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        if readline(file) == "l"
            window[2, :] .= parse.(Int16, split(readline(file), " "))
        else
            println(stderr, "Instance file is non-conformant...")
            exit(2)
        end

        return ProblemInstance(num_nodes,
                               num_vehi,
                               num_servi,
                               requisitions,
                               possible_servi,
                               dists,
                               times,
                               window)
    end
end
