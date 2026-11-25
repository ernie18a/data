Long: price >= high[1] + OHLC shift AND (no long position OR high[1] + OHLC shift > highest long entry price + position shift)
Short: price <= low[1] - OHLC shift AND (no short position OR low[1] - OHLC shift < lowest short entry price - position shift)
Calculation: managed net profit = SUM(open-position profit + swap + commission)
Exit: long, managed net profit > profit threshold
Exit: short, managed net profit > profit threshold