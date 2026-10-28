Calculation: Money Flow Divergence = EMA of close momentum
Calculation: ADX = SMA of the absolute difference between +DI and -DI, divided by their sum, times 100; +DI and -DI are SMAs of positive and negative directional movement divided by true range, times 100
Calculation: Bullish engulfing = close > prior open AND open < prior close AND current high-low range > prior high-low range
Calculation: Bearish engulfing = close < prior open AND open > prior close AND current high-low range > prior high-low range
Long: datetime is between 9:30 and 12:00 ET AND cumulativeLoss > daily loss limit AND short-period EMA(close) > long-period EMA(close) AND close > VWAP AND Money Flow Divergence > its SMA AND bullish engulfing AND ADX > trend-strength threshold
Short: datetime is between 9:30 and 12:00 ET AND cumulativeLoss > daily loss limit AND short-period EMA(close) < long-period EMA(close) AND close < VWAP AND Money Flow Divergence < its SMA AND bearish engulfing AND ADX > trend-strength threshold
Exit: long, low <= entry-signal close - 0.8 × ATR OR high >= entry-signal close + 2 × ATR OR (close >= entry price + ATR AND low <= entry price)
Exit: short, high >= entry-signal close + 0.8 × ATR OR low <= entry-signal close - 2 × ATR OR (close <= entry price - ATR AND high >= entry price)