Calculation: High Low Logic Index = EMA(if (advancing issues + declining issues) != 0 then min(new 52-week highs, new 52-week lows) / (advancing issues + declining issues) * 100 else 0, smoothing lookback), calculated on chart bars using T1 close values (last completed T1 bar historically; still-forming T1 bar in real time)
Long: High Low Logic Index <= bullish threshold
Long: High Low Logic Index crosses below bullish threshold
Short: High Low Logic Index >= bearish threshold
Short: High Low Logic Index crosses above bearish threshold
Long: High Low Logic Index(T1, EMA length) <= bullish threshold
Short: High Low Logic Index(T1, EMA length) >= bearish threshold
Long: High Low Logic Index(T1, EMA length) crosses below bullish threshold
Short: High Low Logic Index(T1, EMA length) crosses above bearish threshold