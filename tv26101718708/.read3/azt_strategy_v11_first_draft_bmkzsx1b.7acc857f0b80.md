Calculation: Structure(bars) = 1 if close > most recent confirmed PivotHigh(high, pivot strength, pivot strength), -1 if close < most recent confirmed PivotLow(low, pivot strength, pivot strength), otherwise Structure(bars)[1]
Calculation: HigherBullCount = number of Structure(T3 bars, last completed bar), Structure(T4 bars, last completed bar), Structure(T5 bars, last completed bar) that equal 1
Calculation: HigherBearCount = number of Structure(T3 bars, last completed bar), Structure(T4 bars, last completed bar), Structure(T5 bars, last completed bar) that equal -1
Calculation: VolumeOK(bars) = volume > SMA(volume, volume lookback)
Calculation: ClusterAbove(bars) = |EMA(close, cluster lookback) - VWAP| <= tolerance multiple * ATR(ATR lookback) AND close > max(EMA(close, cluster lookback), VWAP)
Calculation: ClusterBelow(bars) = |EMA(close, cluster lookback) - VWAP| <= tolerance multiple * ATR(ATR lookback) AND close < min(EMA(close, cluster lookback), VWAP)
Calculation: CrossUp(bars) = crossover(EMA(close, shorter lookback), EMA(close, longer lookback))
Calculation: CrossDown(bars) = crossunder(EMA(close, shorter lookback), EMA(close, longer lookback))
Calculation: BullCandle(bars) = ((close[1] > open[1] AND close[2] < open[2] AND close[1] >= open[2] AND open[1] <= close[2]) OR (|close[1] - open[1]| <= small-body max * (high[1] - low[1]) AND min(open[1], close[1]) - low[1] >= long-wick min * (high[1] - low[1]) AND high[1] - max(open[1], close[1]) <= |close[1] - open[1]|) OR (|close[1] - open[1]| <= doji max * (high[1] - low[1]) AND min(open[1], close[1]) - low[1] >= long-wick min * (high[1] - low[1]))) AND close > high[1]
Calculation: BearCandle(bars) = ((close[1] < open[1] AND close[2] > open[2] AND close[1] <= open[2] AND open[1] >= close[2]) OR (|close[1] - open[1]| <= small-body max * (high[1] - low[1]) AND high[1] - max(open[1], close[1]) >= long-wick min * (high[1] - low[1]) AND min(open[1], close[1]) - low[1] <= |close[1] - open[1]|) OR (|close[1] - open[1]| <= doji max * (high[1] - low[1]) AND high[1] - max(open[1], close[1]) >= long-wick min * (high[1] - low[1]))) AND close < low[1]
Calculation: Trending(bars) = (close crosses above most recent confirmed PivotHigh or close crosses below most recent confirmed PivotLow, at some bar within the last regime window bars) AND |most recent confirmed PivotHigh - most recent confirmed PivotLow| >= chop multiple * ATR(ATR lookback)
Calculation: ChartLongBase = Structure(chart bars) = 1 AND Structure(T1 bars, last completed bar) = 1 AND Structure(T2 bars, last completed bar) = 1 AND HigherBullCount >= 2 AND barssince(CrossUp(T1 bars, last completed bar)) <= recent window in chart bars AND EMA(close, shorter lookback, T1 bars, last completed bar) > EMA(close, longer lookback, T1 bars, last completed bar) AND ClusterAbove(chart bars) AND BullCandle(chart bars) AND Trending(chart bars)
Calculation: ChartShortBase = Structure(chart bars) = -1 AND Structure(T1 bars, last completed bar) = -1 AND Structure(T2 bars, last completed bar) = -1 AND HigherBearCount >= 2 AND barssince(CrossDown(T1 bars, last completed bar)) <= recent window in chart bars AND EMA(close, shorter lookback, T1 bars, last completed bar) <= EMA(close, longer lookback, T1 bars, last completed bar) AND ClusterBelow(chart bars) AND BearCandle(chart bars) AND Trending(chart bars)
Calculation: MirrorLongBase = Structure(T1 bars, last completed bar) = 1 AND Structure(T2 bars, last completed bar) = 1 AND HigherBullCount >= 2 AND barssince(CrossUp(T1 bars)) <= recent window in T1 bars, evaluated on last completed T1 bar AND EMA(close, shorter lookback, T1 bars, last completed bar) > EMA(close, longer lookback, T1 bars, last completed bar) AND ClusterAbove(T1 bars, last completed bar) AND BullCandle(T1 bars, last completed bar) AND Trending(T1 bars, last completed bar)
Calculation: MirrorShortBase = Structure(T1 bars, last completed bar) = -1 AND Structure(T2 bars, last completed bar) = -1 AND HigherBearCount >= 2 AND barssince(CrossDown(T1 bars)) <= recent window in T1 bars, evaluated on last completed T1 bar AND EMA(close, shorter lookback, T1 bars, last completed bar) <= EMA(close, longer lookback, T1 bars, last completed bar) AND ClusterBelow(T1 bars, last completed bar) AND BearCandle(T1 bars, last completed bar) AND Trending(T1 bars, last completed bar)
Calculation: ChartLongTier = 3 if ChartLongBase AND HigherBullCount = 3 AND VolumeOK(chart bars) AND ClusterAbove(T1 bars, last completed bar) AND ClusterAbove(T2 bars, last completed bar); else 2 if ChartLongBase AND HigherBullCount = 3 AND VolumeOK(chart bars); else 1 if ChartLongBase; else 0
Calculation: ChartShortTier = 3 if ChartShortBase AND HigherBearCount = 3 AND VolumeOK(chart bars) AND ClusterBelow(T1 bars, last completed bar) AND ClusterBelow(T2 bars, last completed bar); else 2 if ChartShortBase AND HigherBearCount = 3 AND VolumeOK(chart bars); else 1 if ChartShortBase; else 0
Calculation: MirrorLongTier = 3 if MirrorLongBase AND HigherBullCount = 3 AND VolumeOK(T1 bars, last completed bar) AND ClusterAbove(T2 bars, last completed bar); else 2 if MirrorLongBase AND HigherBullCount = 3 AND VolumeOK(T1 bars, last completed bar); else 1 if MirrorLongBase; else 0
Calculation: MirrorShortTier = 3 if MirrorShortBase AND HigherBearCount = 3 AND VolumeOK(T1 bars, last completed bar) AND ClusterBelow(T2 bars, last completed bar); else 2 if MirrorShortBase AND HigherBearCount = 3 AND VolumeOK(T1 bars, last completed bar); else 1 if MirrorShortBase; else 0
Long: ChartLongTier >= minimum tier AND ChartLongTier[1] < minimum tier
Long: ChartLongTier >= minimum tier
Long: MirrorLongTier >= minimum tier
Long: MirrorLongTier >= minimum tier AND MirrorLongTier[1] < minimum tier
Long: CrossUp(T1 bars, last completed bar) AND NOT CrossUp(T1 bars, last completed bar)[1]
Long: EMA(close, cluster lookback) crosses VWAP AND close > max(EMA(close, cluster lookback), VWAP)
Long: close > max(EMA(close, cluster lookback), VWAP)
Long: Structure(chart bars) = 1
Long: Structure(T1 bars, last completed bar) = 1
Long: Structure(T2 bars, last completed bar) = 1
Long: Structure(T3 bars, last completed bar) = 1
Long: Structure(T4 bars, last completed bar) = 1
Long: Structure(T5 bars, last completed bar) = 1
Long: Structure(chart bars) = 1 AND Structure(T1 bars, last completed bar) = 1 AND Structure(T2 bars, last completed bar) = 1
Long: EMA(close, shorter lookback, T1 bars, last completed bar) > EMA(close, longer lookback, T1 bars, last completed bar)
Long: BullCandle(chart bars)
Long: ClusterAbove(chart bars)
Short: ChartShortTier >= minimum tier AND ChartShortTier[1] < minimum tier
Short: ChartShortTier >= minimum tier
Short: MirrorShortTier >= minimum tier
Short: MirrorShortTier >= minimum tier AND MirrorShortTier[1] < minimum tier
Short: CrossDown(T1 bars, last completed bar) AND NOT CrossDown(T1 bars, last completed bar)[1]
Short: EMA(close, cluster lookback) crosses VWAP AND close < min(EMA(close, cluster lookback), VWAP)
Short: close < min(EMA(close, cluster lookback), VWAP)
Short: Structure(chart bars) = -1
Short: Structure(T1 bars, last completed bar) = -1
Short: Structure(T2 bars, last completed bar) = -1
Short: Structure(T3 bars, last completed bar) = -1
Short: Structure(T4 bars, last completed bar) = -1
Short: Structure(T5 bars, last completed bar) = -1
Short: Structure(chart bars) = -1 AND Structure(T1 bars, last completed bar) = -1 AND Structure(T2 bars, last completed bar) = -1
Short: EMA(close, shorter lookback, T1 bars, last completed bar) <= EMA(close, longer lookback, T1 bars, last completed bar)
Short: BearCandle(chart bars)
Short: ClusterBelow(chart bars)