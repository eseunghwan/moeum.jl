module Core
    using DataStructures

    include("../io/internal.jl")
    include("../io/output.jl")

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
        #modify
        insert::Function
        append::Function

        #simple selection and query
        select::Function
        where::Function
        equation::Function

        #descriptive statistics
        describe::Function

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

            instance._sok_dict, instance._sok_arr = internal.set_sok(instance, instance.dat_sori, instance.hol_sori)

            #modify
            instance.insert = function(;dat_name::Any = "", hol_value::Array = [], dat_pos::Int = length(instance.dat_sori) + 1)
                return internal.insert(instance, dat_pos, dat_name, hol_value)
            end

            instance.append = function(;dat_name::Any = "", hol_value::Array = [])
                return internal.append(instance, dat_name, hol_value)
            end

            #simple selection and query
            instance.select = function(key)
                return internal.select(instance, key)
            end

            instance.where = function(where_string; drop_null::Bool = true)
                return internal.where(instance, where_string, drop_null)
            end

            instance.equation = function(equation_string; inplace::Bool = true)
                return internal.equation(instance, equation_string, inplace)
            end

            #descriptive statistics
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
end