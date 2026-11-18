Calculation: Bullish CRT(T) = close[2] > open[2] AND low[1] < low[2] AND close[1] > open[2] AND close > high[2]; evaluate on chart bars using T OHLC values mapped with lookahead_off; [n] counts chart bars ago; the mapped T value is the last completed bar historically and may be the still-forming bar in realtime
Calculation: Bearish CRT(T) = close[2] < open[2] AND high[1] > high[2] AND close[1] < open[2] AND close < low[2]; evaluate on chart bars using T OHLC values mapped with lookahead_off; [n] counts chart bars ago; the mapped T value is the last completed bar historically and may be the still-forming bar in realtime
Long: Bullish CRT(T1) AND NOT Bullish CRT(T1)[1]
Long: Bullish CRT(T2) AND NOT Bullish CRT(T2)[1]
Short: Bearish CRT(T1) AND NOT Bearish CRT(T1)[1]
Short: Bearish CRT(T2) AND NOT Bearish CRT(T2)[1]