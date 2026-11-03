Calculation: Candle range = high − low; ratios with candle range as denominator are 0 when the range is 0.
Calculation: Body = close − open; body ratio = |body| / candle range; upper wick ratio = (high − max(open, close)) / candle range; lower wick ratio = (min(open, close) − low) / candle range; close location = (2 × close − high − low) / candle range.
Calculation: Z-score of a series = (current value − SMA of the series) / population standard deviation of the series; use 0 when the standard deviation is 0.
Calculation: Relative volume = volume / SMA(volume); use 1 when the denominator is 0.
Calculation: Normalized result = tanh(clamp(4 × body / ATR, −2.5, 2.5)); use 0 for body / ATR when ATR is 0.
Calculation: Pressure = EMA(100 × relative volume × (effort weight × clamp(body / candle range, −1, 1) + result weight × normalized result + location weight × clamp(close location + 0.5 × (lower wick ratio − upper wick ratio), −1, 1)), pressure smoothing length).
Calculation: Pressure signal = EMA(pressure, max(2, floor(1.5 × pressure smoothing length))).
Calculation: Baseline = EMA of a selected OHLC source. Baseline bias = 1 when close > baseline AND baseline > previous baseline; −1 when close < baseline AND baseline < previous baseline; otherwise 0.
Calculation: Drive quality = 0.30 × 25 × clamp(Z-score of relative volume, −2, 2) + 0.30 × 50 × close location + 0.40 × 50 × normalized result. The relative-volume Z-score uses the ATR lookback; the volume Z-score and relative-volume SMA share a separate lookback.
Calculation: Rotation = 2 × (pressure − lowest pressure) / (highest pressure − lowest pressure) − 1 over a lookback equal to the greater of 10 and the ATR lookback; use 0 when highest and lowest pressure are equal.
Calculation: Recent bullish event = at least one bullish drive or bullish absorption condition occurred within the recent-state lookback, including the current bar. Recent bearish event = the corresponding bearish condition occurred within that lookback.
Long: Pressure > drive threshold AND pressure > pressure signal AND close location > 0 AND (baseline filter disabled OR baseline bias >= 0).
Short: Pressure < −drive threshold AND pressure < pressure signal AND close location < 0 AND (baseline filter disabled OR baseline bias <= 0).
Long: Volume Z-score > absorption threshold AND lower wick ratio > upper wick ratio AND body ratio < absorption body-ratio cap AND close location > 0.10 AND pressure > 0 AND (baseline filter disabled OR baseline bias >= 0).
Short: Volume Z-score > absorption threshold AND upper wick ratio > lower wick ratio AND body ratio < absorption body-ratio cap AND close location < −0.10 AND pressure < 0 AND (baseline filter disabled OR baseline bias <= 0).
Short: Highest pressure over the exhaustion lookback > drive threshold AND pressure > 0.55 × drive threshold AND pressure < 0.88 × highest pressure over the exhaustion lookback AND EMA(body, shorter momentum lookback) < EMA(body, longer momentum lookback) AND close location < 0.15.
Long: Lowest pressure over the exhaustion lookback < −drive threshold AND pressure < −0.55 × drive threshold AND pressure > 0.88 × lowest pressure over the exhaustion lookback AND EMA(body, shorter momentum lookback) > EMA(body, longer momentum lookback) AND close location > −0.15.
Long: Pressure crosses above pressure signal.
Short: Pressure crosses below pressure signal.
Long: Drive quality crosses above 0.
Short: Drive quality crosses below 0.
Long: Pressure >= 0.
Short: Pressure < 0.
Long: Drive quality >= 0.
Short: Drive quality < 0.
Long: Pressure > 0.4 × drive threshold.
Short: Pressure < −0.4 × drive threshold.
Long: Baseline bias > 0.
Short: Baseline bias < 0.
Long: Recent bullish event = true AND recent bearish event = false.
Short: Recent bearish event = true AND recent bullish event = false.
Long: Pressure does not cross pressure signal AND rotation > 0.
Short: Pressure does not cross pressure signal AND rotation < 0.