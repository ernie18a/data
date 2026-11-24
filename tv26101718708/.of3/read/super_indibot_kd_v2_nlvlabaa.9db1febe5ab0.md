Calculation: stop distance = ATR(ATR lookback) on the entry-signal bar × stop multiplier
Calculation: target distance(i) = stop distance × take-profit multiplier × i
Long: EMA(close, shorter lookback)[1] crosses above EMA(close, longer lookback)[1] on a confirmed chart bar
Short: EMA(close, shorter lookback)[1] crosses below EMA(close, longer lookback)[1] on a confirmed chart bar
Exit: long, low <= entry price - stop distance OR maximum high from the entry-signal bar through the current bar >= entry price + target distance(target count)
Exit: short, high >= entry price + stop distance OR minimum low from the entry-signal bar through the current bar <= entry price - target distance(target count)
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)
Long: For each selected dashboard timeframe T1, T2, and T3, EMA(close, shorter lookback, T, latest available bar) > EMA(close, longer lookback, T, latest available bar), evaluated on chart bars using lookahead_off values; T may still be forming in real time
Short: For each selected dashboard timeframe T1, T2, and T3, EMA(close, shorter lookback, T, latest available bar) <= EMA(close, longer lookback, T, latest available bar), evaluated on chart bars using lookahead_off values; T may still be forming in real time
Long: A majority of T1, T2, and T3 have EMA(close, shorter lookback, T, latest available bar) > EMA(close, longer lookback, T, latest available bar), evaluated on chart bars using lookahead_off values; T may still be forming in real time
Short: A majority of T1, T2, and T3 have EMA(close, shorter lookback, T, latest available bar) <= EMA(close, longer lookback, T, latest available bar), evaluated on chart bars using lookahead_off values; T may still be forming in real time
Long: For each displayed screened symbol, EMA(close, shorter lookback) > EMA(close, longer lookback), evaluated on chart bars from same-timeframe lookahead_off values; the bar may still be forming in real time
Short: For each displayed screened symbol, EMA(close, shorter lookback) <= EMA(close, longer lookback), evaluated on chart bars from same-timeframe lookahead_off values; the bar may still be forming in real time