Calculation: entry price = close on the signal bar
Calculation: long stop = min(entry price - ATR(ATR lookback) * ATR stop multiplier, lowest(low, swing lookback) * (1 - wick buffer / 100)), using signal-bar values and held fixed for the position
Calculation: short stop = max(entry price + ATR(ATR lookback) * ATR stop multiplier, highest(high, swing lookback) * (1 + wick buffer / 100)), using signal-bar values and held fixed for the position
Calculation: long risk = entry price - long stop
Calculation: short risk = short stop - entry price
Calculation: first long target = entry price + long risk * first reward ratio
Calculation: second long target = entry price + long risk * second reward ratio
Calculation: first short target = entry price - short risk * first reward ratio
Calculation: second short target = entry price - short risk * second reward ratio
Long: EMA(close, shorter lookback) > EMA(close, middle lookback) AND EMA(close, middle lookback) > EMA(close, longer lookback) AND RSI(close, RSI lookback) >= long lower RSI threshold AND RSI(close, RSI lookback) <= long upper RSI threshold AND Supertrend direction turns bullish AND (volume filter disabled OR volume > SMA(volume, volume lookback))
Short: EMA(close, shorter lookback) < EMA(close, middle lookback) AND EMA(close, middle lookback) < EMA(close, longer lookback) AND RSI(close, RSI lookback) >= short lower RSI threshold AND RSI(close, RSI lookback) <= short upper RSI threshold AND Supertrend direction turns bearish AND (volume filter disabled OR volume > SMA(volume, volume lookback))
Exit: long, low <= long stop
Exit: long, high >= first long target
Exit: long, high >= second long target
Exit: short, high >= short stop
Exit: short, low <= first short target
Exit: short, low <= second short target