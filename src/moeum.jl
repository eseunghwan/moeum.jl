__precompile__()

module moeum
    export MOEUM, io

    #includes
    include("io.input.jl")
    include("structs.jl")

    #exporting to root
    MOEUM = structs.MOEUM
    from_dict = input.from_dict
    from_dataframe = input.from_dataframe
    from_csv = input.from_csv

end
