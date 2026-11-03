Calculation: Mean period high/low = the average of the highest high / lowest low in each of iPeriod consecutive periods on the calculation timeframe; include the current period if configured to use a partial period, otherwise use completed periods.
Calculation: Trend state = up when close > mean period high, down when close < mean period low, otherwise retain the previous bar's trend state.
Long: Trend state is up AND the previous bar's trend state was not up
Short: Trend state is down AND the previous bar's trend state was not down