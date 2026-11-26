Calculation: Trend = SMA(close, fast lookback) > SMA(close, medium lookback) AND SMA(close, medium lookback) > SMA(close, slow lookback) AND close > SMA(close, slow lookback), where fast lookback < medium lookback < slow lookback
Calculation: Zone = Trend AND low <= SMA(close, medium lookback) + ATR(ATR lookback) * zone tolerance AND close >= SMA(close, slow lookback) - ATR(ATR lookback) * zone tolerance
Calculation: VolumeConfirm = volume filter off OR volume > SMA(volume, volume lookback)
Calculation: Pivot = (high + low + close) / 3 of the last completed T1 bar, taken on chart bars
Calculation: Range = high - low of the last completed T1 bar, taken on chart bars
Calculation: Target_k = Pivot + Range * multiplier_k for k = 1, 2, 3, where multiplier_1 < multiplier_2 < multiplier_3
Calculation: Stop = MIN(low, SMA(close, slow lookback)) - ATR(ATR lookback) * stop multiplier
Calculation: RRPass = R/R filter off OR (close > Stop AND (close - Stop) / close * 100 >= minimum risk percent AND (Target_1 - close) / (close - Stop) >= minimum R/R)
Long: Zone AND close[2] < open[2] AND ABS(close[1] - open[1]) < ABS(close[2] - open[2]) * morning star body ratio AND close > open AND close > (open[2] + close[2]) / 2 AND VolumeConfirm AND RRPass
Long: Zone AND close > open AND close[1] < open[1] AND close > open[1] AND open <= close[1] AND VolumeConfirm AND RRPass
Long: Zone AND high < high[1] AND low > low[1] AND close > open AND close[1] < open[1] AND VolumeConfirm AND RRPass
Long: Zone AND high - low > 0 AND MIN(open, close) - low > pin wick ratio * ABS(close - open) AND high - MAX(open, close) <= pin tail ratio * (high - low) AND VolumeConfirm AND RRPass
Long: Zone AND high - low > 0 AND ABS(close - open) <= doji body ratio * (high - low) AND VolumeConfirm AND RRPass
Exit: long, NOT Trend
Exit: long, high >= Target_1
Exit: long, high >= Target_2
Exit: long, high >= Target_3
Calculation: Body(n) = |close[n] − open[n]|
Calculation: Range = high − low
Calculation: Stop = min(low, SMA(close, slow period)) − stop multiplier × ATR(ATR period)
Calculation: Target(r) = (previous T1 high + previous T1 low + previous T1 close) / 3 + r × (previous T1 high − previous T1 low)
Long: SMA(close, fast period) > SMA(close, medium period) AND SMA(close, medium period) > SMA(close, slow period) AND close > SMA(close, slow period) AND low ≤ SMA(close, medium period) + ATR(ATR period) × pullback tolerance AND close ≥ SMA(close, slow period) − ATR(ATR period) × pullback tolerance AND (volume filter disabled OR volume > SMA(volume, volume period)) AND ((morning star enabled AND close[2] < open[2] AND Body(1) < star body ratio × Body(2) AND close > open AND close > (open[2] + close[2]) / 2) OR (engulfing enabled AND close > open AND close[1] < open[1] AND close > open[1] AND open ≤ close[1]) OR (harami enabled AND high < high[1] AND low > low[1] AND close > open AND close[1] < open[1]) OR (pin bar enabled AND min(open, close) − low > Body(0) × pin wick multiple AND high − max(open, close) ≤ Range × pin upper wick ratio) OR (doji enabled AND Range > 0 AND Body(0) ≤ Range × doji body ratio)) AND (R/R filter disabled OR (close > Stop AND (close − Stop) / close × 100 ≥ minimum risk percent AND (Target(first target ratio) − close) / (close − Stop) ≥ minimum R/R))
Exit: long, close ≤ SMA(close, slow period) OR SMA(close, fast period) ≤ SMA(close, medium period) OR SMA(close, medium period) ≤ SMA(close, slow period)
Exit: long, close ≥ Target(first target ratio)
Exit: long, close ≥ Target(second target ratio)
Exit: long, close ≥ Target(third target ratio)