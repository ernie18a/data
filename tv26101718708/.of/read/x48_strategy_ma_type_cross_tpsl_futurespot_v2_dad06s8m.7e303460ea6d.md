Calculation: Fast MA = selected moving average of close with a shorter lookback than the Slow MA
Calculation: Slow MA = selected moving average of close with a longer lookback than the Fast MA
Calculation: MACD histogram = EMA(close, fast lookback) − EMA(close, slow lookback) − EMA of that difference over a signal lookback; the fast lookback is shorter than the slow lookback
Calculation: Surfing EMA = EMA(close, lookback)
Calculation: Bar-paint average = EMA(OHLC4, short lookback)
Long: Fast MA crosses above Slow MA
Long: Fast MA > Slow MA
Long: RSI crosses above its overbought threshold
Long: MACD histogram crosses above zero
Long: Close crosses above Surfing EMA
Short: Fast MA crosses below Slow MA
Short: Fast MA < Slow MA
Short: RSI crosses below its oversold threshold
Short: MACD histogram crosses below zero
Short: Close crosses below Surfing EMA
Exit: Long, MA2 mode enabled AND Fast MA crosses below the middle moving average
Exit: Long, spot mode enabled AND Fast MA crosses below Slow MA
Exit: Long, take-profit/stop-loss mode enabled AND (configured stop-loss percentage > 0 AND low <= entry price × (1 − stop-loss percentage / 100) OR configured long take-profit percentage > 0 AND high >= entry price × (1 + long take-profit percentage / 100))
Exit: Short, take-profit/stop-loss mode enabled AND (configured stop-loss percentage > 0 AND high >= entry price × (1 + stop-loss percentage / 100) OR configured short take-profit percentage > 0 AND low <= entry price × (1 − short take-profit percentage / 100))
Exit: Long, callback trailing mode enabled AND close < highest high over the callback lookback × (1 − callback percentage / 100)
Exit: Short, callback trailing mode enabled AND close > lowest low over the callback lookback × (1 + callback percentage / 100)