Calculation: volume-range product = selected volume * (high - low)
Calculation: maximum volume-range product = MAX(volume-range product, lookback)
Long: volume-range product = maximum volume-range product AND close > (high + low) / 2
Short: volume-range product = maximum volume-range product AND close <= (high + low) / 2