Calculation: Liquidity reference = lowest low over the lookback bars before the current bar
Calculation: Liquidity sweep = current low < liquidity reference AND current close > liquidity reference
Calculation: RSI z-score = (RSI − its longer-lookback mean) / its longer-lookback standard deviation; use 0 when the standard deviation is 0
Calculation: ATR stop = entry price − ATR-based distance
Calculation: First profit target = entry price + ATR-based distance
Calculation: Second profit target = entry price + a longer ATR-based distance than the first target
Long: close > slow EMA AND fast EMA > slow EMA AND daily close > daily slow EMA AND daily fast EMA > daily slow EMA AND daily RSI > threshold AND ADX > threshold AND volume > its moving average × threshold AND a liquidity sweep occurred within the reclaim window AND close > liquidity reference AND prior-bar RSI z-score < negative threshold AND current RSI z-score crossed above a higher threshold AND close > prior close AND close < fast EMA + ATR-based extension limit
Exit: long, low <= ATR stop OR high >= first profit target OR high >= second profit target OR close < slow EMA