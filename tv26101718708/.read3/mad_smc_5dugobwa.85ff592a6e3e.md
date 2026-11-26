Calculation: Bullish swing break = close > latest unbroken confirmed PivotHigh(high, swing pivot length, swing pivot length)
Calculation: Bearish swing break = close < latest unbroken confirmed PivotLow(low, swing pivot length, swing pivot length)
Calculation: Bullish internal break = close > latest unbroken confirmed PivotHigh(high, internal pivot length, internal pivot length)
Calculation: Bearish internal break = close < latest unbroken confirmed PivotLow(low, internal pivot length, internal pivot length)
Calculation: Sell-side sweep = low < latest unbroken confirmed swing PivotLow and close > that PivotLow
Calculation: Buy-side sweep = high > latest unbroken confirmed swing PivotHigh and close < that PivotHigh
Long: bullish swing break
Short: bearish swing break
Long: bullish internal break
Short: bearish internal break
Long: sell-side sweep
Short: buy-side sweep
Long: bullish swing break AND prior swing trend is bearish AND a sell-side sweep occurred within the sweep-to-CHoCH window
Short: bearish swing break AND prior swing trend is bullish AND a buy-side sweep occurred within the sweep-to-CHoCH window
Long: bullish swing break AND the nearest bearish candle within the OB search lookback exists AND close minus that candle's low is at least the OB displacement ATR multiple times ATR(lookback)
Short: bearish swing break AND the nearest bullish candle within the OB search lookback exists AND that candle's high minus close is at least the OB displacement ATR multiple times ATR(lookback)
Short: close < bottom of an active bullish order block
Long: close > top of an active bearish order block
Long: low[1] > high[3]
Short: high[1] < low[3]
Long: max(open[1], close[1]) < min(open, close)
Short: min(open[1], close[1]) > max(open, close)
Long: newly confirmed swing PivotHigh(high, swing pivot length, swing pivot length) > preceding confirmed swing PivotHigh
Short: newly confirmed swing PivotHigh(high, swing pivot length, swing pivot length) <= preceding confirmed swing PivotHigh
Long: newly confirmed swing PivotLow(low, swing pivot length, swing pivot length) > preceding confirmed swing PivotLow
Short: newly confirmed swing PivotLow(low, swing pivot length, swing pivot length) <= preceding confirmed swing PivotLow
Long: newly confirmed swing PivotLow is lower than the preceding confirmed swing PivotLow AND reference symbol low at the same pivot bar is at least its preceding pivot low
Short: newly confirmed swing PivotHigh is higher than the preceding confirmed swing PivotHigh AND reference symbol high at the same pivot bar is at most its preceding pivot high
Long: absolute difference between successive confirmed swing pivot lows is at most the equal-level ATR tolerance times ATR(lookback)
Short: absolute difference between successive confirmed swing pivot highs is at most the equal-level ATR tolerance times ATR(lookback)