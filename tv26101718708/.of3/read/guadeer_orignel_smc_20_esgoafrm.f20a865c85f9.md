Calculation: Internal structure trend = bullish after close crosses above the latest unbroken confirmed PivotHigh(high, internal lookback, internal lookback) with at least two confirmed PivotLow(low, internal lookback, internal lookback) levels; bearish after close crosses below the latest unbroken confirmed PivotLow(low, internal lookback, internal lookback) with at least two confirmed PivotHigh(high, internal lookback, internal lookback) levels; otherwise retain the previous trend.
Calculation: Accumulation/distribution pattern = the selected shorter or longer sequence of consecutive alternating confirmed pivots, using the internal lookback; successive lows rise and successive highs fall, with a low-first sequence classified as accumulation and a high-first sequence as distribution.
Calculation: Selected gap condition = on chart bars sampling current T1 open, high, low, and close with lookahead off, use the selected method: standard FVG is current T1 low above T1 high at the gap-reference lag, or current T1 high below T1 low at that lag; volume imbalance is bullish when current T1 open > previous chart-sampled T1 close AND previous chart-sampled T1 high > current T1 low AND current T1 close > previous chart-sampled T1 close AND current T1 open > previous chart-sampled T1 open AND previous chart-sampled T1 high < min(current T1 close, current T1 open), and bearish when current T1 open < previous chart-sampled T1 close AND previous chart-sampled T1 low < current T1 high AND current T1 close < previous chart-sampled T1 close AND current T1 open < previous chart-sampled T1 open AND previous chart-sampled T1 low > max(current T1 close, current T1 open); opening gap is bullish when current T1 low > previous chart-sampled T1 high and bearish when current T1 high < previous chart-sampled T1 low; each method also requires a T1 timeframe change on the chart bar.
Long: close crosses above the latest unbroken confirmed PivotHigh(high, internal lookback, internal lookback) with at least two confirmed PivotLow(low, internal lookback, internal lookback) levels, on chart bars.
Short: close crosses below the latest unbroken confirmed PivotLow(low, internal lookback, internal lookback) with at least two confirmed PivotHigh(high, internal lookback, internal lookback) levels, on chart bars.
Long: close crosses above the latest unbroken confirmed PivotHigh(high, swing lookback, swing lookback) with at least two confirmed PivotLow(low, swing lookback, swing lookback) levels, on chart bars.
Short: close crosses below the latest unbroken confirmed PivotLow(low, swing lookback, swing lookback) with at least two confirmed PivotHigh(high, swing lookback, swing lookback) levels, on chart bars.
Long: internal structure trend is bullish and candle coloring is enabled.
Short: internal structure trend is bearish and candle coloring is enabled.
Long: internal structure trend computed on the current, still-forming T1 bars is bullish and the MTF dashboard is enabled.
Short: internal structure trend computed on the current, still-forming T1 bars is bearish and the MTF dashboard is enabled.
Long: internal structure trend computed on the current, still-forming T2 bars is bullish and the MTF dashboard is enabled.
Short: internal structure trend computed on the current, still-forming T2 bars is bearish and the MTF dashboard is enabled.
Long: internal structure trend computed on the current, still-forming T3 bars is bullish and the MTF dashboard is enabled.
Short: internal structure trend computed on the current, still-forming T3 bars is bearish and the MTF dashboard is enabled.
Long: internal structure trend computed on the current, still-forming T4 bars is bullish and the MTF dashboard is enabled.
Short: internal structure trend computed on the current, still-forming T4 bars is bearish and the MTF dashboard is enabled.
Long: a newly confirmed pivot low is less than ATR(ATR lookback) × threshold away from the preceding confirmed pivot low, on chart bars.
Short: a newly confirmed pivot high is less than ATR(ATR lookback) × threshold away from the preceding confirmed pivot high, on chart bars.
Long: accumulation/distribution detection is enabled and the selected accumulation/distribution pattern is accumulation.
Short: accumulation/distribution detection is enabled and the selected accumulation/distribution pattern is distribution.
Long: gap detection is enabled and the selected gap condition was bullish on the previous chart bar.
Short: gap detection is enabled and the selected gap condition was bearish on the previous chart bar.
Long: a swing structure break of either direction matches the selected order-block filter.
Long: on the last chart bar, low crosses below the upper boundary of the newest active bullish volumetric order block and that block type is enabled.
Short: on the last chart bar, high crosses above the lower boundary of the newest active bearish volumetric order block and that block type is enabled.