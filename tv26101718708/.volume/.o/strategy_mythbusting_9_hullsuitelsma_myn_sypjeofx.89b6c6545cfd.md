Calculation: Hull moving average = WMA(2 × WMA(close, half the lookback) − WMA(close, full lookback), rounded square root of the lookback)
Calculation: Least-squares moving average = linear regression of close over its lookback, with zero offset; its lookback is shorter than the Hull moving average’s
Long: Hull moving average < its value two bars ago AND the least-squares moving average crosses above the Hull moving average AND ADX > its threshold, when the ADX filter is enabled
Short: Hull moving average > its value two bars ago AND the least-squares moving average crosses below the Hull moving average AND ADX > its threshold, when the ADX filter is enabled
Exit: long, close < entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + take-profit fraction)
Exit: short, close > entry price × (1 + stop-loss fraction) OR low ≤ entry price × (1 − take-profit fraction)