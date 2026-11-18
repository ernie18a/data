Calculation: Short-term average = selected SMA, EMA, WMA, Hull MA, VWMA, RMA, TEMA, or Tilson T3 of close using the first lookback parameter and, for Tilson T3, the first factor parameter, calculated on the selected timeframe (chart timeframe or T1) and sampled onto chart bars; on T1 use its still-forming bar live and its last completed bar historically.
Calculation: Long-term average = selected SMA, EMA, WMA, Hull MA, VWMA, RMA, TEMA, or Tilson T3 of close using the second lookback parameter and, for Tilson T3, the second factor parameter; TEMA uses the first lookback parameter. Calculate on the selected timeframe (chart timeframe or T1) and sample onto chart bars; on T1 use its still-forming bar live and its last completed bar historically.
Long: Short-term average >= short-term average[smoothing parameter bars ago on chart timeframe]
Short: Short-term average < short-term average[smoothing parameter bars ago on chart timeframe]
Long: chart open < short-term average AND chart close > short-term average
Short: chart open > short-term average AND chart close < short-term average
Long: chart open < long-term average AND chart close > long-term average
Short: chart open > long-term average AND chart close < long-term average
Long: Short-term average crosses above long-term average on chart bars using their sampled values
Short: Short-term average crosses below long-term average on chart bars using their sampled values