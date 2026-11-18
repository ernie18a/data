Calculation: selling-volume spike ratio = volume / SMA(volume, lookback) when SMA(volume, lookback) > 0, otherwise 0
Short: close < open AND selling-volume spike ratio >= higher extreme-spike threshold
Short: close < open AND selling-volume spike ratio >= lower high-spike threshold AND selling-volume spike ratio < higher extreme-spike threshold