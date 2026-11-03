Calculation: Confirmed price pivot = a high or low at a bar that is at least as extreme as each of a parameterized number of preceding bars and strictly more extreme than each of the same number of subsequent bars; evaluate decisions on the confirmation bar, using oscillator values from the pivot bar.
Calculation: VWAP bands = session-anchored VWAP of typical price, reset daily, plus or minus a parameterized multiple of ATR.
Calculation: Hull slope = Hull moving average minus its value a parameterized number of bars earlier.
Long: Close > Hull moving average.
Short: Close <= Hull moving average.
Long: Hull moving average > its value a parameterized number of bars earlier.
Short: Hull moving average <= its value a parameterized number of bars earlier.
Long: A price low pivot is confirmed AND its low < the preceding confirmed low pivot's low AND RSI at the new pivot > RSI at the preceding pivot, using either of two RSI lengths, one shorter than the other.
Short: A price high pivot is confirmed AND its high > the preceding confirmed high pivot's high AND RSI at the new pivot < RSI at the preceding pivot, using either of the same two RSI lengths.
Long: A price low pivot is confirmed AND its low > the preceding confirmed low pivot's low AND the longer-length RSI at the new pivot < RSI at the preceding pivot.
Short: A price high pivot is confirmed AND its high < the preceding confirmed high pivot's high AND the longer-length RSI at the new pivot > RSI at the preceding pivot.
Long: A price low pivot with a shorter confirmation lookback than the RSI pivots is confirmed AND its low < the low of any of a parameterized number of preceding confirmed low pivots AND CMO at the new pivot > CMO at that same preceding pivot.
Short: A price high pivot with a shorter confirmation lookback than the RSI pivots is confirmed AND its high > the high of any of a parameterized number of preceding confirmed high pivots AND CMO at the new pivot < CMO at that same preceding pivot.
Long: A price low pivot is confirmed AND its low < the preceding confirmed low pivot's low AND the longer-length RSI at the new pivot > RSI at the preceding pivot AND Hull moving average > its value a parameterized number of bars earlier AND close > session-anchored VWAP of typical price AND current RSI < an upper threshold AND volume > a parameterized multiple of its moving average.
Short: A price high pivot is confirmed AND its high > the preceding confirmed high pivot's high AND the longer-length RSI at the new pivot < RSI at the preceding pivot AND Hull moving average <= its value the same number of bars earlier AND close < session-anchored VWAP of typical price AND current RSI > a lower threshold AND volume > the same multiple of its moving average.
Long: Volume >= a parameterized multiple of its moving average AND low <= the lowest low over a lookback including the current bar AND close > (high + low) / 2.
Short: Volume >= the same multiple of its moving average AND high >= the highest high over the same lookback including the current bar AND close < (high + low) / 2.
Long: Low <= lower VWAP band + a parameterized multiple of ATR AND close > lower VWAP band.
Short: High >= upper VWAP band - the same multiple of ATR AND close < upper VWAP band.
Long: Hull slope > a parameterized multiple of current ATR AND previous bar's Hull slope <= that same current ATR threshold.
Short: Hull slope < the negative of the same current ATR threshold AND previous bar's Hull slope >= the negative of that same current ATR threshold.