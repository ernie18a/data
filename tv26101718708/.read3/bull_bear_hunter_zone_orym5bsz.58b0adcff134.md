Calculation: market-structure leg(n) = bearish when high[n] > highest(high, n), bullish when low[n] < lowest(low, n), otherwise the prior leg
Calculation: market-structure pivot high(n) = high[n] when the leg turns bearish, otherwise the latest such high
Calculation: market-structure pivot low(n) = low[n] when the leg turns bullish, otherwise the latest such low
Long: on chart bars, close crosses above an unbroken swing market-structure pivot high
Long: on chart bars, close crosses above an unbroken internal market-structure pivot high AND that pivot high differs from the swing pivot high
Short: on chart bars, close crosses below an unbroken swing market-structure pivot low
Short: on chart bars, close crosses below an unbroken internal market-structure pivot low AND that pivot low differs from the swing pivot low
Calculation: T1 signed change = (last completed T1 close - last completed T1 open) / (last completed T1 open × 100)
Calculation: T1 gap threshold = cumulative sum of absolute T1 signed changes on chart bars that begin a new T1 bar, divided by chart bar index and multiplied by the threshold multiplier when the threshold filter is enabled; otherwise zero
Long: on chart bars using T1 values, a new T1 bar begins AND the still-forming T1 low is above the T1 high two bars before the current T1 bar AND the last completed T1 close is above that high AND T1 signed change > T1 gap threshold
Short: on chart bars using T1 values, a new T1 bar begins AND the still-forming T1 high is below the T1 low two bars before the current T1 bar AND the last completed T1 close is below that low AND -T1 signed change > T1 gap threshold
Calculation: bullish impulse bar = abs(close - open) > SMA(abs(close - open), impulse lookback) AND high - max(open, close) < abs(close - open) × body fraction AND min(open, close) - low < abs(close - open) × body fraction AND close > open
Calculation: bearish impulse bar = abs(close - open) > SMA(abs(close - open), impulse lookback) AND high - max(open, close) < abs(close - open) × body fraction AND min(open, close) - low < abs(close - open) × body fraction AND close < open
Long: the prior chart bar is a bullish impulse bar AND ((conventional-gap mode AND low > high two chart bars ago) OR (inverted-gap mode AND low < high two chart bars ago))
Short: the prior chart bar is a bearish impulse bar AND ((conventional-gap mode AND high < low two chart bars ago) OR (inverted-gap mode AND high > low two chart bars ago))
Long: on chart bars, close > EMA(close, shorter EMA lookback) OR close > EMA(close, longer EMA lookback)
Short: on chart bars, close <= EMA(close, shorter EMA lookback) OR close <= EMA(close, longer EMA lookback)
Long: open > close[1] AND high[1] > low AND close > close[1] AND open > open[1] AND high[1] < min(open, close)
Short: open < close[1] AND low[1] < high AND close < close[1] AND open < open[1] AND low[1] > max(open, close)
Long: on chart bars, close > the latest confirmed ZigZag high in an up leg AND market-structure direction is not bullish
Long: on chart bars, market-structure direction is bullish AND close > the latest confirmed ZigZag high AND that high has not already been marked as bullish BOS or MSS
Short: on chart bars, close < the latest confirmed ZigZag low in a down leg AND market-structure direction is not bearish
Short: on chart bars, market-structure direction is bearish AND close < the latest confirmed ZigZag low AND that low has not already been marked as bearish BOS or MSS
Long: on chart bars, close > an unbroken order-block swing high
Short: on chart bars, close < an unbroken order-block swing low
Calculation: order-block candle bounds = min(open, close) and max(open, close) in body mode, or low and high in wick mode
Calculation: bullish order-block zone = the selected candle bounds for the candle with the lowest selected lower bound between the latest order-block swing high and its upside break
Calculation: bearish order-block zone = the selected candle bounds for the candle with the highest selected upper bound between the latest order-block swing low and its downside break
Calculation: bullish order-block breaker confirmation = the latest bullish order-block zone has been broken when min(open, close) falls below its lower bound, has not since been removed by a close above its upper bound, and the latest order-block swing high lies strictly inside the zone
Calculation: bearish order-block breaker confirmation = the latest bearish order-block zone has been broken when max(open, close) rises above its upper bound, has not since been removed by a close below its lower bound, and the latest order-block swing low lies strictly inside the zone
Short: bullish order-block breaker confirmation changes from false to true
Long: bearish order-block breaker confirmation changes from false to true