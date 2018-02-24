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