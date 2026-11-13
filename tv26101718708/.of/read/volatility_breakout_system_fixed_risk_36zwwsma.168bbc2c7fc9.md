Calculation: Keltner upper = EMA(close) + m*ATR; Keltner lower = EMA(close) - m*ATR (m is a multiplier; the Keltner EMA length is shorter than the trend EMA length)
Calculation: trend EMA = EMA(close) with a longer length than the Keltner EMA
Calculation: stop ATR = ATR on chart-timeframe bars, current bar
Long: flat AND close crosses above Keltner upper (previous close <= previous upper AND close > upper) AND volume > SMA(volume) AND close > trend EMA AND RSI(close) > 50 AND ADX > a fixed threshold AND time since the previous entry (long or short) exceeds a fixed cooldown
Short: flat AND close crosses below Keltner lower (previous close >= previous lower AND close < lower) AND volume > SMA(volume) AND close < trend EMA AND RSI(close) < 50 AND ADX > a fixed threshold AND time since the previous entry (long or short) exceeds a fixed cooldown
Exit: long, low <= stop level, where stop level = entry price if the current bar's high > entry price*(1+b%), otherwise entry price - k*stop ATR (b is a small percent; k is a multiplier)
Exit: long, the highest high since entry >= entry price*(1+t%) AND low <= highest high since entry - entry price*o% (t > b > o, all percents)
Exit: short, high >= stop level, where stop level = entry price if the current bar's low < entry price*(1-b%), otherwise entry price + k*stop ATR
Exit: short, the lowest low since entry <= entry price*(1-t%) AND high >= lowest low since entry + entry price*o% (t > b > o, all percents)