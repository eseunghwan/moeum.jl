module Data
    function parse_data_list(source::Array)
        result = Dict(
            "type"=> nothing,
            "data"=> []
        )
        list_type = Dict(
            "Float64"=> 0,
            "Int"=> 0,
            "String"=> 0
        )

        for item in source
            item = string(item)
            if !isnull(tryparse(Float64, item))
                if contains(item, ".")
                    list_type["Float64"] += 1
                else
                    list_type["Int"] += 1
                end
            else
                list_type["String"] += 1
            end
        end
        if list_type["String"] > 0
            result["type"] = String
            result["data"] = [string(item) for item in source]
        else
            if list_type["Float64"] > 0
                result["type"] = Float64
            else
                result["type"] = Int
            end

            result["data"] = [parse(result["type"], string(item)) for item in source]
        end

        return result
    end
end