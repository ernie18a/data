Calculation: EXCESS = MAX(ZLEMA(HLC3, base length) - SMMA(high, base length), 0) + MIN(ZLEMA(HLC3, base length) - SMMA(low, base length), 0)
Calculation: DEVIATION = EXCESS - SMA(EXCESS, smoothing length)
Long: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) > EMA(close, shorter lookback)[1]
Long: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) > EMA(close, shorter lookback)[1] AND EMA(close, shorter lookback)[1] <= EMA(close, shorter lookback)[2]
Short: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) < EMA(close, shorter lookback)[1]
Short: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) < EMA(close, shorter lookback)[1] AND EMA(close, shorter lookback)[1] >= EMA(close, shorter lookback)[2]
Long: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) > EMA(close, longer lookback)
Long: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) > EMA(close, longer lookback) AND EMA(close, shorter lookback)[1] <= EMA(close, longer lookback)[1]
Short: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) < EMA(close, longer lookback)
Short: (NOT flat switch OR (DEVIATION != 0 AND DEVIATION[1] != 0)) AND EMA(close, shorter lookback) < EMA(close, longer lookback) AND EMA(close, shorter lookback)[1] >= EMA(close, longer lookback)[1]