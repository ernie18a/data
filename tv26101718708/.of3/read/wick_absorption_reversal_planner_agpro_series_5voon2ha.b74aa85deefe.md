Calculation: Adjusted ATR = max(ATR(ATR lookback) when available, true range otherwise, minimum tick size)
Calculation: Lower wick = min(open, close) - low
Calculation: Upper wick = high - max(open, close)
Calculation: Candle range = max(high - low, minimum tick size)
Calculation: Lower-wick ATR ratio = lower wick / adjusted ATR
Calculation: Upper-wick ATR ratio = upper wick / adjusted ATR
Calculation: Lower-wick range ratio = lower wick / candle range
Calculation: Upper-wick range ratio = upper wick / candle range
Calculation: Relative volume = volume / SMA(volume, relative-volume lookback) when the SMA is positive, otherwise the relative-volume fallback
Calculation: An absorption event stores its side, bar, and rails as the active pocket; a new event replaces the pocket, invalidation clears it after that bar is evaluated, and expiry does not clear it
Calculation: At a bullish absorption event, store reclaim rail = max(open, close) + adjusted ATR * reclaim buffer ATR; failure rail = low - adjusted ATR * failure buffer ATR; room rail = highest(high[1], room lookback)
Calculation: At a bearish absorption event, store reclaim rail = min(open, close) - adjusted ATR * reclaim buffer ATR; failure rail = high + adjusted ATR * failure buffer ATR; room rail = lowest(low[1], room lookback)
Calculation: Pocket age = current bar index - stored absorption bar index
Calculation: Expired = an active pocket exists and pocket age > maximum pocket age
Calculation: Bullish reclaim = active pocket is bullish, current bar is after its absorption bar, and close > its stored reclaim rail
Calculation: Bearish reclaim = active pocket is bearish, current bar is after its absorption bar, and close < its stored reclaim rail
Calculation: Reversal score = round(clamp(score baseline + clamp(active-side wick ATR ratio * wick-score multiplier, score floor, wick-score cap) + clamp(active-side wick range ratio * ratio-score multiplier, score floor, ratio-score cap) + clamp(distance beyond the active reclaim rail in the reversal direction / adjusted ATR * reclaim-score multiplier, score floor, reclaim-score cap) + clamp(relative volume * volume-score multiplier, score floor, volume-score cap) + clamp(abs(room rail - close) / adjusted ATR * room-score multiplier, score floor, room-score cap), score floor, score ceiling))
Long: lower-wick ATR ratio >= minimum wick ATR AND lower-wick range ratio >= minimum wick-to-range ratio AND low <= lowest(low[1], wick-context lookback) AND close > min(open, close) AND relative volume >= minimum relative volume
Short: upper-wick ATR ratio >= minimum wick ATR AND upper-wick range ratio >= minimum wick-to-range ratio AND high >= highest(high[1], wick-context lookback) AND close < max(open, close) AND relative volume >= minimum relative volume
Long: bullish reclaim AND NOT (bullish reclaim OR bearish reclaim)[1]
Short: bearish reclaim AND NOT (bullish reclaim OR bearish reclaim)[1]
Long: bullish reclaim AND reversal score >= minimum ready score AND NOT expired
Short: bearish reclaim AND reversal score >= minimum ready score AND NOT expired
Exit: long, active pocket is bullish AND close < its stored failure rail
Exit: short, active pocket is bearish AND close > its stored failure rail