Calculation: RSI divergence = current lookback extreme in price versus the preceding equal-length lookback extreme, with RSI extreme moving oppositely
Calculation: Bullish/bearish structure break = close crosses the latest confirmed swing high/low in the opposing direction of the prior structure state
Calculation: Bullish/bearish sweep = price pierces the current structure extreme and closes back across it, after that extreme has stood for more than one bar
Calculation: Bullish/bearish reversal wick = lower/upper wick divided by candle body meets a parameterized minimum ratio; body must be nonzero
Calculation: Higher-timeframe trend = faster EMA above/below slower EMA on the higher-timeframe security series (forming bar in realtime; last confirmed value historically)
Calculation: ATR stop and target levels = entry price offset by parameterized multiples of ATR; the first profit target is two ATR from entry
Long: bullish structure break OR (bullish sweep AND bearish structure state AND bullish reversal wick) AND RSI above its long minimum and below its hard maximum AND (RSI below 75 OR RSI rising for two consecutive bars and no bearish RSI divergence) AND volume above its moving average times a parameterized threshold AND faster EMA above slower EMA AND close above the longer-term EMA AND ADX above its minimum AND close above VWAP and below the hard-overextension threshold AND higher-timeframe trend bullish AND MACD histogram positive
Short: bearish structure break OR (bearish sweep AND bullish structure state AND bearish reversal wick) AND RSI below its short maximum and above its oversold level AND volume above its moving average times a parameterized threshold AND faster EMA below slower EMA AND close below the longer-term EMA AND ADX above its minimum AND close below VWAP AND higher-timeframe trend bearish AND MACD histogram negative
Exit: long, low <= long stop OR high >= long target OR bearish structure break
Exit: long, high >= first profit target (partial exit; if trailing is enabled, move the remaining stop to entry price)
Exit: short, high >= short stop OR low <= short target OR bullish structure break
Exit: short, low <= first profit target (partial exit; if trailing is enabled, move the remaining stop to entry price)
Long: bullish RSI divergence
Short: bearish RSI divergence OR shooting-star candle OR close above VWAP by more than the hard-overextension threshold