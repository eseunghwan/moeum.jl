__precompile__()

module moeum
    export MOEUM, io

    #includes
    include("io.jl")
    include("structs.jl")

    #exporting to root
    MOEUM = structs.MOEUM
    from_dict = io.input.from_dict
end
