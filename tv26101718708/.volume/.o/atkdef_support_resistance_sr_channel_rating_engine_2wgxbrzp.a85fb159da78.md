Calculation: Adaptive pivot width = rounded(5 × ATR(14) / 50-bar SMA of true range), clamped to 3–10 bars; swing highs and lows require that many bars on each side and are confirmed after the right-side bars complete
Calculation: Historical power = min(20, min(10, swing price / ATR(14) at the swing × chart-timeframe multiplier) × min(5, volume at swing / 20-bar average volume at swing) × (1 if swing is within lookback range, otherwise 0.5))
Calculation: Attenuation = min(1, 0.6 × min(bars since swing / 50, 1) + 0.4 × min(100 × |current close − swing price| / swing price / 10, 1))
Calculation: Swirl = min(5, (sum over the latest 11 bars of (bar high − bar low) / the 14-bar average of that range, divided by 10) × current ATR(14) / ATR(14) at the swing)
Long: At a confirmed swing low, historical power ≥ power threshold
Short: At a confirmed swing high, historical power ≥ power threshold