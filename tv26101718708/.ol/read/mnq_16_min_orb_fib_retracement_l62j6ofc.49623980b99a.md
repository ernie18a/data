Calculation: Opening range high/low = maximum high/minimum low across the first eight chart bars beginning at 6:30 America/Los_Angeles; lock after the eighth bar.
Calculation: Opening range midpoint = (opening range high + opening range low) / 2.
Calculation: Daily bias = bullish if the first close after the opening range locks is >= the opening range midpoint; otherwise bearish. Bias stays fixed for the day.
Calculation: Range size = max(opening range high - opening range low, minimum price increment).
Calculation: Bullish 50%/61.8% levels = opening range high - range size × 0.5/0.618; bearish 50%/61.8% levels = opening range low + range size × 0.5/0.618.
Long: Daily bias is bullish AND a close on the current or an earlier bar since the range locked was < the bullish 61.8% level AND current close > the bullish 50% level AND local time is <= 10:00 America/Los_Angeles AND no signal has occurred that day.
Short: Daily bias is bearish AND a close on the current or an earlier bar since the range locked was > the bearish 61.8% level AND current close < the bearish 50% level AND local time is <= 10:00 America/Los_Angeles AND no signal has occurred that day.