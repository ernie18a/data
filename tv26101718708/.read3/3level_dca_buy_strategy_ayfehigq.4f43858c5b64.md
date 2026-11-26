Calculation: volume filter passes = volume filter disabled OR volume > SMA(volume, volume lookback) * volume threshold
Calculation: trend filter passes = MTF filter disabled OR close of the still-forming T1 bar > SMA(close, trend lookback) on the still-forming T1 bar, sampled on chart bars
Calculation: cycle high = persistent high set when high = highest(high, peak lookback), volume filter passes, and trend filter passes, if no prior cycle high exists or high > prior cycle high; each update arms all three buy levels
Calculation: drop from cycle high = (cycle high - close) / cycle high * 100
Long: first buy level is armed and unused in the current cycle AND drop from cycle high >= first drop threshold AND volume filter passes AND trend filter passes
Long: second buy level is armed and unused in the current cycle AND drop from cycle high >= second drop threshold AND volume filter passes AND trend filter passes
Long: third buy level is armed and unused in the current cycle AND drop from cycle high >= third drop threshold AND volume filter passes AND trend filter passes
Exit: Long, temporary sell cycle enabled AND chart bar index >= the recorded buy bar index for that level + exit delay
Long: temporary sell cycle enabled AND chart bar index >= the recorded buy bar index for that level + exit delay