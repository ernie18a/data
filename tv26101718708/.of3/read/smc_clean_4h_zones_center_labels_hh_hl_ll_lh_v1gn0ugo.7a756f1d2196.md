Calculation: Most recent pivot high = latest confirmed pivot high(high, pivot strength, pivot strength)
Calculation: Most recent pivot low = latest confirmed pivot low(low, pivot strength, pivot strength)
Calculation: Previous pivot high = most recent confirmed pivot high before the current pivot confirmation
Calculation: Previous pivot low = most recent confirmed pivot low before the current pivot confirmation
Calculation: Prior structure direction = side of the most recent earlier close crossing a pivot high or low, or neutral if none
Calculation: Active bullish FVG = latest range from high two bars ago to low where low > high two bars ago and the gap is at least ATR(ATR length) times minimum FVG size; active until close falls below its lower boundary
Calculation: Active bearish FVG = latest range from high to low two bars ago where high < low two bars ago and the gap is at least ATR(ATR length) times minimum FVG size; active until close rises above its upper boundary
Calculation: Active bullish OB = high and low of the nearest prior bearish candle within OB lookback at a bullish structure break; active until close falls below its low
Calculation: Active bearish OB = high and low of the nearest prior bullish candle within OB lookback at a bearish structure break; active until close rises above its high
Calculation: Latest demand zone = on a chart bar where T1 changes, use the last completed T1 bar's confirmed pivot low(low, pivot strength, pivot strength); set bottom to low[pivot strength] and top to max(open[pivot strength], close[pivot strength]) on T1 bars
Calculation: Latest supply zone = on a chart bar where T1 changes, use the last completed T1 bar's confirmed pivot high(high, pivot strength, pivot strength); set top to high[pivot strength] and bottom to min(open[pivot strength], close[pivot strength]) on T1 bars
Calculation: Long stop = close minus ATR(ATR length) times stop ATR multiple on the most recent long entry signal bar
Calculation: Long target = close plus ATR(ATR length) times target ATR multiple on the most recent long entry signal bar
Calculation: Short stop = close plus ATR(ATR length) times stop ATR multiple on the most recent short entry signal bar
Calculation: Short target = close minus ATR(ATR length) times target ATR multiple on the most recent short entry signal bar
Long: confirmed pivot high exists AND (no previous pivot high exists OR confirmed pivot high > previous pivot high)
Long: confirmed pivot low exists AND previous pivot low exists AND confirmed pivot low > previous pivot low
Long: close > most recent pivot high AND close[1] <= most recent pivot high
Long: low > high two bars ago AND low - high two bars ago >= ATR(ATR length) * minimum FVG size
Long: bullish structure break AND a bearish candle exists within OB lookback prior bars
Long: T1 changes on a chart bar AND a confirmed pivot low exists on the last completed T1 bar
Long: bar is confirmed AND (active bullish FVG exists AND low <= its midpoint AND close > its midpoint OR active bullish OB exists AND low <= its top AND close > its bottom OR latest demand zone exists AND low <= its top AND close > its bottom OR bullish structure break occurs while prior structure direction is short OR active bearish FVG exists AND close > its upper boundary)
Short: confirmed pivot high exists AND previous pivot high exists AND confirmed pivot high <= previous pivot high
Short: confirmed pivot low exists AND (no previous pivot low exists OR confirmed pivot low <= previous pivot low)
Short: close < most recent pivot low AND close[1] >= most recent pivot low
Short: high < low two bars ago AND low two bars ago - high >= ATR(ATR length) * minimum FVG size
Short: bearish structure break AND a bullish candle exists within OB lookback prior bars
Short: T1 changes on a chart bar AND a confirmed pivot high exists on the last completed T1 bar
Short: bar is confirmed AND (active bearish FVG exists AND high >= its midpoint AND close < its midpoint OR active bearish OB exists AND high >= its bottom AND close < its top OR latest supply zone exists AND high >= its bottom AND close < its top OR bearish structure break occurs while prior structure direction is long OR active bullish FVG exists AND close < its lower boundary)
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target