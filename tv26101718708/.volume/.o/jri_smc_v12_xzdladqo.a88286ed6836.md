Calculation: Swing highs/lows = confirmed pivot highs/lows using equal lookbacks before and after the candidate bar.
Calculation: Bullish structure = the latest of at least two swing highs is higher than the prior swing high AND the latest of at least two swing lows is higher than the prior swing low; bearish structure uses lower highs AND lower lows.
Calculation: Confirmed supply/demand zone = a ±0.1% band around a swing high/low, respectively, with at least two swing highs/lows inside the band; price is in the zone when close is inside any confirmed band.
Calculation: Institution candle = absolute candle body > 2 × its 20-bar average; bullish if close > open, bearish if close < open.
Calculation: High sweep = high > the prior bar's 10-bar highest high AND close < that high; low sweep = low < the prior bar's 10-bar lowest low AND close > that low.
Calculation: Down BOS = close crosses below the second most recent swing low; up BOS = close crosses above the second most recent swing high.
Calculation: Down-BOS retest = after a down BOS, high reaches within 0.1% below its broken swing low and close is below it; up-BOS retest = after an up BOS, low reaches within 0.1% above its broken swing high and close is above it. Each retest condition clears after it occurs.
Long: bullish structure OR bullish institution candle OR low sweep OR up BOS OR up-BOS retest OR price enters a confirmed demand zone OR bullish entry signal.
Short: bearish structure OR bearish institution candle OR high sweep OR down BOS OR down-BOS retest OR price enters a confirmed supply zone OR bearish entry signal.
Long: bullish entry signal = bullish structure + demand-zone condition + up BOS + up-BOS retest + close above session VWAP + 20-period EMA above 50-period EMA + 14-period RSI > 50 score at least the configured threshold, while flat, unlocked, and past the long cooldown.
Short: bearish entry signal = bearish structure + supply-zone condition + down BOS + down-BOS retest + close below session VWAP + 20-period EMA below 50-period EMA + 14-period RSI < 50 score at least the configured threshold, while flat, unlocked, and past the short cooldown.
Exit: long, low <= initial stop or high >= 3R target; at 1R close half and at 2R move stop to entry.
Exit: short, high >= initial stop or low <= 3R target; at 1R close half and at 2R move stop to entry.