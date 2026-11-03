Calculation: Signal score = +1 for each of: MACD line > signal line; RSI > 50 and RSI ≤ 70; ADX > threshold and +DI > −DI; close > short EMA; close > long EMA; SuperTrend bullish; volume > its moving average × volume factor. Otherwise each criterion contributes −1.
Calculation: Dip upper band = long EMA − ATR × (dip-zone multiplier − offset).
Calculation: Peak lower band = short EMA + ATR × (peak-zone multiplier − offset).
Calculation: Target levels H1, H2, H3 = dip base + ATR × respective target multiplier; dip base is the lowest low over a short lookback. On a fresh full-buy signal, if targets are absent or H1 was already hit, set targets to close + ATR × respective target multiplier.
Calculation: Long stop = SuperTrend value on a fresh full-buy signal; while SuperTrend is bullish, raise the stop to the maximum of its previous value and current SuperTrend value.
Long: SuperTrend bullish AND close < dip upper band AND MACD line > signal line AND RSI > 50 AND RSI ≤ 70 AND signal score ≥ 1
Long: SuperTrend bullish AND close < dip upper band AND MACD line > signal line AND RSI > 50 AND volume > its moving average × volume factor AND signal score ≥ 3
Short: SuperTrend bearish AND close > peak lower band AND MACD line ≤ signal line AND RSI ≤ 70 AND signal score ≤ −1
Short: SuperTrend bearish AND close > peak lower band AND MACD line ≤ signal line AND RSI ≤ 50 AND volume > its moving average × volume factor AND signal score ≤ −3
Long: SuperTrend bullish AND MACD line > signal line AND RSI > 50 AND RSI ≤ 70 AND ADX > threshold AND +DI > −DI AND close > short EMA AND close > long EMA AND signal score ≥ 6 AND this condition was false on the previous bar
Short: SuperTrend bearish AND MACD line ≤ signal line AND RSI ≤ 50 AND ADX > threshold AND +DI ≤ −DI AND close ≤ short EMA AND close ≤ long EMA AND signal score ≤ −4 AND this condition was false on the previous bar
Long: Trade Zone display enabled AND previous close < previous lower Bollinger Band AND current close is within the current Bollinger Bands
Long: Close crosses above the descending resistance line formed by the two most recent confirmed pivot highs, where the older pivot high is greater than the newer pivot high
Long: Heikin-Ashi close > Heikin-Ashi open AND previous bar Heikin-Ashi close ≤ Heikin-Ashi open
Short: Heikin-Ashi close ≤ Heikin-Ashi open AND previous bar Heikin-Ashi close > Heikin-Ashi open
Long: Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi low = Heikin-Ashi open
Short: Heikin-Ashi close ≤ Heikin-Ashi open AND Heikin-Ashi high = Heikin-Ashi open
Long: SuperTrend changes from bearish to bullish
Short: SuperTrend changes from bullish to bearish
Exit: long, close < long stop
Exit: long, high ≥ H1
Exit: long, high ≥ H2
Exit: long, high ≥ H3