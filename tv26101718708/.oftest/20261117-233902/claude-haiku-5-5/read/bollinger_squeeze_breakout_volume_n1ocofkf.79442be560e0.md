Calculation: BB = BollingerBands(close, bb length, bb multiplier)
Calculation: BandWidth = (upper band of BB - lower band of BB) / middle band of BB
Calculation: SqueezeState = BandWidth < SMA(BandWidth, squeeze lookback) * squeeze threshold
Calculation: VolumeAboveAverage = volume > SMA(volume, volume lookback)
Calculation: AverageTrueRange = ATR(atr length)
Long: SqueezeState[1] AND close crosses above upper band of BB AND VolumeAboveAverage AND position side is flat
Short: SqueezeState[1] AND close crosses below lower band of BB AND VolumeAboveAverage AND position side is flat
Exit: Long, low <= entry price - AverageTrueRange at entry bar * stop multiplier OR high >= entry price + AverageTrueRange at entry bar * target multiplier
Exit: Short, high >= entry price + AverageTrueRange at entry bar * stop multiplier OR low <= entry price - AverageTrueRange at entry bar * target multiplier