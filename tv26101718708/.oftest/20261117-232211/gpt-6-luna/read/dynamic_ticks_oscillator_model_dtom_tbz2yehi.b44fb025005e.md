Calculation: R = ROC(T1 close, rocLength), evaluated on chart bars using values from the still-forming T1 bar
Calculation: V = StdDev(R, volatilityLookback), evaluated on chart bars
Long: R < -V * entryStdDevMultiplier
Exit: long, R > V * exitStdDevMultiplier