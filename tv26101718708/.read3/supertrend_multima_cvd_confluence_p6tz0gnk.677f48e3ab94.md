Calculation: volume delta = high == low ? 0 : volume * (2 * close - high - low) / (high - low)
Long: MA(close, shorter lookback) crosses above MA(close, longer lookback) AND CVD > CVD[1] AND close > SuperTrend
Short: MA(close, shorter lookback) crosses below MA(close, longer lookback) AND CVD < CVD[1] AND close < SuperTrend
Exit: long, close crosses below SuperTrend OR MA(close, shorter lookback) crosses below MA(close, longer lookback)
Exit: short, close crosses above SuperTrend OR MA(close, shorter lookback) crosses above MA(close, longer lookback)