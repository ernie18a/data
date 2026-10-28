Calculation: Fast MA = selected moving average of the configured source using a shorter lookback
Calculation: Slow MA = selected moving average of the configured source using a longer lookback than the Fast MA
Calculation: Middle MA = selected moving average of the configured source
Calculation: CDC average = 2-period EMA of OHLC4
Calculation: MACD histogram = (fast EMA of close − slow EMA of close) − EMA of that difference
Long: Fast MA crosses above Slow MA
Long: RSI crosses above its overbought threshold
Long: MACD histogram crosses above zero
Long: Close crosses above its 21-period EMA
Long: Fast MA > Slow MA AND CDC average > Fast MA
Long: Fast MA > Slow MA AND CDC average < Fast MA
Short: Fast MA crosses below Slow MA
Short: RSI crosses below its oversold threshold
Short: MACD histogram crosses below zero
Short: Close crosses below its 21-period EMA
Short: Fast MA < Slow MA AND CDC average < Fast MA
Short: Fast MA < Slow MA AND CDC average > Fast MA
Exit: Long, Fast MA crosses below Slow MA
Exit: Long, Fast MA crosses below Middle MA
Exit: Long, Low <= entry price − stop-loss distance OR High >= entry price + long take-profit distance
Exit: Short, High >= entry price + stop-loss distance OR Low <= entry price − short take-profit distance
Exit: Long, Close < highest High over the callback lookback × (1 − callback percentage)
Exit: Short, Close > lowest Low over the callback lookback × (1 + callback percentage)