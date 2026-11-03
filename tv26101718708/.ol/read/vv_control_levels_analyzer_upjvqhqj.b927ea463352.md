Calculation: Daily, weekly, and monthly POC = for each period, divide the price range of its last completed period into equal-width rows, add each chart bar’s volume to the row containing its HLC3, and take the midpoint of the row with the greatest volume.
Calculation: VWAP Gate = volume-weighted average of HLC3 over the selected daily, weekly, or monthly period, using the last completed period.
Calculation: VWAP deviation gates = VWAP Gate plus or minus one standard deviation of HLC3 weighted by volume over the selected period; the upper and lower gates use the same calculation.
Calculation: Near a control level = absolute percentage distance from close to a Daily, weekly, or monthly POC, VWAP Gate, or first upper or lower deviation gate is at most the neutral-distance threshold.
Long: close crosses above VWAP Gate AND strong-volume filter passes when required
Long: low <= first lower VWAP deviation gate AND close > first lower VWAP deviation gate AND close > open
Long: close > first upper VWAP deviation gate AND previous close <= previous first upper VWAP deviation gate
Long: close crosses above active POC
Long: close is above VWAP Gate AND (close crosses above VWAP Gate with strong-volume filter passing when required OR close crosses above active POC OR close > first upper VWAP deviation gate AND previous close <= previous first upper VWAP deviation gate)
Long: close is above exactly 3 or all 4 of Daily POC, weekly POC, monthly POC, and VWAP Gate AND not near any control level
Long: close is below VWAP Gate AND low <= first lower VWAP deviation gate AND close > first lower VWAP deviation gate AND close > open
Short: close crosses below VWAP Gate
Short: high >= first upper VWAP deviation gate AND close < first upper VWAP deviation gate AND close < open
Short: close < first lower VWAP deviation gate AND previous close >= previous first lower VWAP deviation gate
Short: close crosses below active POC
Short: close is below VWAP Gate AND (close < first lower VWAP deviation gate AND previous close >= previous first lower VWAP deviation gate OR close crosses below VWAP Gate OR close crosses below active POC)
Short: close is below exactly 1 or all 0 of Daily POC, weekly POC, monthly POC, and VWAP Gate AND not near any control level
Exit: long, none
Exit: short, none