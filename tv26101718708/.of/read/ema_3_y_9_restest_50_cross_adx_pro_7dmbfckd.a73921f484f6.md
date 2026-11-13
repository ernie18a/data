Calculation: EMAfast, EMAmid, EMAslow = EMAs of close on the chart timeframe, current bar, with lengths fast < mid < slow
Calculation: Zone = low <= EMAslow*(1+b) AND high >= EMAslow*(1-b), where b is a small fixed fraction
Calculation: VolHigh = volume > m * SMA(volume), where m > 1
Calculation: BreakUp = close > previous bar high; BreakDn = close < previous bar low
Calculation: RSI, ADX, +DI, -DI = standard RSI and DMI/ADX on the chart timeframe
Calculation: LongFilters = the six conditions [close > EMAslow, RSI > 50, VolHigh, ADX > ADXmin, Zone, BreakUp]; ShortFilters = the six conditions [close < EMAslow, RSI < 50, VolHigh, ADX > ADXmin, Zone, BreakDn]
Calculation: CounterLong = sum of a positive weight for each LongFilters condition that is false (each condition has its own weight; trend and ADX weights >= the other weights); CounterShort = the same for ShortFilters
Calculation: StrongLong = close > EMAslow AND ADX > ADXstrong; StrongShort = close < EMAslow AND ADX > ADXstrong; ADXstrong > ADXmin
Long: EMAfast crosses above EMAmid AND all six LongFilters are true AND (bullish candle with close > open and body > 0.5 * (high - low) OR close > EMAfast) AND position is not already long
Short: EMAfast crosses below EMAmid AND all six ShortFilters are true AND (bearish candle with open > close and body > 0.5 * (high - low) OR close < EMAfast) AND position is not already short
Exit: long, close < lowest low of the N bars before the current bar (short fixed lookback N) OR (CounterLong >= cancel threshold AND NOT StrongLong); evaluated on every bar while long, including the entry bar
Exit: short, close > highest high of the N bars before the current bar (short fixed lookback N) OR (CounterShort >= cancel threshold AND NOT StrongShort); evaluated on every bar while short, including the entry bar
Long: count of true LongFilters >= k (k = majority of the six)
Short: count of true ShortFilters >= k AND count of true LongFilters < k
Long: ADX > ADXmin AND +DI > -DI
Short: ADX > ADXmin AND -DI > +DI
Long: close > EMAslow
Short: close <= EMAslow
Long: RSI > upper level (above 50)
Short: RSI < lower level (below 50)