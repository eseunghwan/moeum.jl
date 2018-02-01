module io
    export input

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
        using moeum

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

                    result = moeum.MOEUM(dat_sori = dat_sori, hol_sori = hol_sori, name = name)
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

                    result = moeum.MOEUM(dat_sori = dat_sori, hol_sori = hol_sori, name = name)
                else
                    result = convertable
                end
            end

            return result
        end
    end
end