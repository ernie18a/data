Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Long EMA = EMA of close with a longer lookback than both the fast and slow EMAs
Calculation: Confirmed swing high/low = pivot high/low using equal left and right lookbacks; the lookback is the S/R lookback, increased to at least 100 on daily-or-higher chart timeframes
Calculation: Tolerance = close × 0.005 on daily-or-higher chart timeframes; otherwise close × 0.002
Calculation: Stochastic RSI %K = SMA of the stochastic value of RSI(close) over its lookback, using a shorter smoothing lookback
Calculation: Stochastic RSI %D = SMA of Stochastic RSI %K using a longer smoothing lookback than %K
Long: Fast EMA > Slow EMA AND close > Long EMA AND ((low <= Fast EMA AND high >= Slow EMA) OR (low <= Slow EMA AND high >= Fast EMA) OR (low within Tolerance of the last confirmed swing low) OR (close <= last confirmed swing low + 2 × Tolerance)) AND Stochastic RSI %K crosses above %D while %K is below the oversold threshold AND volume > SMA(volume)
Short: Fast EMA < Slow EMA AND close < Long EMA AND ((low <= Fast EMA AND high >= Slow EMA) OR (low <= Slow EMA AND high >= Fast EMA) OR (high within Tolerance of the last confirmed swing high) OR (close >= last confirmed swing high − 2 × Tolerance)) AND Stochastic RSI %K crosses below %D while %K is above the overbought threshold AND volume > SMA(volume)