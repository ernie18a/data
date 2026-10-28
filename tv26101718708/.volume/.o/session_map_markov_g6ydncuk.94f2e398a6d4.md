Calculation: Opening-range high/low = highest high/lowest low of RTH bars from the RTH open through the configured opening-range duration; use only after that window ends, during RTH.
Calculation: Initial-balance high/low = highest high/lowest low of RTH bars from the RTH open through the configured initial-balance duration; use only after that window ends, during RTH.
Calculation: Anchored VWAP = cumulative volume-weighted average of HLC3 since the configured RTH open, Globex open, or daily open; include the current bar, and use an unweighted average when volume is unavailable.
Calculation: Anchored VWAP standard deviation = square root of the nonnegative difference between the cumulative volume-weighted average of HLC3 squared and Anchored VWAP squared, using the same anchor and bars as Anchored VWAP.
Long: During RTH, after the opening-range window ends, close > opening-range high and no opening-range-high break has occurred this RTH session.
Short: During RTH, after the opening-range window ends, close < opening-range low and no opening-range-low break has occurred this RTH session.
Long: During RTH, after the initial-balance window ends, close > initial-balance high and no initial-balance-high break has occurred this RTH session.
Short: During RTH, after the initial-balance window ends, close < initial-balance low and no initial-balance-low break has occurred this RTH session.
Long: Low <= Anchored VWAP - 2 × Anchored VWAP standard deviation and Anchored VWAP standard deviation > 0.
Short: High >= Anchored VWAP + 2 × Anchored VWAP standard deviation and Anchored VWAP standard deviation > 0.