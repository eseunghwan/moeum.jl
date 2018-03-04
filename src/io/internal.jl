module internal
    using Logging, DataStructures

    include("../structs/DataSet.jl")
    include("../functions/Data.jl")

    #set sok and parse data type
    function set_sok(instance, dat_sori, hol_sori)
        key_list = dat_sori ; sok_dict = Dict(dat => [] for dat in dat_sori) ; sok_type = Dict()
        for hol in hol_sori
            for i in eachindex(key_list)
                append!(sok_dict[key_list[i]], hol[i])
            end
        end
        for key in key_list
            sok_type[key], sok_dict[key] = Data.parse_data_list(sok_dict[key])["type"], Data.parse_data_list(sok_dict[key])["data"]
        end

        new_hol = []
        for hol in hol_sori
            tmp_hol = []
            for i in eachindex(key_list)
                if sok_type[key_list[i]] == String
                    append!(tmp_hol, string(hol[i]))
                else
                    append!(tmp_hol, parse(sok_type[key_list[i]], string(hol[i])))
                end
            end

            append!(new_hol, [tmp_hol])
        end
        instance.hol_sori = new_hol

        return [
            DataStructures.OrderedDict(key_list[i]=> DataSet.ColumnSet(sok_dict[key_list[i]], i, key_list[i], instance) for i in eachindex(key_list)),
            [DataSet.RowSet(DataStructures.OrderedDict(key => sok_dict[key][i] for key in key_list), i, instance) for i in eachindex(hol_sori)]
        ]
    end

    #modify
    function insert(instance, dat_pos, dat_name, hol_value)
        if dat_pos < 1 || dat_pos > length(instance.dat_sori) + 1
            Logging.ERROR("insert position is invalid.")
            result = false
        else
            new_dat_sori = insert!(instance.dat_sori, dat_pos, dat_name)
            new_hol_sori = [insert!(instance.hol_sori[i], dat_pos, hol_value[i]) for i in eachindex(instance.hol_sori)]
            new_sok_dict, new_sok_arr = set_sok(instance, new_dat_sori, new_hol_sori)

            instance.dat_sori, instance.hol_sori, instance._sok_dict, instance._sok_arr = new_dat_sori, new_hol_sori, new_sok_dict, new_sok_arr

            result = true
        end

        return result
    end

    function append(instance, dat_name, hol_value)
        return insert(instance, length(instance.dat_sori) + 1, dat_name, hol_value)
    end

    #simple selection and query
    function select(instance, key)
        key = string(key)
        if !isnull(tryparse(Int, key))
            result = instance._sok_arr[parse(Int, key)]
        else
            result = instance._sok_dict[key]
        end

        return result
    end

    function where(instance, where_string, drop_null)
        new_dat_sori, new_hol_sori = instance.dat_sori, []
        for row_set in instance._sok_arr
            where_result = row_set.where(where_string, drop_null = drop_null)
            if where_result != nothing
                append!(new_hol_sori, [where_result])
            end
        end

        new_instance = Base.deepcopy(instance)
        new_sok_dict, new_sok_arr = set_sok(new_instance, new_dat_sori, new_hol_sori)
        new_instance.dat_sori, new_instance.hol_sori, new_instance._sok_dict, new_instance._sok_arr = new_dat_sori, new_hol_sori, new_sok_dict, new_sok_arr
        new_instance.name = string(new_instance.name, ": ", where_string)

        return new_instance
    end

    function equation(instance, equation_string, inplace)
        equation_to = strip(split(equation_string, "=")[1])
        new_dat_sori, new_hol_sori = in(equation_to, instance.dat_sori) ? instance.dat_sori : append!(instance.dat_sori, equation_to), []
        for row_set in instance._sok_arr
            equation_result = row_set.equation(equation_string)
            if equation_result != nothing
                append!(new_hol_sori, [equation_result])
            end
        end

        if inplace
            new_instance = Base.deepcopy(instance)
        else
            new_instance = instance
        end

        new_sok_dict, new_sok_arr = set_sok(new_instance, new_dat_sori, new_hol_sori)
        new_instance.dat_sori, new_instance.hol_sori, new_instance._sok_dict, new_instance._sok_arr = new_dat_sori, new_hol_sori, new_sok_dict, new_sok_arr
        new_instance.name = string(new_instance.name, ": ", equation_string)

        if inplace
            println(new_instance.to_string())
        else
            return new_instance
        end
    end

    #descriptive statistics
    function describe(instance)
        result = DataStructures.OrderedDict()
        for dat in instance.dat_sori
            result[dat] = instance.select(dat).describe()
        end

        return result
    end
end