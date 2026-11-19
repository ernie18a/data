Calculation: T1 deviation = (close / SMA(close, lookback1, T1, selected bar) - 1) * 100, sampled on chart bars using the last completed T1 bar when the confirmed-HTF parameter is on and the forming T1 bar when off
Calculation: T2 deviation = (close / SMA(close, lookback2, T2, selected bar) - 1) * 100, sampled on chart bars using the last completed T2 bar when the confirmed-HTF parameter is on and the forming T2 bar when off
Long: T1 deviation <= threshold1 AND T1 deviation[1] > threshold1
Long: T2 deviation <= threshold2 AND T2 deviation[1] > threshold2