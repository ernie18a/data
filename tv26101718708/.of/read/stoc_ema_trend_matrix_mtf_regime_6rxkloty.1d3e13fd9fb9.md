Calculation: EMA(n) = exponential moving average of close with lookback n.
Calculation: Pair(fast, slow) = EMA(fast) on chart-timeframe bars vs EMA(slow) on chart-timeframe bars, with the fast lookback shorter than the slow lookback. It is bullish if fast EMA > slow EMA and bearish if fast EMA < slow EMA. Seven such pairs are evaluated at the same time, with overlapping lookbacks.
Calculation: Regime = on bars aggregated to a fixed timeframe, independent of the chart timeframe and taken from the bar still forming (not the last completed bar), take three EMAs of close with fast < middle < slow lookbacks. It is bullish if EMA_fast > EMA_middle > EMA_slow and bearish if EMA_fast < EMA_middle < EMA_slow. Otherwise it is neutral. Four regimes are used, on four increasing timeframes, and both the timeframe and the EMA lookbacks grow from the shortest regime to the longest.
Calculation: BullRegimes / BearRegimes = number of the four regimes that are bullish / bearish.
Long: BullRegimes >= 3 (all four regimes available)
Long: any single Regime is bullish
Long: any single Pair is bullish
Short: BearRegimes >= 3 (all four regimes available)
Short: any single Regime is bearish
Short: any single Pair is bearish