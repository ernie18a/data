Calculation: Chart-Bar Percent Change = 100 × (close − close[1]) / close[1] on chart bars
Calculation: Gold Driver Score = (1 if short-yield percent change < −sensitivity, −1 if > sensitivity, otherwise 0) + (1 if dollar percent change < −sensitivity, −1 if > sensitivity, otherwise 0)
Calculation: Yield-Curve Change = long-yield Chart-Bar Percent Change − short-yield Chart-Bar Percent Change
Long: current T1 close of the 10-year yield series − current T1 close of the 10-year breakeven series < real-yield threshold, using current T1 values mapped to chart bars (T1 bar still forming in real time)
Short: current T1 close of the 10-year yield series − current T1 close of the 10-year breakeven series ≥ real-yield threshold, using current T1 values mapped to chart bars (T1 bar still forming in real time)
Long: Gold Driver Score > 0
Short: Gold Driver Score < 0
Long: Yield-Curve Change > sensitivity AND short-yield Chart-Bar Percent Change < −sensitivity
Short: (Yield-Curve Change > sensitivity AND short-yield Chart-Bar Percent Change ≥ −sensitivity AND long-yield Chart-Bar Percent Change > sensitivity) OR (Yield-Curve Change < −sensitivity AND short-yield Chart-Bar Percent Change ≥ −sensitivity)