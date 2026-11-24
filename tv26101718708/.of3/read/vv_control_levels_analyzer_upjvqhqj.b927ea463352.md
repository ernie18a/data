Calculation: Period POC(T) = the center of the equal-width HLC3 price bin spanning the minimum-to-maximum HLC3 values that has the greatest sum of max(volume, 0) over the last completed T period, accumulated on chart bars; use the lowest-price bin on ties and the HLC3 value when all values are equal. The bin count is a parameter; T1, T2, and T3 are distinct periods ordered shortest to longest.
Calculation: Selected POC = Period POC(T) for the configured selection from T1, T2, and T3; automatic selection uses T1 on chart periods below T1, T2 on T1 charts, and T3 on T2-or-longer charts.
Calculation: VWAP(T) = sum(HLC3 * max(volume, 0)) / sum(max(volume, 0)) for the last completed T period, accumulated on chart bars; T is configured independently of the selected POC period, and automatic selection uses the same period mapping as the selected POC.
Calculation: VWAP deviation(T) = sqrt(max(sum(HLC3^2 * v) / sum(v) - VWAP(T)^2, 0)) for the last completed T period, accumulated on chart bars, where v = max(volume, 0).
Calculation: Upper and lower VWAP gates = VWAP(T) plus or minus the same configured multiplier times VWAP deviation(T).
Calculation: Number of controls above close = count of available levels among Period POC(T1), Period POC(T2), Period POC(T3), and VWAP(T) that are below close.
Calculation: Near a control = at least one available, nonzero level among Period POC(T1), Period POC(T2), Period POC(T3), VWAP(T), and the upper and lower VWAP gates has abs(close - level) / level * 100 less than or equal to the neutral-distance parameter.
Calculation: Strong volume = SMA(volume, volume lookback) is available and greater than zero, and volume / SMA(volume, volume lookback) is greater than or equal to the strong-volume threshold.
Long: close > Selected POC
Long: close crosses above Selected POC
Long: close > Period POC(T2) AND close > Period POC(T3)
Long: Number of controls above close >= 3 AND NOT Near a control
Long: close crosses above VWAP(T) AND (volume confirmation is disabled OR Strong volume)
Long: low <= lower VWAP gate AND close > lower VWAP gate AND close > open
Long: close crosses above upper VWAP gate
Long: close > VWAP(T) AND close > Selected POC AND Number of controls above close >= 3 AND NOT (close crosses above VWAP(T) AND (volume confirmation is disabled OR Strong volume))
Long: close > VWAP(T) AND NOT (close crosses above VWAP(T) AND (volume confirmation is disabled OR Strong volume)) AND NOT (close < Selected POC) AND NOT (close > Selected POC AND Number of controls above close >= 3)
Short: close < Selected POC
Short: close crosses below Selected POC
Short: close < Period POC(T2) AND close < Period POC(T3)
Short: Number of controls above close <= 1 AND NOT Near a control
Short: close crosses below VWAP(T)
Short: high >= upper VWAP gate AND close < upper VWAP gate AND close < open
Short: close crosses below lower VWAP gate