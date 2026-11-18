Calculation: volume-range product = volume * (high - low)
Long: close > open AND (volume >= volume multiplier * SMA(volume[1], volume lookback) OR volume-range product >= highest(volume-range product[1], volume-range lookback))
Short: close <= open AND (volume >= volume multiplier * SMA(volume[1], volume lookback) OR volume-range product >= highest(volume-range product[1], volume-range lookback))