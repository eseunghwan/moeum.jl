module moeum
    export MOEUM, io

    #includes
    include("io.jl")

    mutable struct MOEUM
        """
        An Tabular Struct for Massive Data Processing

        **Common methods**
        """

        ###parameters
        #arguments
        dat_sori::Array
        hol_sori::Array
        name::String
        #hidden parameters
        _sok_dict::Dict
        _sok_arr::Array
        
        ###functions
        #modify

        #output
        to_dataframe::Function
        to_dict::Function
        to_csv::Function
        to_db::Function

        #init
        function MOEUM(;dat_sori = [], hol_sori = [], name = "moeum.MOEUM")
            #init instance
            instance = new(dat_sori, hol_sori, name)
            instance._sok_dict = Dict(dat => [] for dat in instance.dat_sori)
            for hol in instance.hol_sori
                for i in eachindex(instance.dat_sori)
                    append!(instance._sok_dict[instance.dat_sori[i]], hol[i])
                end
            end
            instance._sok_arr = [Dict(instance.dat_sori[i] => hol[i] for i in eachindex(instance.dat_sori)) for hol in instance.hol_sori]

            #output functions
            instance.to_dataframe = function()
                return io.output.to_dataframe(instance)
            end

            instance.to_dict = function(;orientation::String = "Dict")
                return io.output.to_dict(instance, orientation)
            end

            instance.to_csv = function(;csv_path::String = joinpath(pwd(), string(instance.name, ".csv")))
                return io.output.to_csv(instance, csv_path)
            end

            return instance
        end
    end
    function Base.show(io::Base.IO, instance::MOEUM)
        max_lengths = Dict(key => ceil(Int, maximum(insert!([length(string(item)) for item in instance._sok_dict[key]], 1, length(key))) * 1.5) for key in keys(instance._sok_dict))
        max_lengths["index"] = maximum([length(string(length(instance._sok_arr))), length("index")])
        #using @printf for easy printing
        @printf("[ %s | %s × %s ]\n", instance.name, length(instance._sok_dict), length(instance._sok_arr))

        @printf("| %s | ", lpad("", max_lengths["index"], " "))
        for key in keys(instance._sok_dict)
            @printf("%s | ", lpad(key, max_lengths[key], " "))
        end
        @printf("\n")

        if length(instance._sok_arr) > 20
            print_arr = instance._sok_arr[1:20]
        else
            print_arr = instance._sok_arr
        end
        for i in eachindex(print_arr)
            arr = print_arr[i]
            @printf("| %s | ", lpad(i, max_lengths["index"], " "))
            for key in keys(arr)
                @printf("%s | ", lpad(arr[key], max_lengths[key], " "))
            end
            @printf("\n")
        end
    end
end
