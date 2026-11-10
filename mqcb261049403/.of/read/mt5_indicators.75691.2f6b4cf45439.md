Calculation: Trend direction = +1 when the shorter-period close moving average is above the longer-period close moving average, -1 when it is below, and 0 when equal. Use the same moving-average method and periods on three configurable timeframes ordered from shorter to longer. Each timeframe may be higher or lower than, or equal to, the chart timeframe; use its bar still forming.
Calculation: Macro score = sum of the three timeframe trend directions.
Long: Trend direction on any one of the three timeframes = +1.
Short: Trend direction on any one of the three timeframes = -1.
Long: Macro score > 0.
Short: Macro score < 0.
Long: Macro score >= 2.
Short: Macro score <= -2.
Long: Macro score = 3.
Short: Macro score = -3.
Exit: long, previous macro score > 0 AND current macro score < 0.
Exit: short, previous macro score < 0 AND current macro score > 0.