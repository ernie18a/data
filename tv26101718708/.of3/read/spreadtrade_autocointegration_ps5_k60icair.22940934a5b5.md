Calculation: ratio = on chart bars, log(selected source / selected source from the last completed T1 bar)
Calculation: z-score = (short average - long average) / stdev(long average, round(mean of the separate short and long lookbacks)); both averages use the same selected type (EMA, HMA, SMA, WMA, or VWAP); for EMA, HMA, SMA, or WMA, apply the short and long lookbacks to ratio; for VWAP, use VWAP(ratio) as the short average and VWAP(ratio[1]) as the long average; calculate on chart bars
Long: z-score crosses below negative entry threshold
Short: z-score crosses above entry threshold
Exit: long, z-score >= negative entry threshold AND z-score <= entry threshold
Exit: short, z-score >= negative entry threshold AND z-score <= entry threshold