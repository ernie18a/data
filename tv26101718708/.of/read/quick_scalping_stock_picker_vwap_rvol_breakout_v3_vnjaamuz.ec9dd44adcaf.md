Calculation: VWAP = session-anchored (resets each day) volume-weighted average price of (high+low+close)/3
Calculation: RVOL = volume / SMA(volume, n) taken over the n bars before the current bar (current bar excluded)
Calculation: PriorHigh / PriorLow = highest high / lowest low of the previous m bars, current bar excluded
Calculation: ClosePos = (close-low)/(high-low); BodyFrac = abs(close-open)/(high-low)
Calculation: HTF trend = on a higher timeframe than the chart, using the bar still forming (the one containing the current chart bar), compare its close with EMA(close, slow length), the same length as the chart slow EMA
Calculation: EntryATR = ATR value on the bar where the position was opened, held fixed while in the position
Calculation: LongScore = 25*(RVOL >= min) + 25*(close > VWAP AND EMA fast > EMA slow AND close > EMA fast AND HTF close > HTF EMA) + 20*(RSI > upper-mid level AND RSI < overbought cap) + 20*(close > PriorHigh) + 10*(close > open AND ClosePos above a high threshold AND BodyFrac above a moderate threshold); EMA fast has a shorter length than EMA slow
Calculation: ShortScore = 25*(RVOL >= min) + 25*(close < VWAP AND EMA fast < EMA slow AND close < EMA fast AND HTF close < HTF EMA) + 20*(RSI < lower-mid level AND RSI > oversold floor) + 20*(close < PriorLow) + 10*(close < open AND ClosePos below a low threshold AND BodyFrac above a moderate threshold)
Long: bar time within the trading window AND LongScore >= threshold
Short: shorting allowed AND bar time within the trading window AND ShortScore >= threshold
Exit: long, low <= entry price - stop multiple*EntryATR OR high >= entry price + R multiple*stop multiple*EntryATR OR bars since entry >= max hold OR bar time outside the trading window OR Short condition true
Exit: short, high >= entry price + stop multiple*EntryATR OR low <= entry price - R multiple*stop multiple*EntryATR OR bars since entry >= max hold OR bar time outside the trading window OR Long condition true