Long: EMA(short) crosses above EMA(medium) AND close > EMA(long) AND RSI < overbought threshold
Long: EMA(medium) > EMA(long) AND low <= EMA(medium) AND close > EMA(medium) AND close > open AND close > EMA(long) AND more than the minimum gap has passed since the previous long pullback signal
Long: bullish engulfing condition OR hammer condition, and more than the minimum gap has passed since the previous bullish pattern signal
Short: EMA(short) crosses below EMA(medium) AND close < EMA(long) AND RSI > oversold threshold
Short: EMA(medium) < EMA(long) AND high >= EMA(medium) AND close < EMA(medium) AND close < open AND close < EMA(long) AND more than the minimum gap has passed since the previous short pullback signal
Short: bearish engulfing condition OR shooting-star condition, and more than the minimum gap has passed since the previous bearish pattern signal
Calculation: EMA(short), EMA(medium), and EMA(long) use progressively longer lookbacks
Calculation: Bullish engulfing = green candle whose body fully contains the previous red candle's body, is larger than that body by a minimum multiplier, and is at least a minimum ATR multiple; close[1] < close[4]
Calculation: Bearish engulfing = red candle whose body fully contains the previous green candle's body, is larger than that body by a minimum multiplier, and is at least a minimum ATR multiple; close[1] > close[4]
Calculation: Hammer = body > 0 AND range >= minimum ATR multiple AND lower wick >= minimum body multiple AND upper wick <= maximum body multiple AND close[1] < close[4] AND RSI < bullish-pattern threshold
Calculation: Shooting star = body > 0 AND range >= minimum ATR multiple AND upper wick >= minimum body multiple AND lower wick <= maximum body multiple AND close[1] > close[4] AND RSI > bearish-pattern threshold
Calculation: Body = abs(close - open); range = high - low; upper wick = high - max(close, open); lower wick = min(close, open) - low