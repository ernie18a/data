Calculation: Prior T1 SSL Channel direction = previous T1 bar's state, where state is bullish when T1 close > WMA(T1 high, confirmation-period parameter), bearish when T1 close < WMA(T1 low, confirmation-period parameter), otherwise its previous state
Long: WMA(chart close, short-period parameter) crosses above WMA(chart close, long-period parameter) AND prior T1 SSL Channel direction is bullish
Short: WMA(chart close, short-period parameter) crosses below WMA(chart close, long-period parameter) AND prior T1 SSL Channel direction is bearish
Exit: long, prior T1 SSL Channel direction is bearish
Exit: short, prior T1 SSL Channel direction is bullish