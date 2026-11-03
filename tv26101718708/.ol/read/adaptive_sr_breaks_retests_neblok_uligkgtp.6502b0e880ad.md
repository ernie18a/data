Calculation: Live resistance = price of the latest confirmed pivot high; a newer confirmed pivot high replaces it
Calculation: Live support = price of the latest confirmed pivot low; a newer confirmed pivot low replaces it
Calculation: Pivot high/low = a swing high/low confirmed after the configured number of bars to its right
Calculation: ATR = average true range
Calculation: Zone tolerance = greater of the ATR-scaled zone half-width and the minimum price increment
Calculation: Break score = count of (relative volume above its threshold, or—if volume is unavailable—bar range above its ATR-scaled threshold), (body/range above its threshold and body points in the break direction), and (close distance beyond the level above its ATR-scaled threshold)
Calculation: Qualified bullish break = close above live resistance by at least the ATR-scaled minimum close-through distance, with break score at least the configured minimum
Calculation: Qualified bearish break = close below live support by at least the ATR-scaled minimum close-through distance, with break score at least the configured minimum
Calculation: Broken resistance/support = the level from a qualified bullish/bearish break, watched for the configured retest window
Long: Qualified bullish break OR broken resistance retest (low ≤ level + zone tolerance AND close > level) OR failed bearish break (close > broken support + zone tolerance) OR support sweep (low < live support AND close > live support AND previous low ≥ live support)
Short: Qualified bearish break OR broken support retest (high ≥ level − zone tolerance AND close < level) OR failed bullish break (close < broken resistance − zone tolerance) OR resistance sweep (high > live resistance AND close < live resistance AND previous high ≤ live resistance)