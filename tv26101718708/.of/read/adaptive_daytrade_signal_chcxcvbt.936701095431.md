Calculation: VWAP = cumulative(typical price * volume) / cumulative(volume), typical price = (high+low+close)/3, reset each trading day
Calculation: VolOK = volume >= multiplier * SMA(volume, n), multiplier >= 1
Calculation: Entry price = close of the signal bar
Calculation: StopLong = min(lowest low of the last N bars including the current bar, EntryPrice - k*ATR); RLong = EntryPrice - StopLong; TargetLong = EntryPrice + m*RLong, m > 1
Calculation: StopShort = max(highest high of the last N bars including the current bar, EntryPrice + k*ATR); RShort = StopShort - EntryPrice; TargetShort = EntryPrice - m*RShort, m > 1
Long: (the most recent entry signal was not a long) AND VolOK AND close > open AND ((ADX >= trend threshold AND EMA(fast) > EMA(slow) AND EMA(trend) > EMA(trend) 3 bars earlier AND close > EMA(trend) AND abs(low - EMA(fast)) <= EMA(fast) * pullback% AND close > VWAP) OR (ADX < trend threshold AND close <= lower Bollinger Band AND RSI <= oversold level)); EMA lengths: fast < slow < trend
Short: (the most recent entry signal was not a short) AND VolOK AND close < open AND ((ADX >= trend threshold AND EMA(fast) < EMA(slow) AND EMA(trend) < EMA(trend) 3 bars earlier AND close < EMA(trend) AND abs(high - EMA(fast)) <= EMA(fast) * pullback% AND close < VWAP) OR (ADX < trend threshold AND close >= upper Bollinger Band AND RSI >= overbought level)); EMA lengths: fast < slow < trend
Exit: long, low <= StopLong OR high >= TargetLong
Exit: short, high >= StopShort OR low <= TargetShort