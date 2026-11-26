Long: (ATH breakout enabled AND close > highest(high, all prior chart bars)) OR (T1 high breakout enabled AND close > highest(high, high lookback, T1 bars through the then-forming bar, sampled on chart bars)[1 chart bar]
Exit: long, EMA exit enabled AND close < EMA(close, EMA lookback)
Exit: long, EMA exit disabled AND low <= entry price - ATR(ATR lookback) * multiplier