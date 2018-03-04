using moeum
using Base.Test

#default test
@test mo_a = moeum.MOEUM(dat_sori = ["dat1", "dat2"], hol_sori = [[1, 2], [3, 4]], name = "mo_a")
@test dat1 = mo_a.select("dat1")
@test dat1.describe()

@test mo_a = moeum.from_csv("mo_a.csv")
@test dat1 = mo_a.select("dat1")
@test dat1.describe()

@test mo_a.where("dat1 >= 2")