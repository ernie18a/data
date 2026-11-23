Calculation: ORB high = highest high of the bars within the most recent ORB session
Calculation: ORB low = lowest low of the bars within the most recent ORB session
Calculation: ORB locked = the most recent ORB session has ended
Calculation: new ORB session = bar is the first bar within an ORB session
Calculation: ORB long state = (ORB locked AND close > ORB high) OR (ORB long state[1] AND NOT new ORB session AND NOT (ORB locked AND close < ORB low))
Calculation: ORB short state = (ORB locked AND close < ORB low) OR (ORB short state[1] AND NOT new ORB session AND NOT (ORB locked AND close > ORB high))
Long: ORB long state = true
Short: ORB short state = true
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback)
Long: low > high[2] AND low - high[2] >= minimum gap
Short: high < low[2] AND low[2] - high >= minimum gap
Exit: long, bars since the last bullish FVG formed > maximum FVG lifetime
Exit: short, bars since the last bearish FVG formed > maximum FVG lifetime
Long: pivot high(volume, pivot length, pivot length) is confirmed AND close[pivot length] > open[pivot length]
Short: pivot high(volume, pivot length, pivot length) is confirmed AND close[pivot length] <= open[pivot length]
Exit: long, low < low of the pivot bar of any bullish order block not yet invalidated
Exit: short, high > high of the pivot bar of any bearish order block not yet invalidated
Calculation: tested level = close[k], for k from 1 to level lookback, formed at the first bar where at least minimum tests of the closes at bars k - level window through k + level window (including k) are within test proximity of close[k] and no tested level still held is within test proximity of close[k]
Long: for some tested level, bars since it formed <= level expiry AND close > tested level
Short: for some tested level, bars since it formed <= level expiry AND close <= tested level