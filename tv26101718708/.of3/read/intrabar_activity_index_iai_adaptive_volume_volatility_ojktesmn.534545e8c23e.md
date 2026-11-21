Calculation: ChartRatio = min(floor(duration(T1) / duration(chart)), bar cap)
Calculation: SubBarRange = Sum(TR of bars of the shorter of T2 and chart within the current chart bar) if any such bar exists, else ATR(floor(duration(T1) / duration(T2)))
Calculation: VolumeRank = PercentRank(Sum(volume, ChartRatio), min(lookback * ChartRatio, bar cap)) if chart shorter than T1, else PercentRank(volume, lookback)
Calculation: RangeRank = PercentRank(Sum(TR, ChartRatio), min(lookback * ChartRatio, bar cap)) if chart shorter than T1, else PercentRank(SubBarRange, lookback)
Calculation: ReferenceOpen = open[ChartRatio] if chart shorter than T1, else open
Long: VolumeRank > volume threshold AND RangeRank > volatility threshold AND ReferenceOpen < close
Short: VolumeRank > volume threshold AND RangeRank > volatility threshold AND ReferenceOpen >= close