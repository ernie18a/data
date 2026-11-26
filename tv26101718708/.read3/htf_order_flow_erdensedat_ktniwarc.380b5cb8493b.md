Calculation: LastPivotHigh = most recent non-na PivotHigh(high, pivot span, pivot span)
Calculation: LastPivotLow = most recent non-na PivotLow(low, pivot span, pivot span)
Calculation: VWAPT1 = VWAP(hlc3, volume) over chart bars within the current, still-forming T1 bar, through the current bar
Calculation: CVDT1 = cumulative sum of (volume if close >= open, else -volume) over chart bars within the current, still-forming T1 bar, through the current bar
Long: close > LastPivotHigh AND highest close from LastPivotHigh's confirmation bar through the previous bar <= LastPivotHigh
Long: PivotHigh(high, pivot span, pivot span) != na
Long: close > VWAPT1
Long: close > VWAPT1 AND CVDT1 > 0
Long: CVDT1 >= 0
Long: close of forming T1 bar >= open of forming T1 bar
Short: close < LastPivotLow AND lowest close from LastPivotLow's confirmation bar through the previous bar >= LastPivotLow
Short: PivotLow(low, pivot span, pivot span) != na
Short: close <= VWAPT1
Short: close < VWAPT1 AND CVDT1 < 0
Short: CVDT1 < 0
Short: close of forming T1 bar < open of forming T1 bar