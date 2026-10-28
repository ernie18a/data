Calculation: Daily cumulative volume = sum of the current day's intraday volume from the first bar through the current bar
Calculation: Volume benchmark = average daily volume over a longer lookback, using only completed daily bars
Calculation: Trailing stop = highest value so far during the position of (bar high − ATR × stop multiplier)
Calculation: Profit target = entry price + ATR × target multiplier, using ATR on the first bar of the position
Long: Position is flat AND bar high >= current day's open × (1 + configured percentage threshold) AND daily cumulative volume >= volume benchmark AND daily market-index close > its moving average AND MFI > its midpoint AND time is at or before the configured intraday cutoff
Exit: Long, bar close < trailing stop OR bar close >= profit target