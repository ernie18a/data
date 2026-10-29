Calculation: EMA envelope = EMA of close ± standard deviation of close over the same lookback multiplied by a deviation multiplier
Calculation: Anchored VWAP = session-anchored volume-weighted average of (high + low + close) / 3
Calculation: VWAP stretch bands = anchored VWAP ± standard deviation of close minus anchored VWAP over the envelope lookback multiplied by a stretch multiplier
Calculation: Average volume = simple moving average of volume
Calculation: Bull rejection candle = close > open AND lower wick > body size multiplied by a threshold AND close > low + (high − low) multiplied by a threshold
Calculation: Bear rejection candle = close < open AND upper wick > body size multiplied by a threshold AND close < low + (high − low) multiplied by a threshold
Long: low < lower EMA envelope AND low < lower VWAP stretch band AND RSI ≤ oversold threshold AND volume ≥ average volume × impulse multiplier AND bull rejection candle AND close > lower EMA envelope AND cooldown clear
Short: high > upper EMA envelope AND high > upper VWAP stretch band AND RSI ≥ overbought threshold AND volume ≥ average volume × impulse multiplier AND bear rejection candle AND close < upper EMA envelope AND cooldown clear