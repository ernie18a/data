Long: close crosses above EMA(close, shorter lookback) AND (trend filter disabled OR EMA(close, shorter lookback) > EMA(close, longer lookback))
Short: close crosses below EMA(close, shorter lookback) AND (trend filter disabled OR EMA(close, shorter lookback) < EMA(close, longer lookback))
Exit: long, close < EMA(close, longer lookback)
Exit: short, close > EMA(close, longer lookback)
Exit: long, ATR stop enabled AND low <= entry price - ATR(lookback) * multiplier
Exit: short, ATR stop enabled AND high >= entry price + ATR(lookback) * multiplier
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback)
Long: close > EMA(close, shorter lookback) AND EMA(close, shorter lookback) > EMA(close, shorter lookback)[1]
Short: close < EMA(close, shorter lookback) AND EMA(close, shorter lookback) < EMA(close, shorter lookback)[1]
Long: low > high[2]
Short: high < low[2]
Long: PivotLow(low, lookback, lookback) is not NA
Short: PivotHigh(high, lookback, lookback) is not NA