Calculation: vector candle = vector detection enabled AND selected volume >= SMA(selected volume, lookback) * volume threshold percentage / 100 AND high - low >= SMA(high - low, same lookback) * spread multiplier
Long: vector candle AND close > open
Short: vector candle AND close <= open
Calculation: candle range = high - low
Calculation: vector candle = vector detection enabled AND volume of the selected source >= SMA(volume of the selected source, lookback period) * (volume threshold percentage / 100) AND candle range >= SMA(candle range, lookback period) * range multiplier