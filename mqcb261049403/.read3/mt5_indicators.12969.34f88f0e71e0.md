Calculation: range per volume = (high - low) / selected volume, or 1 if the result is 0
Calculation: swing = ((high - low) + abs(open - close)) / (2 * range per volume)
Calculation: bullish pressure = swing + (open > close ? (open - close) / range per volume : 0)
Calculation: bearish pressure = swing + (open < close ? (close - open) / range per volume : 0)
Calculation: smoothed bullish pressure = selected smoothing method(bullish pressure, lookback, phase)
Calculation: smoothed bearish pressure = selected smoothing method(bearish pressure, lookback, phase)
Long: smoothed bearish pressure > smoothed bullish pressure on chart bars, OR the same comparison on the still-forming T1 bar, calculated on T1 bars, sampled on its first chart bar and held across chart bars
Short: smoothed bullish pressure > smoothed bearish pressure on chart bars, OR the same comparison on the still-forming T1 bar, calculated on T1 bars, sampled on its first chart bar and held across chart bars