Calculation: Trend state = 1 when close > SMA(high, SSL lookback), -1 when close < SMA(low, SSL lookback), otherwise its previous value
Calculation: Smoothed open = EMA((open[1] + close[1]) / 2, open lookback)
Calculation: Smoothed high = EMA(max(high, close), high lookback)
Calculation: Bar midpoint = (high + low) / 2
Long: Trend state = 1 AND Trend state[1] = -1 AND Smoothed open > Smoothed open[1] AND EMA(close, MA lookback) < Bar midpoint AND Smoothed high < Bar midpoint AND flat
Exit: long, high >= entry price * (1 + take-profit percentage / 100)
Exit: long, close < EMA(close, MA lookback) AND percentage stop disabled
Exit: long, close < EMA(close, MA lookback) AND percentage stop enabled AND low <= entry price * (1 - stop percentage / 100)