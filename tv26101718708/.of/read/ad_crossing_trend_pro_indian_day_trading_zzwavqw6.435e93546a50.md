Calculation: A/D flow = 0 when high = low; otherwise ((2 × close − low − high) / (high − low)) × volume
Calculation: Smoothed A/D = EMA(A/D flow, shorter lookback) when smoothing is enabled; otherwise A/D flow
Calculation: Final A/D = rolling sum of Smoothed A/D, optionally divided by the rolling window length
Calculation: Fast A/D trend = EMA(Final A/D, shorter lookback)
Calculation: Slow A/D trend = EMA(Final A/D, longer lookback)
Calculation: Trend power = absolute difference between Fast A/D trend and Slow A/D trend
Calculation: Average trend power = SMA(Trend power, lookback)
Long: Fast A/D trend ≥ Slow A/D trend OR (Fast A/D trend crosses above Slow A/D trend AND Trend power > Average trend power × multiplier) OR (Fast A/D trend > Slow A/D trend AND Trend power > Average trend power × multiplier)
Short: Fast A/D trend < Slow A/D trend OR (Fast A/D trend crosses below Slow A/D trend AND Trend power > Average trend power × multiplier) OR (Fast A/D trend < Slow A/D trend AND Trend power > Average trend power × multiplier)