Calculation: Candle range = max(high − low, minimum price increment); body % = abs(close − open) / candle range; close location = (close − low) / candle range; upper wick % = (high − max(open, close)) / candle range; lower wick % = (min(open, close) − low) / candle range
Calculation: Volume ratio = volume / its simple moving average over a lookback, or 1 if the average is not positive
Calculation: Range/ATR = candle range / ATR over a lookback, or 1 if ATR is not positive
Calculation: VWAP = current session’s volume-weighted average of (high + low + close) / 3, including the current bar
Calculation: Bull body points = 2 if close > open and body % ≥ strong body threshold; otherwise 1 if close > open and body % ≥ 0.70 × that threshold; otherwise 0. Bear body points use close < open and the same thresholds.
Calculation: Bull close points = 2 if close location ≥ strong close threshold; otherwise 1 if close location ≥ 0.60; otherwise 0. Bear close points = 2 if close location ≤ 1 − strong close threshold; otherwise 1 if close location ≤ 0.40; otherwise 0.
Calculation: Volume points = 2 if volume pressure is enabled and volume ratio ≥ high volume multiplier; otherwise 1 if enabled and volume ratio ≥ 1; otherwise 0 if enabled; use 1 if disabled.
Calculation: ATR points = 2 if ATR expansion is enabled and range/ATR ≥ ATR expansion multiplier; otherwise 1 if enabled and range/ATR ≥ 0.85; otherwise 0 if enabled; use 1 if disabled.
Calculation: VWAP points = 2 if VWAP filter is enabled and close ≥ VWAP for bull points or close ≤ VWAP for bear points; otherwise 0 if enabled; use 1 if disabled.
Calculation: Bull wick point = 1 if lower wick % > upper wick % and lower wick % ≥ 0.20, else 0. Bear wick point = 1 if upper wick % > lower wick % and upper wick % ≥ 0.20, else 0.
Calculation: Bull score = bull body points + bull close points + volume points + ATR points + bull VWAP points + bull wick point, clamped to 0–10. Bear score = corresponding bear points, clamped to 0–10.
Calculation: Bullish absorption = absorption enabled AND volume ratio ≥ absorption volume multiplier AND body % ≤ absorption body maximum AND lower wick % ≥ absorption wick minimum AND close location ≥ 0.45. Bearish absorption uses upper wick % ≥ absorption wick minimum and close location ≤ 0.55, with the same other conditions.
Long: (bull score ≥ medium pressure minimum AND bull score > bear score AND NOT bearish absorption) OR bullish absorption
Short: (bear score ≥ medium pressure minimum AND bear score > bull score AND NOT bullish absorption) OR bearish absorption