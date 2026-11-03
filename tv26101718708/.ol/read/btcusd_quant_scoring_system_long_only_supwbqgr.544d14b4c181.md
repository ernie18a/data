Calculation: normalized(x, lookback) = 0 if standard deviation(x, lookback) is 0; otherwise clamp((x - SMA(x, lookback)) / standard deviation(x, lookback), -3, 3) / 3
Calculation: trend score = clamp((shorter-lookback EMA(close) - longer-lookback EMA(close)) / ATR, -3, 3) / 3
Calculation: mean-reversion score = clamp(-(close - VWMA(close, shorter lookback)) / ATR, -3, 3) / 3
Calculation: regression slope = linear regression of close at shorter-lookback offset 0 minus that at offset 1
Calculation: score = 7 * (0.20 * trend score + 0.20 * normalized(ROC(close, momentum lookback), normalization lookback) + 0.10 * mean-reversion score + 0.10 * normalized(volume, normalization lookback) * sign(ROC(close, momentum lookback)) + 0.10 * normalized(regression slope, normalization lookback))
Calculation: normal stop = max(entry price - ATR * stop multiple, entry price * (1 - hard-stop percentage / 100))
Calculation: target = entry price + ATR * target multiple
Calculation: runner stop = entry price * (1 - hard-stop percentage / 100)
Calculation: higher-timeframe bearish condition = last completed higher-timeframe close < its EMA AND that EMA < its value on the preceding higher-timeframe bar
Long: score > long threshold AND EMA with shorter lookback > EMA with longer lookback AND close > EMA with longer lookback
Exit: Long, before runner mode: score < exit threshold OR close < shorter-lookback EMA OR low <= normal stop OR high >= target; runner mode begins and persists once high >= entry price * (1 + runner trigger percentage / 100); in runner mode: low <= runner stop OR higher-timeframe bearish condition