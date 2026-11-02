Calculation: Upper channel = highest high over the channel lookback ending at the previous bar.
Calculation: Lower channel = lowest low over the channel lookback ending at the previous bar.
Calculation: Uptrend = close > long-period EMA AND EMA > its value at the slope lookback AND (higher-timeframe filter disabled OR close > the same-period EMA of the last completed higher-timeframe bar).
Calculation: Downtrend = close < long-period EMA AND EMA < its value at the slope lookback AND (higher-timeframe filter disabled OR close < the same-period EMA of the last completed higher-timeframe bar).
Calculation: Long stop = entry price minus an initial-stop multiple of entry-bar ATR on the entry bar; on each subsequent bar, test the previous stop first, then, if not hit, update it to the maximum of the previous stop and the highest high since entry minus a trailing multiple of current ATR.
Calculation: Short stop = entry price plus an initial-stop multiple of entry-bar ATR on the entry bar; on each subsequent bar, test the previous stop first, then, if not hit, update it to the minimum of the previous stop and the lowest low since entry plus a trailing multiple of current ATR.
Long: Close > upper channel AND previous close <= previous upper channel AND (trend filter disabled OR (with-trend-only enabled AND uptrend) OR (with-trend-only disabled AND downtrend is false)).
Short: Close < lower channel AND previous close >= previous lower channel AND (trend filter disabled OR (with-trend-only enabled AND downtrend) OR (with-trend-only disabled AND uptrend is false)).
Exit: long, low <= previous long stop OR bars since entry >= trade-window lookback.
Exit: short, high >= previous short stop OR bars since entry >= trade-window lookback.