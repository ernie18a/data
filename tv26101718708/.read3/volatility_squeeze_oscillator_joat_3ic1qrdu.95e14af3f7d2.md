Calculation: SqueezeValue = EMA((EMA(EMA(TR, shorter lookback), longer lookback) - EMA(TR, shorter lookback)) / EMA(high - low, longer lookback), smoothing lookback)
Calculation: SqueezeSignal = EMA(SqueezeValue, signal lookback)
Calculation: DeltaBias = (SMA(CLV, delta lookback) - lowest(SMA(CLV, delta lookback), normalization lookback)) / (highest(SMA(CLV, delta lookback), normalization lookback) - lowest(SMA(CLV, delta lookback), normalization lookback))
Long: SqueezeValue crosses below SqueezeSignal AND RSI(volume, volume RSI lookback) > volume threshold AND DeltaBias > bullish threshold
Short: SqueezeValue crosses below SqueezeSignal AND RSI(volume, volume RSI lookback) > volume threshold AND DeltaBias < bearish threshold