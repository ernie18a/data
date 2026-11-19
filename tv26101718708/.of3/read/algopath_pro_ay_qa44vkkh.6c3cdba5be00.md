Calculation: Opening gap = current day's New York opening session chart-bar open - previous day's regular trading-hours closing session chart-bar open; detect session starts from the still-forming T1 session bars and compute on chart bars
Long: On the first chart bar where the T1 New York opening session is active, opening gap > 0
Short: On the first chart bar where the T1 New York opening session is active, opening gap <= 0
Calculation: Selected candle size = high - low when wick length is selected, otherwise absolute value of close - open
Long: close > open AND selected candle size > ATR(lookback) * multiplier
Short: close < open AND selected candle size > ATR(lookback) * multiplier