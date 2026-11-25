Calculation: support = Lowest(low, level lookback, T1 bars through the current forming bar; sampled on chart bars)
Calculation: resistance = Highest(high, level lookback, T1 bars through the current forming bar; sampled on chart bars)
Long: open of the current chart bar > EMA(open, maPeriod, chart bars through the current forming bar) AND ask price > resistance
Short: open of the current chart bar < EMA(open, maPeriod, chart bars through the current forming bar) AND bid price < support
Exit: long, bid price < support
Exit: short, ask price > resistance