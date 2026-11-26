Calculation: R = REI(lookback, T1, configured signal shift; completed bar if shift > 0, forming bar if shift = 0; checked on each new T1 bar if shift > 0 and on each chart tick if shift = 0)
Long: long-entry enabled AND R > lower level AND R[1] <= lower level
Short: short-entry enabled AND R < upper level AND R[1] >= upper level
Exit: long, R <= lower level OR (long-exit enabled AND R < upper level)
Exit: short, (short-exit enabled AND R > lower level) OR R >= upper level