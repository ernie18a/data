Calculation: Bar range = max(high - low, minimum price increment)
Calculation: Safe ATR = max(ATR(ATR lookback), true range if ATR is unavailable, minimum price increment)
Calculation: Impulse size = bar range / safe ATR
Calculation: Body efficiency = abs(close - open) / bar range
Calculation: Close location = (close - low) / bar range
Calculation: High-normalized score(x, lower, upper) = clamp(100 × (x - lower) / (upper - lower), 0, 100), or 0 if upper = lower
Calculation: Low-normalized score(x, good, bad) = clamp(100 × (bad - x) / (bad - good), 0, 100), or 0 if bad = good
Calculation: Peak-normalized score(x, lower, ideal, upper) = high-normalized score(x, lower, ideal) when x ≤ ideal; otherwise low-normalized score(x, ideal, upper)
Calculation: Impulse size score = peak-normalized score(impulse size, minimum impulse ATR × size-score lower factor, minimum impulse ATR + size-score ideal offset, oversized impulse ATR)
Calculation: Body score = high-normalized score(body efficiency, minimum body efficiency × body-score lower factor, body-score upper bound)
Calculation: Bullish edge score = high-normalized score(close location, minimum close location × edge-score lower factor, bullish edge-score upper bound)
Calculation: Bearish edge score = high-normalized score(1 - close location, minimum close location × edge-score lower factor, bearish edge-score upper bound)
Calculation: Volume score = peak-normalized score(volume / SMA(volume, volume lookback), volume-score lower bound, volume-score ideal, climax volume ratio), using a volume ratio of 1 when the average is unavailable or nonpositive
Calculation: Directional trend score(side) = clamp(price-alignment score + EMA-stack score + slope score, 0, 100); price-alignment score is the aligned-price score when close is at or above the slow EMA for long, or at or below it for short, otherwise the misaligned-price score; EMA-stack score is the stack bonus when the fast EMA is at or above the slow EMA for long, or at or below it for short, otherwise 0; slope score is the slope weight × high-normalized score(abs(slow EMA - slow EMA[slope lookback]) / safe ATR, weak-slope bound, strong-slope bound) when that EMA change aligns with side, otherwise 0
Calculation: Bullish impulse score = clamp(size weight × impulse size score + body weight × body score + edge weight × bullish edge score + volume weight × volume score + trend weight × directional trend score(long), 0, 100)
Calculation: Bearish impulse score = clamp(size weight × impulse size score + body weight × body score + edge weight × bearish edge score + volume weight × volume score + trend weight × directional trend score(short), 0, 100)
Calculation: Bullish impulse qualifies = close > open AND impulse size ≥ minimum impulse ATR AND body efficiency ≥ minimum body efficiency AND close location ≥ minimum close location AND bullish impulse score ≥ minimum impulse score AND side setting permits long
Calculation: Bearish impulse qualifies = close < open AND impulse size ≥ minimum impulse ATR AND body efficiency ≥ minimum body efficiency AND 1 - close location ≥ minimum close location AND bearish impulse score ≥ minimum impulse score AND side setting permits short
Calculation: Accepted impulse = either qualified impulse when bar-close confirmation is disabled or the bar is closed, and no earlier accepted impulse exists or at least the impulse cooldown bars have elapsed since it
Long: The most recent accepted impulse is bullish AND its age in chart bars is ≤ the tracking lookback
Short: The most recent accepted impulse is bearish AND its age in chart bars is ≤ the tracking lookback