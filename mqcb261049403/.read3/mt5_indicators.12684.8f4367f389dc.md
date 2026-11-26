Calculation: 3-line-break direction(high, low, lookback) = up if high > Highest(high[1], lookback) or (3-line-break direction[1] is up AND low >= Lowest(low[1], lookback)); otherwise down; initially down
Long: 3-line-break direction(high, low, chart lookback) is up
Short: 3-line-break direction(high, low, chart lookback) is down
Long: 3-line-break direction(high, low, T1 lookback) on T1 bars, sampled from the T1 bar containing the chart bar's datetime, is up; use the forming T1 bar when applicable
Short: 3-line-break direction(high, low, T1 lookback) on T1 bars, sampled from the T1 bar containing the chart bar's datetime, is down; use the forming T1 bar when applicable