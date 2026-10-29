Calculation: Latest confirmed pivot high = the most recent bar high that is higher than the highs of the specified number of bars on both sides; it is available once the bars on its right have completed.
Calculation: Latest confirmed pivot low = the most recent bar low that is lower than the lows of the specified number of bars on both sides; it is available once the bars on its right have completed.
Long: low is within the specified percentage of the latest confirmed pivot low AND latest confirmed pivot high − low > ATR × exhaustion multiplier AND volume > volume SMA × volume multiplier AND (close > open OR close > previous bar high)
Short: high is within the specified percentage of the latest confirmed pivot high AND close − latest confirmed pivot low > ATR × exhaustion multiplier AND volume > volume SMA × volume multiplier AND (close < open OR close < previous bar low)
Calculation: Long stop = the lower of the latest confirmed pivot low and the signal bar low; long target = entry price + (entry price − long stop) × risk-to-reward ratio.
Calculation: Short stop = the higher of the latest confirmed pivot high and the signal bar high; short target = entry price − (short stop − entry price) × risk-to-reward ratio.
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target