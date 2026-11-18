Long: close > highest(high, structure lookback)[1]
Short: close < lowest(low, structure lookback)[1]
Long: close > highest(high, structure lookback)[1] AND close[1] < lowest(low, structure lookback)[2]
Short: close < lowest(low, structure lookback)[1] AND close[1] > highest(high, structure lookback)[2]
Long: low > high[2]
Short: high < low[2]
Long: low = lowest(low, structure lookback)
Short: high = highest(high, structure lookback)
Long: close > highest(high, structure lookback)[1] AND close > low(T1, bar still forming, sampled on chart bars) AND low > high[2]
Short: close < lowest(low, structure lookback)[1] AND close < high(T1, bar still forming, sampled on chart bars) AND high < low[2]