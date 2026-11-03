Calculation: Short-term EMA = Exponential moving average of close with a shorter lookback than the long-term EMA
Calculation: Long-term EMA = Exponential moving average of close with a longer lookback than the short-term EMA
Calculation: Pullback distance = Absolute percentage distance between close and the short-term EMA
Long: close > long-term EMA AND pullback distance <= pullback threshold AND RSI > bullish momentum threshold AND volume > average volume AND close > open
Short: close < long-term EMA AND pullback distance <= pullback threshold AND RSI < bearish momentum threshold AND volume > average volume AND close < open