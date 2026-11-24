Calculation: Fast = kernel estimate(selected price source, Fast kernel family, Fast bandwidth, Fast shape parameter, Fast period, Fast phase, Fast filter)
Calculation: Medium = kernel estimate(selected price source, Medium kernel family, Medium bandwidth, Medium shape parameter, Medium period, Medium phase, Medium filter)
Calculation: Slow = kernel estimate(selected price source, Slow kernel family, Slow bandwidth, Slow shape parameter, Slow period, Slow phase, Slow filter)
Long: Fast > Fast[1]
Short: Fast < Fast[1]
Long: Medium > Medium[1]
Short: Medium < Medium[1]
Short: Medium <= Medium[1]
Long: Slow > Slow[1]
Short: Slow < Slow[1]
Long: Fast > Fast[1] AND Fast[1] <= Fast[2]
Short: Fast < Fast[1] AND Fast[1] >= Fast[2]
Long: Medium > Medium[1] AND Medium[1] <= Medium[2]
Short: Medium <= Medium[1] AND Medium[1] > Medium[2]
Short: Medium < Medium[1] AND Medium[1] >= Medium[2]
Long: Slow > Slow[1] AND Slow[1] <= Slow[2]
Short: Slow < Slow[1] AND Slow[1] >= Slow[2]
Long: Fast crosses above Slow
Short: Fast crosses below Slow
Long: Fast > Medium AND Medium > Slow AND Medium > Medium[1] AND NOT (Fast[1] > Medium[1] AND Medium[1] > Slow[1] AND Medium[1] > Medium[2])
Short: Fast < Medium AND Medium < Slow AND Medium < Medium[1] AND NOT (Fast[1] < Medium[1] AND Medium[1] < Slow[1] AND Medium[1] < Medium[2])
Long: Fast > Fast[1] AND Medium > Medium[1] AND Slow > Slow[1]
Short: Fast < Fast[1] AND Medium < Medium[1] AND Slow < Slow[1]