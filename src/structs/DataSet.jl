module DataSet
    using DataStructures

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

        #init
        function ColumnSet(data = [], col_num = 0, col_name = "dat", parent = nothing)
            instance = new(data) ; instance._parent_name, instance._col_num, instance._col_name = col_name = parent.name, col_num, col_name
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
            instance.sum, instance.avg, instance.std, instance.min, instance.max, instance.unique, instance.describe = [instance._invalid for i in 1:7]
            if type_count["Numeric"] >= type_count["String"]
                instance._data_type = "Numeric"

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

        #eval
        where::Function
        equation::Function

        #init
        function RowSet(data = DataStructures.OrderedDict(), row_num = 0, parent = nothing)
            instance = new(data) ; instance._parent_name, instance._row_num = parent.name, row_num
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

            #eval
            instance.where = function(where_string; drop_null::Bool = true)
                result = nothing
                key_list = instance.keys()
                eval(parse(string(join(key_list, ", "), " = $(values(instance.data))")))
                if eval(parse(where_string))
                    result = collect(values(instance.data))
                else
                    if !drop_null
                        result = [nothing for key in key_list]
                    end
                end

                return result
            end

            instance.equation = function(equation_string)
                result = nothing
                key_list = in(strip(split(equation_string, "=")[1]), instance.keys()) ? instance.keys() : append!(nstance.keys(), strip(split(equation_string, "=")[1]))
                eval(parse(string(join(instance.keys(), ", "), " = $(values(instance.data))")))
                
                #try
                eval(parse(equation_string))
                result = [eval(parse(key)) for key in key_list]
                #catch
                #    result = [nothing for key in key_list]
                #end

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