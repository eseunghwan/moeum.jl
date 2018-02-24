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

    function from_dataframe(source; name = "moeum.MOEUM")
        dat_sori, hol_sori = [String(item) for item in source.colindex.names], []

        datas = source.columns
        for i in eachindex(datas[1])
            item = []
            for col in datas
                append!(item, col[i])
            end

            append!(hol_sori, [item])
        end

        return structs.MOEUM(dat_sori = dat_sori, hol_sori = hol_sori, name = name)
    end
end