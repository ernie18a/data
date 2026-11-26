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
Calculation: Pivot low(x, P1) = x P1 bars ago, if it is the lowest x among the 2*P1+1 bars ending with the current bar; otherwise none
Calculation: Pivot high(x, P1) = x P1 bars ago, if it is the highest x among the 2*P1+1 bars ending with the current bar; otherwise none
Calculation: Last pivot low(x, P1, k) = the most recent defined Pivot low(x, P1) evaluated on any bar at or before k bars ago; otherwise none
Calculation: Last pivot high(x, P1, k) = the most recent defined Pivot high(x, P1) evaluated on any bar at or before k bars ago; otherwise none
Long: Pivot low(traded low, P1) is defined AND Pivot low(correlated low, P1) is defined AND Pivot low(traded low, P1) < Last pivot low(traded low, P1, 2*P1) AND Pivot low(correlated low, P1) > Last pivot low(correlated low, P1, 1)
Short: Pivot high(traded high, P1) is defined AND Pivot high(correlated high, P1) is defined AND Pivot high(traded high, P1) > Last pivot high(traded high, P1, 2*P1) AND Pivot high(correlated high, P1) < Last pivot high(correlated high, P1, 1)