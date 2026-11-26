Calculation: RangeHigh = Highest(high, lookback)[1]
Calculation: RangeLow = Lowest(low, lookback)[1]
Long: low[delay] < RangeLow[delay] AND close > RangeLow AND high[delay] <= RangeHigh[delay]
Short: high[delay] > RangeHigh[delay] AND close < RangeHigh
Exit: long, high >= entry price + target multiple * ATR(atr length) at entry bar OR low <= low[delay] at entry bar - stop multiple * ATR(atr length) at entry bar
Exit: short, low <= entry price - target multiple * ATR(atr length) at entry bar OR high >= high[delay] at entry bar + stop multiple * ATR(atr length) at entry bar