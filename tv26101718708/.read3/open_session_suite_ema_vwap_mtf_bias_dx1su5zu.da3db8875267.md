Long: close > EMA(close, shorter lookback) AND close > VWAP AND close > EMA(close, longer lookback)
Short: close < EMA(close, shorter lookback) AND close < VWAP AND close < EMA(close, longer lookback)
Long: close crosses above EMA(close, shorter lookback) AND close > VWAP AND close > EMA(close, longer lookback)
Short: close crosses below EMA(close, shorter lookback) AND close < VWAP AND close < EMA(close, longer lookback)
Long: chart-bar close > EMA(close, shorter lookback) calculated on T1 bars at the last completed T1 bar and sampled on chart bars
Short: chart-bar close <= EMA(close, shorter lookback) calculated on T1 bars at the last completed T1 bar and sampled on chart bars
Long: chart-bar close > EMA(close, shorter lookback) calculated on T2 bars at the last completed T2 bar and sampled on chart bars
Short: chart-bar close <= EMA(close, shorter lookback) calculated on T2 bars at the last completed T2 bar and sampled on chart bars