Calculation: Grid distance = rounded-to-integer range in pips between the highest high and lowest low over the lookback of completed chart bars; use the default grid-distance parameter if the rounded value is ≤ 0
Calculation: Average entry price = sum(open price × position volume) / sum(position volume) across open strategy positions
Long: Flat AND close[2] < close[1] AND RSI(close, lookback, T2, last completed bar sampled on chart bars) < RSI upper-threshold parameter
Short: Flat AND close[2] > close[1] AND RSI(close, lookback, T2, last completed bar sampled on chart bars) > RSI lower-threshold parameter
Long: Position side is long AND open-position count ≤ maximum-trades parameter AND low ≤ last long entry price − grid distance
Short: Position side is short AND open-position count ≤ maximum-trades parameter AND high ≥ last short entry price + grid distance
Exit: Long, CCI(close, lookback, T1, still-forming bar sampled on chart bars) < −CCI threshold parameter
Exit: Short, CCI(close, lookback, T1, still-forming bar sampled on chart bars) > CCI threshold parameter
Exit: Long, high > average entry price + take-profit distance parameter
Exit: Short, low < average entry price − take-profit distance parameter