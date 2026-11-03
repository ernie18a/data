Calculation: Base high = highest high over the base-length bars immediately before the current chart bar
Calculation: Base low = lowest low over the base-length bars immediately before the current chart bar
Calculation: Base range = Base high - Base low
Calculation: Zone score = 1 if Base range < ATR × base-range multiplier, plus 2 if the current candle body exceeds ATR × impulse multiplier in the breakout direction, plus 2 if current volume > volume SMA × volume multiplier
Long: Base range < ATR × base-range multiplier AND close > open AND close - open > ATR × impulse multiplier AND volume > volume SMA × volume multiplier AND close > Base high AND Zone score >= minimum score
Short: Base range < ATR × base-range multiplier AND close < open AND open - close > ATR × impulse multiplier AND volume > volume SMA × volume multiplier AND close < Base low AND Zone score >= minimum score