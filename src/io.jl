module io
    export input, output

    module internal
        function select(instance, key)
            result = nothing
            if typeof(key)<:Real
                result = instance._sok_arr[key]
            elseif typeof(key)<:String
                result = instance._sok_dict[key]
            end

            return result
        end

        function to_string(instance)
            sok_dict, sok_arr = Dict(key=>value.data for (key, value) in instance._sok_dict), [item.data for item in instance._sok_arr]
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
                    arr_string = string(arr_string, lpad(arr[key], max_lengths[key], " "), " | ")
                end
                arr_string = string(arr_string, "\n")
            end
            print_string = string(print_string, arr_string, "\n")

            return print_string
        end
    end

    module output
        using DataFrames

        function to_dataframe(instance)
            return DataFrames.DataFrame(instance._sok_dict)
        end

        function to_dict(instance, orientation)
            result = nothing
            if orientation == "Dict"
                result = instance._sok_dict
            elseif orientation == "Array"
                result = instance._sok_arr
            end

            return result
        end

        function to_csv(instance, csv_path)
            result = nothing
            try
                open(csv_path) do f_csv
                    csv_string = string(join(keys(instance.sok_dict), ", "), "\n")
                    for sok in instance.sok_arr
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

    module input
        include("structs.jl")

        function from_dict(source ; name::String = "moeum.MOEUM")
            convertable, result = true, nothing
            if length(source) > 0 && isa(source, Array)
                for item in source
                    if !isa(item, Dict)
                        convertable = false
                        break
                    end
                end

                if convertable
                    dat_sori = [key for key in keys(source[1])]
                    hol_sori = [[row[dat] for dat in dat_sori] for row in source]

                    result = structs.MOEUM(dat_sori = dat_sori, hol_sori = hol_sori, name = name)
                else
                    result = convertable
                end
            elseif isa(source, Dict)
                for value in values(source)
                    if !isa(value, Array)
                        convertable = false
                        break
                    elseif length(value) == 0
                        convertable = false
                        break
                    end
                end

                if convertable
                    dat_sori = [key for key in keys(source)]
                    hol_sori = [[source[dat][i] for dat in dat_sori] for i in eachindex(source[dat_sori[1]])]

                    result = structs.MOEUM(dat_sori = dat_sori, hol_sori = hol_sori, name = name)
                else
                    result = convertable
                end
            end

            return result
        end
    end
end