Calculation: Swing high = highest high since the prior distance-threshold BUY or SELL signal, including the current bar; reset to current high on a signal bar and initialize to the first bar's high
Calculation: Swing low = lowest low since the prior distance-threshold BUY or SELL signal, including the current bar; reset to current low on a signal bar and initialize to the first bar's low
Long: no prior distance-threshold signal or the latest was short AND swing high - low >= minimum swing distance AND close > open AND (EMA trend filter disabled OR close > EMA(close, longer lookback))
Short: no prior distance-threshold signal or the latest was long AND high - swing low >= minimum swing distance AND close < open AND (EMA trend filter disabled OR close < EMA(close, longer lookback))
Long: no prior distance-threshold signal or the latest was short AND swing high - low >= minimum swing distance AND swing high - low >= major swing distance AND close > open AND (EMA trend filter disabled OR close > EMA(close, longer lookback))
Short: no prior distance-threshold signal or the latest was long AND high - swing low >= minimum swing distance AND high - swing low >= major swing distance AND close < open AND (EMA trend filter disabled OR close < EMA(close, longer lookback))
Long: EMA(close, shorter lookback) crosses above VWAP(close)
Short: EMA(close, shorter lookback) crosses below VWAP(close)
Calculation: Order-block pivot lookback = longer parameter on chart minute timeframes at or above a timeframe-threshold parameter; shorter parameter otherwise
Calculation: Active resistance = latest confirmed PivotHigh(high, S/R pivot lookback, S/R pivot lookback); before the first confirmed pivot, use Highest(high, fallback lookback)[1]
Calculation: Active support = latest confirmed PivotLow(low, S/R pivot lookback, S/R pivot lookback); before the first confirmed pivot, use Lowest(low, fallback lookback)[1]
Calculation: Latest supply zone = [low, high] at the most recent confirmed PivotHigh(high, order-block pivot lookback, order-block pivot lookback)
Calculation: Latest demand level = low at the most recent confirmed PivotLow(low, order-block pivot lookback, order-block pivot lookback)
Calculation: Lower rejection wick = min(open, close) - low
Calculation: Upper rejection wick = high - max(open, close)
Long: close crosses above active resistance
Long: close crosses above the top of the latest supply zone
Long: low <= active support AND high >= active support AND bar range > 0 AND lower rejection wick >= bar range * wick fraction AND close > active support
Long: low <= latest demand level AND high >= latest demand level AND bar range > 0 AND lower rejection wick >= bar range * wick fraction AND close > latest demand level
Short: close crosses below active support
Short: close crosses below latest demand level
Short: high >= active resistance AND low <= active resistance AND bar range > 0 AND upper rejection wick >= bar range * wick fraction AND close < active resistance
Short: high >= bottom of latest supply zone AND low <= top of latest supply zone AND bar range > 0 AND upper rejection wick >= bar range * wick fraction AND close < bottom of latest supply zone
Long: low > high[gap lookback]
Short: high < low[gap lookback]
Calculation: Latest bullish FVG bounds = bottom high[gap lookback] and top low on the most recent bar where low > high[gap lookback], updated when FVG display is enabled
Calculation: Latest bearish FVG bounds = bottom high and top low[gap lookback] on the most recent bar where high < low[gap lookback], updated when FVG display is enabled
Long: FVG display enabled AND a latest bullish FVG exists AND low <= its top AND high >= its bottom
Short: FVG display enabled AND a latest bearish FVG exists AND high >= its bottom AND low <= its top