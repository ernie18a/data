Calculation: HLC3 = (high + low + close) / 3
Calculation: Main resistance = latest pivot high of high, confirmed after a shorter right-side lookback than the strong pivots
Calculation: Main support = latest pivot low of low, confirmed after a shorter right-side lookback than the strong pivots
Calculation: Strong resistance = latest pivot high of high, confirmed after the longer right-side lookback
Calculation: Strong support = latest pivot low of low, confirmed after the longer right-side lookback
Calculation: Historical resistance/support levels = earlier confirmed pivots, using highs/lows or closes according to the configured source mode
Calculation: Fast MA = configured moving average of the configured source using a shorter lookback than the slow MA
Calculation: Slow MA = configured moving average of the configured source using a longer lookback than the fast MA
Calculation: Pivot levels use chart-timeframe bars, or configured higher-timeframe bars when enabled; higher-timeframe levels update only from completed bars
Long: HLC3 > fast MA AND HLC3 > slow MA [AND open > fast MA AND open > slow MA when the open-outside-ribbon filter is enabled]
Long: Main support touch OR strong support touch OR close above main resistance by the configured breakout distance after the previous close was at or below main resistance OR a retest of broken main resistance from above OR rejection at main support
Long: fast MA > slow MA AND close > previous close AND the XBuy sequence is not already active
Long: bullish bar-color condition AND NOT (ribbon filter enabled AND fast MA < slow MA) AND NOT (slope filter enabled AND fast MA is falling over two bars), when this condition begins a new qualifying sequence
Short: HLC3 < fast MA AND HLC3 < slow MA [AND open < fast MA AND open < slow MA when the open-outside-ribbon filter is enabled]
Short: Main resistance touch OR strong resistance touch OR close below main support by the configured breakout distance after the previous close was at or above main support OR a retest of broken main support from below OR rejection at main resistance
Short: fast MA < slow MA AND close < previous close AND the XSell sequence is not already active
Short: bearish bar-color condition AND NOT (ribbon filter enabled AND fast MA > slow MA) AND NOT (slope filter enabled AND fast MA is rising over two bars), when this condition begins a new qualifying sequence
Exit: long, the prior bar qualified for the long swing sequence and the current bar does not
Exit: short, the prior bar qualified for the short swing sequence and the current bar does not