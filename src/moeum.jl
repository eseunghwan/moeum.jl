__precompile__()

module moeum
    using Logging; Logging.configure(level = Logging.OFF)

    export MOEUM, io

    #includes
    include("io/input.jl")
    include("structs/Core.jl")

    #exporting to root
    MOEUM = Core.MOEUM
    from_dict = input.from_dict
    from_dataframe = input.from_dataframe
    from_csv = input.from_csv

end
