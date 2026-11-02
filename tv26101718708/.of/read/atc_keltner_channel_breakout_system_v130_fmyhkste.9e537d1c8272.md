Calculation: Upper band = Hull moving average of close + ATR multiplier × ATR.
Calculation: Lower band = Hull moving average of close − ATR multiplier × ATR, using the same lengths and multiplier as the upper band.
Calculation: Volume Z-score = (volume − rolling SMA of volume) / rolling population standard deviation of volume; use zero when the mean or standard deviation is unavailable or the standard deviation is zero.
Calculation: Breakout bias = bullish on a confirmed long breakout and bearish on a confirmed short breakout; each breakout resets a hold counter to a configurable number of bars. On each subsequent bar without a breakout, decrement a positive counter. When the counter was already zero at the start of a bar without a breakout, clear the bias if close is strictly between the bands.
Long: Close > upper band AND previous close <= previous upper band AND (volume gate disabled OR volume Z-score >= threshold).
Short: Close < lower band AND previous close >= previous lower band AND (volume gate disabled OR volume Z-score >= threshold).
Long: Breakout bias = bullish.
Short: Breakout bias = bearish.
Long: Close >= Hull moving average of close.
Short: Close < Hull moving average of close.
Exit: long, close < upper band AND close > lower band AND bars since the confirmed long breakout <= hold period.
Exit: short, close < upper band AND close > lower band AND bars since the confirmed short breakout <= hold period.