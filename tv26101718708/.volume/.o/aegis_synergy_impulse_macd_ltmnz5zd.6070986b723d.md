Calculation: MACD line = faster moving average of close minus slower moving average of close; use volume-weighted moving averages when volume weighting is enabled
Calculation: MACD signal = exponential moving average of the MACD line, with a shorter lookback than the moving averages used for the MACD line
Calculation: MACD histogram = MACD line minus MACD signal
Calculation: Impulse MACD = exponential moving average of (close minus the highest high over the impulse lookback when close is above its exponential moving average over that lookback; close minus the lowest low over that lookback when close is below that moving average; otherwise zero)
Calculation: Impulse signal = simple moving average of Impulse MACD, using the same lookback as its exponential moving average
Calculation: Impulse histogram = Impulse MACD minus Impulse signal
Long: MACD line > MACD signal AND previous MACD line <= previous MACD signal AND MACD histogram > 0 AND Impulse histogram > 0 AND Impulse MACD > 0 AND close > long-term exponential moving average
Short: MACD line < MACD signal AND previous MACD line >= previous MACD signal AND MACD histogram < 0 AND Impulse histogram < 0 AND Impulse MACD < 0 AND close < long-term exponential moving average