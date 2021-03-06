module structs
    using DataStructures

    include("io/internal.jl")
    include("io/output.jl")

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
        _sok_dict::DataStructures.OrderedDict
        _sok_arr::Array
        
        ###functions
        #internal functions
        select::Function
        describe::Function

        #modify
        insert::Function
        append::Function
        #equation::Function

        #query
        #where::Function

        #output
        to_string::Function
        to_dataframe::Function
        to_dict::Function
        to_csv::Function
        to_db::Function

        #init
        function MOEUM(;dat_sori = [], hol_sori = [], name = "moeum.MOEUM")
            #init instance
            instance = new(dat_sori, hol_sori, name)

            #=key_list = instance.dat_sori; sok_dict = Dict(dat => [] for dat in instance.dat_sori)
            for hol in instance.hol_sori
                for i in eachindex(instance.dat_sori)
                    append!(sok_dict[instance.dat_sori[i]], hol[i])
                end
            end=#
            instance._sok_dict, instance._sok_arr = internal.set_sok(instance.dat_sori, instance.hol_sori, instance.name)

            #instance._sok_dict = DataStructures.OrderedDict(key_list[i]=> ColumnSet(sok_dict[key_list[i]], i, key_list[i], instance.name) for i in eachindex(key_list))
            #instance._sok_arr = [RowSet(DataStructures.OrderedDict(instance.dat_sori[j] => instance.hol_sori[i][j] for j in eachindex(instance.dat_sori)), i, instance.name) for i in eachindex(instance.hol_sori)]

            #modify
            instance.insert = function(;dat_pos::Int = length(instance.dat_sori) + 1, dat_name::Any = "", hol_value::Array = [])
                return internal.insert(instance, dat_pos, dat_name, hol_value)
            end

            instance.append = function(;dat_name::Any = "", hol_value::Array = [])
                return internal.append(instance, dat_name, hol_value)
            end

            #internal functions
            instance.select = function(key)
                return internal.select(instance, key)
            end

            instance.describe = function()
                return internal.describe(instance)
            end

            #output functions
            instance.to_string = function()
                return output.to_string(instance)
            end

            instance.to_dataframe = function()
                return output.to_dataframe(instance)
            end

            instance.to_dict = function(;orientation::String = "Dict")
                return output.to_dict(instance, orientation)
            end

            instance.to_csv = function(;csv_path::String = joinpath(pwd(), string(instance.name, ".csv")))
                return output.to_csv(instance, csv_path)
            end

            return instance
        end
    end
    function Base.show(io::Base.IO, instance::MOEUM)
        println(io, instance.to_string())
    end

    mutable struct ColumnSet
        ###parameters
        #arguments
        data::Array
        #hidden parameters
        _data_type::String
        _parent_name::String
        _col_num::Int
        _col_name::String

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

        #eval equation
        equation::Function

        #init
        function ColumnSet(data = [], col_num = 0, col_name = "dat", parent_name = "moeum.MOEUM")
            instance = new(data) ; instance._parent_name, instance._col_num, instance._col_name = col_name = parent_name, col_num, col_name
            type_count = Dict("Numeric"=>0, "String"=>0)
            for i in eachindex(instance.data)
                item = string(instance.data[i])
                if !isnull(tryparse(Float64, item))
                    if contains(item, ".")
                        parse_type = Float64
                    else
                        parse_type = Int
                    end

                    instance.data[i] = parse(parse_type, item)
                    type_count["Numeric"] += 1
                else
                    type_count["String"] += 1
                end
            end

            #descriptive statistics/invalid
            instance._invalid = function()
                println(string("invalid for data-type is ", instance._data_type))
                return false
            end

            #set default invalid to functions
            instance.equation, instance.sum, instance.avg, instance.std, instance.min, instance.max, instance.unique, instance.describe = [instance._invalid for i in 1:8]
            if type_count["Numeric"] >= type_count["String"]
                instance._data_type = "Numeric"
                #instance.data = collect(float(item) for item in instance.data)

                #descriptive statistics/numeric
                parsed_data = [parse(Float64, string(item)) for item in instance.data]
                instance.sum = function()
                    return Base.sum(instance.data)
                end

                instance.avg = function()
                    return Base.mean(parsed_data)
                end

                instance.std = function()
                    return Base.std(parsed_data)
                end

                instance.max = function()
                    Base.maximum(instance.data)
                end

                instance.min = function()
                    Base.minimum(instance.data)
                end

                #eval equation
                instance.equation = function(equation_string)
                    for item in instance.data
                        eval(parse(equation_string))
                    end
                end
            else
                instance._data_type = "String"
                #instance.data = collect(string(item) for item in instance.data)

                #descriptive statistics/string
                #instance.top = function()
                #    Base.top(instance.data)
                #end

                instance.unique = function()
                    return Base.unique(instance.data)
                end
            end

            #descriptive statistics/common
            instance.describe = function(;return_value = true, header_name = true)
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

                describe_string = join(["$key : $value" for (key, value) in describe_dict], "\n")
                if header_name
                    describe_string = string(instance._col_name, "@", instance._parent_name, "\n", describe_string)
                else
                    describe_string = string("ColumnSet-", instance._col_num, "@", instance._parent_name, "\n", describe_string)
                end
                if return_value
                    println(describe_string)
                    return describe_dict
                else
                    return describe_string
                end
            end

            instance.count = function()
                return length(instance.data)
            end

            return instance
        end
    end
    function Base.show(io::Base.IO, instance::ColumnSet)
        println(io, string(instance.describe(return_value = false, header_name = false), "\n\n"))
    end

    mutable struct RowSet
        ###parameters
        #arguments
        data::DataStructures.OrderedDict
        #hidden parameters
        _parent_name::String
        _row_num::Int

        ###functions
        null::Function
        keys::Function

        #init
        function RowSet(data = DataStructures.OrderedDict(), row_num = 0, parent_name = "moeum.MOEUM")
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
        print_string = string("RowSet-", instance._row_num, "@", instance._parent_name, "\n")
        print_string = string(
            print_string,
            string("keys : ", instance.keys(), "\n")
        )
        
        println(io, print_string[1:end - 1])
    end
end