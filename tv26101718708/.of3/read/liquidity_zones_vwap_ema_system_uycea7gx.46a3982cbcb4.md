Calculation: bull state = close > VWAP(high, low, close, volume, reset at start of T1) AND close > EMA(close, short-term EMA length) AND close > EMA(close, medium-term EMA length)
Calculation: bear state = close <= VWAP(high, low, close, volume, reset at start of T1) AND close <= EMA(close, short-term EMA length) AND close <= EMA(close, medium-term EMA length)
Calculation: kept zone levels = on the most recent bar where a pivot high or pivot low of pivot length is confirmed, take the zone count most recent pivot high levels and the zone count most recent pivot low levels, keeping each level only if it is at least zone separation multiplier * ATR(atr period) from every more recent kept level on its side; zone width(L) = zone thickness multiplier * ATR(atr period), both evaluated on that bar
Calculation: zone bull share(L) = on the same bar, sum of volume of bars with close >= open divided by sum of volume of all bars, among the last zone volume lookback bars that satisfy high >= L - zone width(L) AND low <= L + zone width(L)
Calculation: in bull zone = for some L in kept zone levels: zone bull share(L) >= bull threshold AND low <= L + zone width(L) / 2 AND close >= L - zone width(L) / 2
Calculation: in bear zone = for some L in kept zone levels: zone bull share(L) < 1 - bear threshold AND high >= L - zone width(L) / 2 AND close <= L + zone width(L) / 2
Long: bull state
Long: bull state AND NOT bull state[1]
Long: bull state AND close > VWAP upper band(high, low, close, volume, first band multiplier, reset at start of T1)
Long: close > VWAP(high, low, close, volume, reset at start of T1)
Long: close crosses above VWAP(high, low, close, volume, reset at start of T1)
Long: EMA(close, short-term EMA length) crosses above EMA(close, medium-term EMA length)
Long: close > EMA(close, short-term EMA length) AND close > EMA(close, medium-term EMA length) AND close > EMA(close, long-term EMA length) AND EMA(close, short-term EMA length) > EMA(close, short-term EMA length)[1] AND EMA(close, medium-term EMA length) > EMA(close, medium-term EMA length)[1] AND EMA(close, long-term EMA length) > EMA(close, long-term EMA length)[1]
Long: bull state AND in bull zone AND close <= VWAP upper band(high, low, close, volume, second band multiplier, reset at start of T1) AND volume / SMA(volume, volume average lookback) >= volume ratio threshold AND EMA(close, long-term EMA length) > EMA(close, long-term EMA length)[1]
Long: in bull zone
Short: bear state
Short: bear state AND NOT bear state[1]
Short: bear state AND close < VWAP lower band(high, low, close, volume, first band multiplier, reset at start of T1)
Short: close < VWAP(high, low, close, volume, reset at start of T1)
Short: close crosses below VWAP(high, low, close, volume, reset at start of T1)
Short: EMA(close, short-term EMA length) crosses below EMA(close, medium-term EMA length)
Short: close < EMA(close, short-term EMA length) AND close < EMA(close, medium-term EMA length) AND close < EMA(close, long-term EMA length) AND EMA(close, short-term EMA length) < EMA(close, short-term EMA length)[1] AND EMA(close, medium-term EMA length) < EMA(close, medium-term EMA length)[1] AND EMA(close, long-term EMA length) < EMA(close, long-term EMA length)[1]
Short: bear state AND in bear zone AND close >= VWAP lower band(high, low, close, volume, second band multiplier, reset at start of T1) AND volume / SMA(volume, volume average lookback) >= volume ratio threshold AND EMA(close, long-term EMA length) < EMA(close, long-term EMA length)[1]
Short: in bear zone