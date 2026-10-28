Long: SMA(9) of close > its value on the previous bar
Short: SMA(9) of close < its value on the previous bar
Long: HLC3 >= EMA(34) and the previous bar's HLC3 < its EMA(34)
Short: HLC3 < EMA(34) and the previous bar's HLC3 >= its EMA(34)
Long: close crosses above SMA(9)
Short: close crosses below SMA(9)
Long: low > high from two bars earlier, previous close > that earlier high, and (low - that earlier high) / that earlier high > threshold
Short: high < low from two bars earlier, previous close < that earlier low, and (that earlier low - high) / high > threshold
Long: at a confirmed pivot low, price is lower than at the preceding pivot low and MACD-AS is higher than at the preceding pivot low
Short: at a confirmed pivot high, price is higher than at the preceding pivot high and MACD-AS is lower than at the preceding pivot high
Calculation: MACD-AS = (fast EMA of close - slow EMA of close) - EMA of that difference using the signal smoothing length