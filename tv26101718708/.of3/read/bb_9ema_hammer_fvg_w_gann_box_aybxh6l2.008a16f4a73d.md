Calculation: CandleRange = ABS(high - low)
Calculation: Type2Up = high > high[1] AND low >= low[1]
Calculation: Type2Down = low < low[1] AND high <= high[1]
Calculation: UpGap = low - high[2]
Calculation: DownGap = low[2] - high
Calculation: UpBreakPrice = high if the high/low break switch is on, else close
Calculation: DownBreakPrice = low if the high/low break switch is on, else close
Calculation: LastPivotHigh = last non-NA value of PivotHigh(high, swing length, swing length)
Calculation: LastPivotLow = last non-NA value of PivotLow(low, swing length, swing length)
Calculation: HighUnbroken = (PivotHigh(high, swing length, swing length) is not NA OR HighUnbroken[1]) AND UpBreakPrice <= LastPivotHigh
Calculation: LowUnbroken = (PivotLow(low, swing length, swing length) is not NA OR LowUnbroken[1]) AND DownBreakPrice >= LastPivotLow
Long: high[confirm] - fib level * CandleRange[confirm] < MIN(open[confirm], close[confirm]) AND (close > open OR confirm = 0)
Short: low[confirm] + fib level * CandleRange[confirm] > MAX(open[confirm], close[confirm]) AND (close < open OR confirm = 0)
Long: Type2Down AND close > close[1]
Short: Type2Up AND close < close[1]
Long: Type2Up AND close >= close[1]
Short: Type2Down AND close <= close[1]
Long: UpGap > min FVG gap
Short: DownGap > min FVG gap
Long: datetime(T1, last completed bar) != datetime(T1, last completed bar)[1] AND UpGap(T1, last completed bar) > HTF min FVG gap
Short: datetime(T1, last completed bar) != datetime(T1, last completed bar)[1] AND DownGap(T1, last completed bar) > HTF min FVG gap
Long: HighUnbroken[1] AND UpBreakPrice > LastPivotHigh
Short: LowUnbroken[1] AND DownBreakPrice < LastPivotLow
Long: PivotHigh(high, swing length, swing length) >= LastPivotHigh[1]
Long: PivotLow(low, swing length, swing length) >= LastPivotLow[1]
Short: PivotHigh(high, swing length, swing length) is not NA AND NOT (PivotHigh(high, swing length, swing length) >= LastPivotHigh[1])
Short: PivotLow(low, swing length, swing length) is not NA AND NOT (PivotLow(low, swing length, swing length) >= LastPivotLow[1])