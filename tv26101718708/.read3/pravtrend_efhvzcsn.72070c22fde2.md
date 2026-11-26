Calculation: EMA alignment(T) = EMA(close, shorter lookback, T, bar still forming) > EMA(close, longer lookback, T, bar still forming), evaluated on T bars and sampled on chart bars
Calculation: Long continuation state = false initially; true when the first-entry long condition is true; false when EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Calculation: Short continuation state = false initially; true when the first-entry short condition is true; false when EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Long: EMA alignment(T1) = true
Short: EMA alignment(T1) = false
Long: EMA alignment(T2) = true
Short: EMA alignment(T2) = false
Long: EMA alignment(T3) = true
Short: EMA alignment(T3) = false
Long: EMA alignment(T4) = true
Short: EMA alignment(T4) = false
Long: close(T3, last completed bar) > open(T3, last completed bar), evaluated on T3 bars and sampled on chart bars
Short: close(T3, last completed bar) < open(T3, last completed bar), evaluated on T3 bars and sampled on chart bars
Long: (session filter disabled OR datetime is within the configured New York session) AND EMA alignment(T2) = true AND (EMA alignment(T1) = true OR EMA alignment(T3) = true) AND close > VWAP(hlc3) AND EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: (session filter disabled OR datetime is within the configured New York session) AND EMA alignment(T2) = false AND (EMA alignment(T1) = false OR EMA alignment(T3) = false) AND close < VWAP(hlc3) AND EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Long: (session filter disabled OR datetime is within the configured New York session) AND Long continuation state = true AND chart timeframe = T4 AND close > VWAP(hlc3) AND low <= EMA(close, longer lookback) AND close > EMA(close, longer lookback) AND close > open
Short: (session filter disabled OR datetime is within the configured New York session) AND Short continuation state = true AND chart timeframe = T4 AND close < VWAP(hlc3) AND high >= EMA(close, longer lookback) AND close < EMA(close, longer lookback) AND close < open