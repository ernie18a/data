Calculation: Range high = highest high over the range lookback
Calculation: Range low = lowest low over the range lookback
Calculation: Range midpoint = (range high + range low) / 2
Calculation: Near range low = low <= range low + 2% of (range high - range low)
Calculation: Near range high = high >= range high - 2% of (range high - range low)
Calculation: In range = high <= range high AND low >= range low
Calculation: Current average volume = average volume of prior bars accumulated while they were in range since the last range change and before a breakout; if there are none, use the simple moving average of volume over the range lookback
Calculation: Locked average volume = current average volume when the first raw breakout occurs before the range changes
Calculation: Strong volume = volume > locked average volume * 1.05
Calculation: Bullish raw breakout = close > range high AND close > VWAP
Calculation: Bearish raw breakout = close < range low AND close < VWAP
Calculation: Bullish breakout confirmation = previous bar had a bullish raw breakout AND close > range high AND volume >= current average volume
Calculation: Bearish breakout confirmation = previous bar had a bearish raw breakout AND close < range low AND volume >= current average volume
Calculation: Strong bullish trend = close > EMA20 AND EMA20 > EMA50 AND EMA50 > EMA200
Calculation: Strong bearish trend = close < EMA20 AND EMA20 < EMA50 AND EMA50 < EMA200
Calculation: Reversal long = close < range midpoint AND near range low AND close > open AND close > previous bar high
Calculation: Reversal short = close > range midpoint AND near range high AND close < open AND close < previous bar low
Calculation: Rejection long = close < range midpoint AND near range low AND close > open AND volume >= current average volume
Calculation: Rejection short = close > range midpoint AND near range high AND close < open AND volume >= current average volume
Calculation: Long confirmation = a prior bar had a long reversal trigger and the current close > previous bar high
Calculation: Short confirmation = a prior bar had a short reversal trigger and the current close < previous bar low
Calculation: Volume spike = locked average volume exists AND volume > locked average volume * 1.5
Long: (strong bullish trend AND (bullish breakout confirmation OR reversal long with volume >= current average volume OR long confirmation OR in range)) OR (NOT strong bullish trend AND NOT strong bearish trend AND (bullish breakout confirmation OR rejection long)) OR (bullish raw breakout AND strong volume) OR (volume spike AND close > open)
Short: (strong bearish trend AND (bearish breakout confirmation OR reversal short with volume >= current average volume OR short confirmation OR in range)) OR (NOT strong bullish trend AND NOT strong bearish trend AND (bearish breakout confirmation OR rejection short)) OR (bearish raw breakout AND strong volume) OR (volume spike AND close < open)