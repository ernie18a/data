Calculation: Heiken Ashi close = (open + high + low + close) / 4; Heiken Ashi open = first bar (open + close) / 2, otherwise the average of the previous bar’s Heiken Ashi open and close
Calculation: Estimated delta = volume × (close − open) / (high − low) when high > low, otherwise 0
Calculation: Smoothed delta = EMA of estimated delta
Calculation: Delta moving average = SMA of smoothed delta, using a longer lookback than the EMA
Calculation: Normalized delta gap = (smoothed delta − delta moving average) / highest value of the absolute delta gap over a lookback five times the delta moving average lookback; use 0 when that highest value is 0
Calculation: Momentum state = fading if smoothed delta’s sign opposes Heiken Ashi direction, or normalized delta gap is below −0.15 for a bullish Heiken Ashi candle or above 0.15 for a bearish one; otherwise strong if normalized delta gap is above 0.15 for a bullish candle or below −0.15 for a bearish one; otherwise moderate
Long: Heiken Ashi close >= Heiken Ashi open AND previous bar’s momentum state was fading AND current momentum state is strong OR smoothed delta > 0 AND previous bar’s smoothed delta <= 0
Short: Heiken Ashi close < Heiken Ashi open AND previous bar’s momentum state was fading AND current momentum state is strong OR smoothed delta < 0 AND previous bar’s smoothed delta >= 0