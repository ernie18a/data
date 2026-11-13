Calculation: swing structure state (computed on a fixed timeframe higher than the chart, using the bar still forming) = swing high/low are pivots confirmed by the same number of bars on the left and right; the state starts at 0; it becomes +1 when close crosses above the latest confirmed swing high (close > it AND previous close <= it); it becomes -1 when close crosses below the latest confirmed swing low (close < it AND previous close >= it); otherwise it keeps its previous value (the high-cross check comes first)
Long: on bars of a timeframe higher than the chart, with L = last completed bar and P = the bar before L: (L.low < P.low AND L.high <= P.high AND L.close < P.high AND L.close > P.low) OR L.close > P.high
Long: same condition as the previous Long line, applied to bars of a timeframe longer than the one used in the previous Long line
Long: swing structure state = +1 on timeframe A
Long: swing structure state = +1 on timeframe B, where B is shorter than A
Long: swing structure state = +1 on timeframe C, where C is shorter than B
Short: on bars of a timeframe higher than the chart, with L = last completed bar and P = the bar before L: (L.high > P.high AND L.close < P.high AND L.close > P.low) OR L.close < P.low
Short: same condition as the previous Short line, applied to bars of a timeframe longer than the one used in the previous Short line
Short: swing structure state = -1 on timeframe A
Short: swing structure state = -1 on timeframe B, where B is shorter than A
Short: swing structure state = -1 on timeframe C, where C is shorter than B