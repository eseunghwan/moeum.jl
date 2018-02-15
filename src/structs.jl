module structs

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
        #internal functions
        select::Function
        to_string::Function

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
            key_list = collect(Base.keys(instance._sok_dict))
            instance._sok_dict = Dict(key_list[i]=> ColumnSet(instance._sok_dict[key_list[i]], i, instance.name) for i in eachindex(key_list))
            instance._sok_arr = [RowSet(Dict(instance.dat_sori[j] => instance.hol_sori[i][j] for j in eachindex(instance.dat_sori)), i, instance.name) for i in eachindex(instance.hol_sori)]

            #internal functions
            instance.select = function(key)
                return io.internal.select(instance, key)
            end

            instance.to_string = function()
                return io.internal.to_string(instance)
            end

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
        #=sok_dict, sok_arr = Dict(key=>value.data for (key, value) in instance._sok_dict), [item.data for item in instance._sok_arr]
        max_lengths = Dict(key => ceil(Int, maximum(insert!([length(string(item)) for item in sok_dict[key]], 1, length(key))) * 1.5) for key in keys(sok_dict))
        max_lengths["index"] = maximum([length(string(length(sok_arr))), length("index")])
        #using @printf for easy printing
        @printf("[ %s | %s × %s ]\n", instance.name, length(sok_dict), length(sok_arr))

        @printf("| %s | ", lpad("", max_lengths["index"], " "))
        for key in keys(sok_dict)
            @printf("%s | ", lpad(key, max_lengths[key], " "))
        end
        @printf("\n")

        if length(sok_arr) > 20
            print_arr = sok_arr[1:20]
        else
            print_arr = sok_arr
        end
        for i in eachindex(print_arr)
            arr = print_arr[i]
            @printf("| %s | ", lpad(i, max_lengths["index"], " "))
            for key in keys(arr)
                @printf("%s | ", lpad(arr[key], max_lengths[key], " "))
            end
            @printf("\n")
        end=#

        print(io, instance.to_string())
    end

    mutable struct ColumnSet
        ###parameters
        #arguments
        data::Array
        #hidden parameters
        _data_type::String
        _parent_name::String
        _col_num::Int

        ###functions
        #descriptive statistics/common
        describe::Function
        count::Function
        #descriptive statistics/numeric
        sum::Function
        avg::Function
        std::Function
        min::Function
        max::Function
        #descriptive statistics/string
        #top::Function
        unique::Function
        #descriptive statistics/invalid
        _invalid::Function

        #init
        function ColumnSet(data = [], col_num = 0, parent_name = "moeum.MOEUM")
            instance = new(data) ; instance._parent_name, instance._col_num = parent_name, col_num
            type_count = Dict("Numeric"=>0, "String"=>0)
            for item in instance.data
                if typeof(item)<:Real
                    type_count["Numeric"] += 1
                elseif typeof(item)<:String
                    type_count["String"] += 1
                end
            end

            #descriptive statistics/invalid
            instance._invalid = function()
                println(string("invalid for data-type is ", instance._data_type))
                return false
            end

            #set default invalid to functions
            instance.sum, instance.avg, instance.std, instance.min, instance.max, instance.unique = [instance._invalid for i in 1:6]
            if type_count["Numeric"] >= type_count["String"]
                instance._data_type = "Numeric"
                instance.data = collect(float(item) for item in instance.data)

                #descriptive statistics/numeric
                instance.sum = function()
                    return Base.sum(instance.data)
                end

                instance.avg = function()
                    return Base.mean(instance.data)
                end

                instance.std = function()
                    return Base.std(instance.data)
                end

                instance.max = function()
                    Base.maximum(instance.data)
                end

                instance.min = function()
                    Base.minimum(instance.data)
                end
            else
                instance._data_type = "String"
                instance.data = collect(string(item) for item in instance.data)

                #descriptive statistics/string
                #instance.top = function()
                #    Base.top(instance.data)
                #end

                instance.unique = function()
                    return Base.unique(instance.data)
                end
            end

            #descriptive statistics/common
            instance.describe = function()
                describe_dict = Dict()
                if instance._data_type == "Numeric"
                    describe_dict["count"] = instance.count()
                    describe_dict["min"] = instance.min()
                    describe_dict["max"] = instance.max()
                    describe_dict["sum"] = instance.sum()
                    describe_dict["std"] = instance.std()
                    describe_dict["avg"] = instance.avg()
                else
                    describe_dict["unique"] = instance.unique()
                end

                println(join(["$key : $value" for (key, value) in describe_dict], "\n"))
                return describe_dict
            end

            instance.count = function()
                return length(instance.data)
            end

            return instance
        end
    end
    function Base.show(io::Base.IO, instance::ColumnSet)
        print_string = string("ColumnSet", instance._col_num, "@", instance._parent_name, "\n")
        print_string = string(
            print_string,
            string("count : ", length(instance.data), "\n")
        )
        print(io, print_string)
    end

    mutable struct RowSet
        ###parameters
        #arguments
        data::Dict
        #hidden parameters
        _parent_name::String
        _row_num::Int

        ###functions
        null::Function
        keys::Function

        #init
        function RowSet(data = Dict(), row_num = 0, parent_name = "moeum.MOEUM")
            instance = new(data) ; instance._parent_name, instance._row_num = parent_name, row_num
            instance.null = function()
                result = []
                for (key, value) in instance.data
                    if value == nothing
                        Base.append!(result, key)
                    end
                end

                return result
            end

            instance.keys = function()
                result = Base.keys(instance.data)
                return result
            end

            return instance
        end
    end
    function Base.show(io::Base.IO, instance::RowSet)
        print_string = string("RowSet ", instance._row_num, "@", instance._parent_name, "\n")
        print_string = string(
            print_string,
            string("keys : ", instance.keys(), "\n")
        )
        
        print(io, print_string)
    end
end