Calculation: ZScore(source, lookback) = (source − SMA(source, lookback)) / population stdev(source, lookback), or 0 when stdev is 0
Calculation: Liquidity Void Oscillator = ZScore(log(close / close[1]), return lookback) × (1 when volume > 0 AND SMA(volume, volume baseline lookback) > 0 AND ZScore(log(volume) − log(SMA(volume, volume baseline lookback)), volume shock lookback) ≤ low-volume threshold; otherwise non-low-volume weight)
Long: Liquidity Void Oscillator crosses below lower threshold
Short: Liquidity Void Oscillator crosses above upper threshold