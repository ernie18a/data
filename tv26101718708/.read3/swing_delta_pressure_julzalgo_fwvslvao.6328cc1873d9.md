Calculation: Direction = 1 if BarsSince(high = Highest(high, N)) < BarsSince(low = Lowest(low, N)) else -1
Calculation: LongStop = (IF StopType = ATR THEN entry price - M * ATR(K) ELSE low[BarsSince(low = Lowest(low, N))]) at entry bar
Calculation: ShortStop = (IF StopType = ATR THEN entry price + M * ATR(K) ELSE high[BarsSince(high = Highest(high, N))]) at entry bar
Long: Direction crosses above 0
Short: Direction crosses below 0
Exit: long, low <= LongStop OR high >= entry price + RR * abs(entry price - LongStop)
Exit: short, high >= ShortStop OR low <= entry price - RR * abs(entry price - ShortStop)