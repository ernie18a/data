Calculation: Range-weighted volume = volume * (high - low)
Long: close > open AND (volume >= average-volume threshold * SMA(volume[1], lookback) OR Range-weighted volume >= Highest(Range-weighted volume[1], lookback))
Short: close <= open AND (volume >= average-volume threshold * SMA(volume[1], lookback) OR Range-weighted volume >= Highest(Range-weighted volume[1], lookback))