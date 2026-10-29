Calculation: Volume ratio = current volume / simple moving average of volume
Calculation: Close position = (close − low) / (high − low); use 0.5 when high = low
Calculation: Blow-off candle = volume ratio >= blow-off threshold AND high > low AND (high − max(open, close)) / (high − low) >= upper-wick threshold
Calculation: Highest close since entry = highest close from the entry bar through the current bar
Calculation: Hard stop = entry price − stop multiplier × ATR on the entry bar
Calculation: Trailing stop = highest close since entry − trail multiplier × current ATR, once (highest close since entry − entry price) / entry price >= minimum trail gain; otherwise use the hard stop. Effective stop = max(hard stop, trailing stop)
Long: volume ratio >= volume surge threshold AND close > open AND close position >= minimum close position AND RSI < maximum entry RSI AND close > EMA AND NOT blow-off candle AND position is flat
Exit: Long, low <= effective stop OR blow-off candle