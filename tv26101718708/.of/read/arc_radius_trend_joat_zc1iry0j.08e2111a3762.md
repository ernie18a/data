Calculation: Curved radius = ATR × radius multiplier × (1 + min(abs(acceleration / ATR), 2)) ^ curve exponent; use zero for normalized acceleration when ATR is not positive. Velocity is EMA of close change; acceleration is EMA of velocity change, using the same smoothing length.
Calculation: Upper band = midpoint of high and low + curved radius; if the previous close is above the previous upper band, use the greater of this value and the previous upper band. Lower band = midpoint of high and low - curved radius; if the previous close is below the previous lower band, use the lesser of this value and the previous lower band. Initialize each band to its unadjusted value.
Calculation: Trend state = bullish if close > previous upper band; otherwise bearish if close < previous lower band; otherwise retain the previous state. Initialize bullish.
Calculation: Signed efficiency = (close - close at the efficiency lookback) / sum of absolute close changes over that lookback; use zero when the denominator is zero.
Calculation: Entropy = -(pUp × ln(pUp) + pDown × ln(pDown)) / ln(2), where pUp and pDown are the counts of rising and falling closes over the entropy lookback divided by max(their sum, 1), each clamped to [0.001, 0.999]; unchanged closes count as neither.
Calculation: Impact = EMA of abs(ln(close / previous close)) / max(close × volume, 1) × 100000000 over the impact lookback; use zero for the logarithmic return unless both closes are positive. Impact ratio = impact / SMA of impact over the same lookback, or 1 when that SMA is not positive.
Calculation: Expansion score = EMA of (45 × signed efficiency + 25 × (1 - entropy) + clamp(15 × (volume / max(SMA of volume over the impact lookback, 1) - 1) + 15 × body efficiency × pressure, -25, 25) - clamp(15 × (impact ratio - 1), -20, 20)). Body efficiency = abs(close - open) / (high - low); pressure = 2 × (close - low) / (high - low) - 1; use zero for their product when high equals low.
Long: Trend state = bullish
Short: Trend state = bearish
Long: Trend state = bullish AND previous trend state = bearish
Short: Trend state = bearish AND previous trend state = bullish
Long: Expansion score > positive threshold
Short: Expansion score < negative threshold
Long: Expansion score > positive threshold AND previous expansion score <= positive threshold
Short: Expansion score < negative threshold AND previous expansion score >= negative threshold