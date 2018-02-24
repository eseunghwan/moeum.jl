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