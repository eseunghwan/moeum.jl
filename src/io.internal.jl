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
end