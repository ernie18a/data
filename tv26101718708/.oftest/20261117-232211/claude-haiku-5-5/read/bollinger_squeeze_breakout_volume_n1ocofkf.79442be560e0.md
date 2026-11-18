Calculation: Width = (BBUpper(close, BB lookback, BB multiplier) - BBLower(close, BB lookback, BB multiplier)) / SMA(close, BB lookback)
Calculation: MeanWidth = SMA(Width, squeeze lookback)
Calculation: Squeeze = Width < MeanWidth * squeeze threshold
Calculation: VolumeAboveAvg = volume > SMA(volume, volume lookback)
Calculation: Atr = ATR(high, low, close, ATR length)
Long: Squeeze[1] AND close crosses above BBUpper(close, BB lookback, BB multiplier) AND VolumeAboveAvg AND position side is flat
Short: Squeeze[1] AND close crosses below BBLower(close, BB lookback, BB multiplier) AND VolumeAboveAvg AND position side is flat
Exit: long, low <= entry price - Atr at entry bar * stop multiplier OR high >= entry price + Atr at entry bar * target multiplier
Exit: short, high >= entry price + Atr at entry bar * stop multiplier OR low <= entry price - Atr at entry bar * target multiplier