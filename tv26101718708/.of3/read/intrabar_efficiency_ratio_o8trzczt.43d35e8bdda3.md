Calculation: IntrabarEfficiency = (close - close[1]) / (sum of abs(T1 close - previous T1 close) over all T1 bars within the chart bar, including the still-forming T1 bar) * W, computed on chart bars, where W = PercentRank(abs(close - close[1]), weight rank lookback) / 100 if weighting enabled, else 1; 0 when undefined
Calculation: MovingAverage(source, length, MA type) = SMA, EMA, RMA, WMA, VWMA, ALMA(source, length, ALMA offset, ALMA sigma), or HMA of source over length, selected by MA type
Calculation: Rank(source) = PercentRank(source, rank lookback)
Long: MovingAverage(IntrabarEfficiency, shorter length, MA type) > MovingAverage(IntrabarEfficiency, longer length, MA type)
Short: MovingAverage(IntrabarEfficiency, shorter length, MA type) <= MovingAverage(IntrabarEfficiency, longer length, MA type)
Long: Rank(MovingAverage(IntrabarEfficiency, longer length, MA type)) > rank midpoint
Short: Rank(MovingAverage(IntrabarEfficiency, longer length, MA type)) <= rank midpoint
Long: Rank(MovingAverage(IntrabarEfficiency, medium length, MA type)) > rank midpoint
Short: Rank(MovingAverage(IntrabarEfficiency, medium length, MA type)) <= rank midpoint
Long: Rank(MovingAverage(IntrabarEfficiency, shorter length, MA type)) > rank midpoint
Short: Rank(MovingAverage(IntrabarEfficiency, shorter length, MA type)) <= rank midpoint