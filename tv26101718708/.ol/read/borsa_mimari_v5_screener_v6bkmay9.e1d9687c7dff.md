Calculation: Score = +1 if MACD line > signal line, else −1; +1 if RSI > 50 and RSI ≤ 70, else −1; +1 if ADX > threshold and +DI > −DI, else −1; +1 if close is above each of the short-term and long-term EMAs, else −1 for each; +1 if SuperTrend is bullish, else −1; +1 if volume > its moving average × volume multiplier, else −1
Calculation: Dip zone upper/lower = long-term EMA − ATR × (dip multiplier − 0.5) / (dip multiplier + 0.5); deep-dip zone uses (dip multiplier + 0.5) / (dip multiplier + 1.5)
Calculation: Peak zone lower/upper = short-term EMA + ATR × (peak multiplier − 0.5) / (peak multiplier + 0.5); extreme-peak zone uses (peak multiplier + 0.5) / (peak multiplier + 1.5)
Calculation: Trade Zone = close SMA ± band multiplier × close standard deviation, using the same lookback for both
Calculation: Heikin-Ashi close = (open + high + low + close) / 4; first Heikin-Ashi open = (open + close) / 2, thereafter = (prior Heikin-Ashi open + prior Heikin-Ashi close) / 2; Heikin-Ashi bullish when its close > its open
Calculation: Falling resistance line = line through the latest two confirmed pivot highs when the earlier pivot high is higher; each pivot requires the pivot lookback number of bars on both sides
Calculation: Targets after a new dip signal = lowest low over the last five bars + ATR × each of three progressively larger target multipliers; after a new AL signal, if targets are unset or all hit, targets = signal-bar close + ATR × each of the same three multipliers
Calculation: Long stop = most recent SuperTrend value set on an AL signal and thereafter trailed upward to the maximum of the prior stop and current SuperTrend while SuperTrend is bullish
Long: MACD line > signal line
Long: RSI > 50
Long: ADX > threshold AND +DI > −DI
Long: Close > short-term EMA
Long: Close > long-term EMA
Long: SuperTrend is bullish
Long: Volume > its moving average × volume multiplier
Long: Score ≥ 2
Long: Close < dip-zone upper boundary
Long: SuperTrend is bullish AND close < dip-zone upper boundary AND MACD line > signal line AND RSI > 50 AND RSI ≤ 70 AND Score ≥ 1
Long: SuperTrend is bullish AND close < dip-zone upper boundary AND MACD line > signal line AND RSI > 50 AND volume > its moving average × volume multiplier AND Score ≥ 3
Long: SuperTrend is bullish AND MACD line > signal line AND RSI > 50 AND RSI ≤ 70 AND ADX > threshold AND +DI > −DI AND close > short-term EMA AND close > long-term EMA AND Score ≥ 6 AND this condition was false on the prior bar
Long: Prior bar close was below the lower Trade Zone band AND current close is within the Trade Zone bands
Long: Close crosses above the falling resistance line
Long: Heikin-Ashi is bearish AND Heikin-Ashi close > (Heikin-Ashi open + Heikin-Ashi close) / 2 AND this condition was false on the prior bar
Long: Heikin-Ashi is bullish AND prior bar Heikin-Ashi was bearish
Long: Heikin-Ashi is bullish AND Heikin-Ashi low = Heikin-Ashi open
Long: SuperTrend changes from bearish to bullish
Long: Close ≥ nearest Fibonacci retracement level AND close < that level + ATR
Short: MACD line < signal line
Short: RSI < 50
Short: ADX > threshold AND +DI ≤ −DI
Short: Close < short-term EMA
Short: Close < long-term EMA
Short: SuperTrend is bearish
Short: Score < 0
Short: Close > peak-zone lower boundary
Short: SuperTrend is bearish AND close > peak-zone lower boundary AND MACD line < signal line AND RSI ≤ 70 AND Score ≤ −1
Short: SuperTrend is bearish AND close > peak-zone lower boundary AND MACD line < signal line AND RSI < 50 AND volume > its moving average × volume multiplier AND Score ≤ −3
Short: SuperTrend is bearish AND MACD line < signal line AND RSI < 50 AND ADX > threshold AND +DI ≤ −DI AND close < short-term EMA AND close < long-term EMA AND Score ≤ −4 AND this condition was false on the prior bar
Short: Heikin-Ashi is bullish AND Heikin-Ashi close < (Heikin-Ashi open + Heikin-Ashi close) / 2 AND this condition was false on the prior bar
Short: Heikin-Ashi changes from bullish to bearish
Short: Heikin-Ashi is bearish AND Heikin-Ashi high = Heikin-Ashi open
Short: SuperTrend changes from bullish to bearish
Short: Close ≤ nearest Fibonacci retracement level AND close > that level − ATR
Exit: Long, close < long stop
Exit: Long, high ≥ any active target