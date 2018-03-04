module output
    using DataFrames, DataStructures

    function to_string(instance)
        sok_dict, sok_arr = DataStructures.OrderedDict(key=> value.data for (key, value) in instance._sok_dict), [item.data for item in instance._sok_arr]
        max_lengths = Dict(key => ceil(Int, maximum(insert!([length(string(item)) for item in sok_dict[key]], 1, length(key))) * 1.5) for key in keys(sok_dict))
        max_lengths["index"] = maximum([length(string(length(sok_arr))), length("index")])

        print_string = string(
            "[ ", instance.name, " | ", length(sok_dict), " × ", length(sok_arr), " ]\n",
            "| ", lpad("", max_lengths["index"], " "), " | ",
            join([string(lpad(key, max_lengths[key], " "), " | ") for key in Base.keys(sok_dict)]),
            "\n"
        )

        print_arr, arr_string = length(sok_arr) > 20 ? sok_arr[1:20] : sok_arr, ""
        for i in eachindex(print_arr)
            arr = print_arr[i]
            arr_string = string(arr_string, "| ", lpad(i, max_lengths["index"], " "), " |")
            for key in keys(arr)
                arr_string = string(arr_string, lpad(arr[key], max_lengths[key] + 1, " "), " | ")
            end
            arr_string = string(arr_string, "\n")
        end
        print_string = string(print_string, arr_string)[1:end - 1]

        return print_string
    end

    function to_dataframe(instance)
        return DataFrames.DataFrame(Dict(key=> value.data for (key, value) in instance._sok_dict))
    end

    function to_dict(instance, orientation)
        sok_dict, sok_arr = DataStructures.OrderedDict(key=> value.data for (key, value) in instance._sok_dict), [item.data for item in instance._sok_arr]

        if orientation == "Dict"
            result = sok_dict
        elseif orientation == "Array"
            result = sok_arr
        end

        return result
    end

    function to_csv(instance, csv_path)
        sok_dict, sok_arr = DataStructures.OrderedDict(key=> value.data for (key, value) in instance._sok_dict), [item.data for item in instance._sok_arr]

        try
            open(csv_path, "w") do f_csv
                csv_string = string(join(keys(sok_dict), ", "), "\n")
                for sok in sok_arr
                    csv_string = string(csv_string, join(values(sok), ", "), "\n")
                end
                write(f_csv, csv_string[1:end - 1])
            end
            result = true
        catch error
            result = false
        end

        return result
    end
end