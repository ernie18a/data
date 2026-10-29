Calculation: Candle range = high − low
Calculation: Candle body fraction = abs(close − open) / candle range
Calculation: Close location = (close − low) / candle range
Calculation: Upper wick fraction = (high − max(open, close)) / candle range
Calculation: Lower wick fraction = (min(open, close) − low) / candle range
Calculation: Volume ratio = volume / simple moving average of volume over a lookback
Calculation: Range-to-ATR ratio = candle range / average true range over a lookback
Calculation: VWAP = session VWAP calculated from typical price (high + low + close) / 3 and volume on chart-timeframe bars
Calculation: Bullish pressure score = clamp to 0–10 the sum of: 2 if close > open and body fraction ≥ strong-body threshold, else 1 if close > open and body fraction ≥ 0.7 × that threshold, else 0; 2 if close location ≥ strong-close threshold, else 1 if ≥ 0.60, else 0; volume points (if volume filter enabled: 2 if volume ratio ≥ high-volume threshold, else 1 if ≥ 1, else 0; otherwise 1); ATR points (if ATR expansion filter enabled: 2 if range-to-ATR ratio ≥ expansion threshold, else 1 if ≥ 0.85, else 0; otherwise 1); VWAP points (if VWAP filter enabled: 2 if close ≥ VWAP, else 0; otherwise 1); and 1 if lower wick fraction > upper wick fraction and ≥ 0.20, else 0
Calculation: Bearish pressure score = clamp to 0–10 the sum of: 2 if close < open and body fraction ≥ strong-body threshold, else 1 if close < open and body fraction ≥ 0.7 × that threshold, else 0; 2 if close location ≤ 1 − strong-close threshold, else 1 if ≤ 0.40, else 0; the same volume points and ATR points as the bullish pressure score; VWAP points (if VWAP filter enabled: 2 if close ≤ VWAP, else 0; otherwise 1); and 1 if upper wick fraction > lower wick fraction and ≥ 0.20, else 0
Calculation: Bullish absorption = absorption enabled AND volume ratio ≥ absorption-volume threshold AND candle body fraction ≤ absorption maximum-body threshold AND lower wick fraction ≥ absorption-wick threshold AND close location ≥ 0.45
Calculation: Bearish absorption = absorption enabled AND volume ratio ≥ absorption-volume threshold AND candle body fraction ≤ absorption maximum-body threshold AND upper wick fraction ≥ absorption-wick threshold AND close location ≤ 0.55
Long: (Bullish pressure score ≥ medium-score threshold AND bullish pressure score > bearish pressure score AND NOT bearish absorption) OR bullish absorption
Short: (Bearish pressure score ≥ medium-score threshold AND bearish pressure score > bullish pressure score AND NOT bullish absorption) OR bearish absorption