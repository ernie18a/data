Calculation: Delta = volume * (2 * close - high - low) / (high - low) if high > low, else 0
Calculation: BuyPct = 100 * (close - low) / (high - low) if volume > 0 and high > low, else 50
Calculation: AvgDelta = SMA(Delta, delta average length)
Calculation: AvgVolume = SMA(volume, volume average length)
Calculation: CVD = cumulative sum of Delta from the first bar through the current bar
Calculation: CVDEMA = EMA(CVD, CVD average length)
Calculation: LastPivotHigh(x) = most recent non-NA value of PivotHigh(x, swing lookback, swing lookback) through the current bar
Calculation: LastPivotLow(x) = most recent non-NA value of PivotLow(x, swing lookback, swing lookback) through the current bar
Long: Delta >= 0
Short: Delta < 0
Long: BuyPct >= imbalance threshold
Short: 100 - BuyPct >= imbalance threshold
Long: Delta < -ABS(AvgDelta) AND close >= close[1]
Short: Delta > ABS(AvgDelta) AND close <= close[1]
Long: volume >= AvgVolume * large-volume multiplier AND Delta >= 0
Short: volume >= AvgVolume * large-volume multiplier AND Delta < 0
Long: CVD crosses above CVDEMA
Short: CVD crosses below CVDEMA
Long: CVD > CVDEMA
Short: CVD <= CVDEMA
Long: CVD >= 0
Short: CVD < 0
Long: PivotLow(low, swing lookback, swing lookback) < LastPivotLow(low)[2 * swing lookback] AND PivotLow(correlated low, swing lookback, swing lookback) > LastPivotLow(correlated low)[1]
Short: PivotHigh(high, swing lookback, swing lookback) > LastPivotHigh(high)[2 * swing lookback] AND PivotHigh(correlated high, swing lookback, swing lookback) < LastPivotHigh(correlated high)[1]