Calculation: LowerWick(bar) = (min(open, close) - low) / (high - low)
Calculation: UpperWick(bar) = (high - max(open, close)) / (high - low)
Calculation: Midpoint(bar) = (high + low) / 2
Long: LowerWick(T1, last completed bar) >= wick threshold
Short: UpperWick(T1, last completed bar) >= wick threshold
Long: low(T1, last completed bar) > high(T1, last completed bar)[2] AND (low(T1, last completed bar) - high(T1, last completed bar)[2]) / SMA(high - low, lookback, T1, last completed bar) >= gap threshold
Short: high(T1, last completed bar) < low(T1, last completed bar)[2] AND (low(T1, last completed bar)[2] - high(T1, last completed bar)) / SMA(high - low, lookback, T1, last completed bar) >= gap threshold
Exit: Long, close < low(T1, last completed bar)
Exit: Long, high >= Midpoint(T1, forming bar)
Exit: Long, high >= high(T1, last completed bar)
Exit: Short, close > high(T1, last completed bar)
Exit: Short, low <= Midpoint(T1, forming bar)
Exit: Short, low <= low(T1, last completed bar)