Calculation: PivotHigh(src, n) = src[n] if src[n] is greater than src[i] for every i from 1 to 2 * n except i = n, otherwise NA
Calculation: PivotLow(src, n) = src[n] if src[n] is less than src[i] for every i from 1 to 2 * n except i = n, otherwise NA
Calculation: ResistanceLevel = first-in-first-out list of at most N values of PivotHigh(high, P)[1] on chart bars; a value is removed when close crosses above it on a bar where volume > SMA(volume, V), or when (bars since it was added + R) > D; the oldest value is removed when the list exceeds N
Calculation: SupportLevel = first-in-first-out list of at most N values of PivotLow(low, P)[1] on chart bars; a value is removed when close crosses below it on a bar where volume > SMA(volume, V), or when (bars since it was added + R) > D; the oldest value is removed when the list exceeds N
Calculation: T1ResistanceLevel = first-in-first-out list of at most N_T1 values of PivotHigh(high, P_T1)[1] computed on T1 bars and taken on chart bars from the last completed T1 bar, adding a non-NA value only when it differs from the previous value; a value is removed when close crosses above it; the oldest value is removed when the list exceeds N_T1
Calculation: T1SupportLevel = first-in-first-out list of at most N_T1 values of PivotLow(low, P_T1)[1] computed on T1 bars and taken on chart bars from the last completed T1 bar, adding a non-NA value only when it differs from the previous value; a value is removed when close crosses below it; the oldest value is removed when the list exceeds N_T1
Long: close crosses above any ResistanceLevel AND volume > SMA(volume, V)
Short: close crosses below any SupportLevel AND volume > SMA(volume, V)
Long: close crosses above any T1ResistanceLevel
Short: close crosses below any T1SupportLevel
Long: PivotHigh(high, P)[1] > previous non-NA PivotHigh(high, P)[1]
Short: PivotHigh(high, P)[1] <= previous non-NA PivotHigh(high, P)[1]
Long: PivotLow(low, P)[1] >= previous non-NA PivotLow(low, P)[1]
Short: PivotLow(low, P)[1] < previous non-NA PivotLow(low, P)[1]
Long: PivotHigh(high, P_T1)[1] of the last completed T1 bar is a new value AND > the previous value
Short: PivotHigh(high, P_T1)[1] of the last completed T1 bar is a new value AND <= the previous value
Long: PivotLow(low, P_T1)[1] of the last completed T1 bar is a new value AND >= the previous value
Short: PivotLow(low, P_T1)[1] of the last completed T1 bar is a new value AND < the previous value
Long: low > high[2] AND close[1] > open[1] AND low - high[2] >= G
Short: high < low[2] AND close[1] < open[1] AND low[2] - high >= G
Exit: long, low > high[2] AND close[1] > open[1] AND low - high[2] >= G AND NOT (close[1] crosses above last PivotHigh(high, S_L)) AND volume[1] > SMA(volume, V_G) * M AND (bars since last PivotLow(low, S_L) was confirmed + S_R) > K
Exit: short, high < low[2] AND close[1] < open[1] AND low[2] - high >= G AND NOT (close[1] crosses below last PivotLow(low, S_L)) AND volume[1] > SMA(volume, V_G) * M AND (bars since last PivotHigh(high, S_L) was confirmed + S_R) > K