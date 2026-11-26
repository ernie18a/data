Calculation: VolumeDelta = up volume - down volume; by volume delta method, up volume is either volume * (close - low) / (high - low), using half volume when high = low, or volume when close >= open and zero otherwise; down volume is either volume - up volume or volume when close < open and zero otherwise, respectively
Long: low < lowest(low, divergence lookback)[1] AND VolumeDelta > lowest(VolumeDelta, divergence lookback)[1] AND VolumeDelta < 0
Short: high > highest(high, divergence lookback)[1] AND VolumeDelta < highest(VolumeDelta, divergence lookback)[1] AND VolumeDelta > 0
Long: VolumeDelta >= 0
Short: VolumeDelta < 0