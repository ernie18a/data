Calculation: Resistance = latest confirmed pivot high, greater than the highs of the same number of bars before and after the pivot
Calculation: Support = latest confirmed pivot low, lower than the lows of the same number of bars before and after the pivot
Calculation: Rejection zone width = chart-timeframe ATR × zone-width multiplier
Calculation: Bearish rejection candle = upper wick ≥ candle body × wick/body ratio AND close ≤ low + candle range × close-location threshold
Calculation: Bullish rejection candle = lower wick ≥ candle body × wick/body ratio AND close ≥ high − candle range × close-location threshold
Calculation: Bearish engulfing = close < open AND close < prior bar low AND open ≥ prior bar close
Calculation: Bullish engulfing = close > open AND close > prior bar high AND open ≤ prior bar close
Calculation: HTF KAMA = KAMA calculated on a higher timeframe using its last completed bar
Exit: Long, high ≥ resistance − rejection zone width AND low ≤ resistance + rejection zone width AND (bearish rejection candle OR optional bearish engulfing) AND (HTF close > HTF KAMA when the HTF trend filter is enabled) AND (current bar is completed when close confirmation is enabled)
Exit: Short, high ≥ support − rejection zone width AND low ≤ support + rejection zone width AND (bullish rejection candle OR optional bullish engulfing) AND (HTF close < HTF KAMA when the HTF trend filter is enabled) AND (current bar is completed when close confirmation is enabled)