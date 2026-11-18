Calculation: candle range = high - low
Calculation: vector candle = vector detection enabled AND volume of the selected source >= SMA(volume of the selected source, lookback period) * (volume threshold percentage / 100) AND candle range >= SMA(candle range, lookback period) * range multiplier
Long: vector candle AND close > open
Short: vector candle AND close <= open