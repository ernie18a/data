Calculation: profile block = consecutive chart bars of the profile-window length, scaled by the rounded T1-to-chart-bar duration ratio when MTF is enabled; divide the block’s high-low range into the parameter number of equal-width price rows.
Calculation: DMI inputs = DMI with the same lookback for DI and ADX, using T1’s current forming bar sampled on chart bars when MTF is enabled, otherwise chart bars.
Calculation: effective volume = source volume when volume weighting is enabled and source volume is positive, otherwise 1; source volume is T1’s current forming volume sampled on chart bars when MTF is enabled, otherwise chart-bar volume.
Calculation: DI imbalance = IF(+DI + -DI = 0, 0, ABS(+DI - -DI) / (+DI + -DI)).
+DI profile row = sum over chart bars touching the row of [+DI × effective volume × (1 + DI imbalance) / number of profile rows touched by the bar].
Calculation: -DI profile row = sum over chart bars touching the row of [-DI × effective volume × (1 + DI imbalance) / number of profile rows touched by the bar].
Calculation: ADX profile row = sum over chart bars touching the row of [ADX × effective volume × (1 + DI imbalance) / number of profile rows touched by the bar].
Calculation: average ADX profile row = ADX profile row / number of chart bars touching the row.
Long: for any profile row, average ADX profile row >= ADX threshold AND +DI profile row > -DI profile row × DI dominance multiplier.
Short: for any profile row, average ADX profile row >= ADX threshold AND -DI profile row > +DI profile row × DI dominance multiplier.
Calculation: upper VWAP Fibonacci target(k) = VWAP(hlc3, effective volume, profile block) + (profile block high - VWAP(hlc3, effective volume, profile block)) × k.
Exit: long, high >= upper VWAP Fibonacci target(upper Fibonacci target ratio 1) OR high >= upper VWAP Fibonacci target(upper Fibonacci target ratio 2)