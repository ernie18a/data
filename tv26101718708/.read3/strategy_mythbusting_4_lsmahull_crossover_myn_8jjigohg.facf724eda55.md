Calculation: LSMA = linear regression of the LSMA source using its lookback and offset on chart bars
Calculation: Hull line = selected HMA or EHMA of the Hull source using Hull length × multiplier, or selected THMA using half that length; calculate on chart bars, or on T1 bars and use the last completed T1 value on chart bars when higher-timeframe mode is enabled
Calculation: ADX = ADX(high, low, close, DI lookback, smoothing lookback)
Long: Hull line crosses above its value two chart bars ago
Short: Hull line crosses below its value two chart bars ago
Long: long entries are enabled AND position side is not long AND LSMA crosses above Hull line AND Hull line ≤ its value two chart bars ago AND Hull source > Hull line AND (ADX filter is disabled OR ADX > ADX threshold)
Short: short entries are enabled AND position side is not short AND LSMA crosses below Hull line AND Hull line > its value two chart bars ago AND Hull source < Hull line AND (ADX filter is disabled OR ADX > ADX threshold)
Exit: Long, close < entry price × (1 − stop-loss percent / 100) OR high ≥ entry price × (1 + target 1 percent / 100) OR high ≥ entry price × (1 + target 2 percent / 100) OR high ≥ entry price × (1 + target 3 percent / 100) OR high ≥ entry price × (1 + target 4 percent / 100)
Exit: Short, close > entry price × (1 + stop-loss percent / 100) OR low ≤ entry price × (1 − target 1 percent / 100) OR low ≤ entry price × (1 − target 2 percent / 100) OR low ≤ entry price × (1 − target 3 percent / 100) OR low ≤ entry price × (1 − target 4 percent / 100)