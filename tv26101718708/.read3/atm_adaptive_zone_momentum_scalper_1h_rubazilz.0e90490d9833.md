Calculation: pip = minimum price increment * pip multiplier
Calculation: avg true range = ATR(high, low, close, ATR lookback)
Calculation: entry band = entry band ATR multiple * avg true range
Calculation: body = |close - open|
Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Calculation: body pct = 100 * body / (high - low) if high > low, else 100
Calculation: doji = body pct <= doji max body % AND high - low > pip
Calculation: bull rejection = lower wick >= rejection min wick ratio * body AND body pct <= rejection max body % AND lower wick > rejection dominance ratio * upper wick
Calculation: bear rejection = upper wick >= rejection min wick ratio * body AND body pct <= rejection max body % AND upper wick > rejection dominance ratio * lower wick
Calculation: momentum = body >= momentum min body-to-ATR ratio * avg true range AND upper wick <= momentum max wick % * body / 100 AND lower wick <= momentum max wick % * body / 100
Calculation: small bar = body pct <= cluster small body % AND high - low <= cluster small range ATR multiple * avg true range
Calculation: cluster = max high and min low of the consecutive small bars immediately before the current bar, if the current bar is not a small bar and that run has at least cluster min candles
Calculation: zone list = zones added on each bar in this order: doji zone if doji (demand with bottom = low and top = open if close >= open, else supply with bottom = close and top = high); rejection zone, demand with bottom = low and top = low + rejection zone fraction * lower wick if bull rejection, else supply with bottom = high - rejection zone fraction * upper wick and top = high if bear rejection; momentum zone if momentum (demand with bottom = low and top = open if close > open, else supply with bottom = close and top = high); demand and supply zones, each with bottom = cluster low and top = cluster high, if cluster exists and 100 * (cluster high - cluster low) / ((cluster high + cluster low) / 2) <= cluster max range %; a zone is added only if top - bottom > pip, and then widens the first live zone of the same type whose midpoints differ by at most zone merge pips * pip (bottom = min, top = max), otherwise is appended if zone list size < zone count limit
Calculation: live zones = zones in zone list not yet neutralized, where a demand zone is neutralized once a bar's close is below its bottom and a supply zone once a bar's close is above its top
Calculation: demand tested zones = live demand zones in zone list order with low <= top + entry band AND close >= bottom
Calculation: supply tested zones = live supply zones in zone list order with high >= bottom - entry band AND close <= top
Calculation: long setup = position side is flat AND close > open AND (demand tested zones exist OR (bar index > warm-up count AND close > high[1] AND rising(close, rise length)))
Calculation: short setup = position side is flat AND close < open AND (supply tested zones exist OR (bar index > warm-up count AND close < low[1] AND falling(close, rise length)))
Calculation: long stop = bottom of last demand tested zone - avg true range * stop ATR multiple, at entry bar
Calculation: long target = bottom of last supply tested zone if supply tested zones exist and that bottom > close, else close + avg true range * target ATR multiple, at entry bar
Calculation: short stop = top of last supply tested zone + avg true range * stop ATR multiple, at entry bar
Calculation: short target = top of last demand tested zone if demand tested zones exist and that top < close, else close - avg true range * target ATR multiple, at entry bar
Long: long setup AND NOT long setup[1]
Long: long setup AND NOT long setup[1] AND demand tested zones exist
Short: short setup AND NOT short setup[1]
Short: short setup AND NOT short setup[1] AND supply tested zones exist
Long: bull rejection
Long: momentum AND close > open
Short: bear rejection
Short: momentum AND close <= open
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target