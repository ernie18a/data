Calculation: T1 uptrend = close > EMA(close, T1 shorter lookback, T1, last completed bar) AND EMA(close, T1 shorter lookback, T1, last completed bar) > EMA(close, T1 longer lookback, T1, last completed bar)
Calculation: T1 downtrend = close < EMA(close, T1 shorter lookback, T1, last completed bar) AND EMA(close, T1 shorter lookback, T1, last completed bar) < EMA(close, T1 longer lookback, T1, last completed bar)
Calculation: T2 uptrend = close > EMA(close, T2 shorter lookback, T2, last completed bar) AND close > EMA(close, T2 longer lookback, T2, last completed bar)
Calculation: T2 downtrend = close < EMA(close, T2 shorter lookback, T2, last completed bar) AND close < EMA(close, T2 longer lookback, T2, last completed bar)
Calculation: T3 uptrend = close > EMA(close, T3 shorter lookback, T3, last completed bar) AND close > EMA(close, T3 longer lookback, T3, last completed bar)
Calculation: T3 downtrend = close < EMA(close, T3 shorter lookback, T3, last completed bar) AND close < EMA(close, T3 longer lookback, T3, last completed bar)
Calculation: T4 uptrend = close > EMA(close, T4 shorter lookback, T4, last completed bar) AND close > EMA(close, T4 longer lookback, T4, last completed bar)
Calculation: T4 downtrend = close < EMA(close, T4 shorter lookback, T4, last completed bar) AND close < EMA(close, T4 longer lookback, T4, last completed bar)
Calculation: swing midpoint = (Highest(high, swing lookback) + Lowest(low, swing lookback)) / 2
Calculation: range position = (close - Lowest(low, swing lookback)) / (Highest(high, swing lookback) - Lowest(low, swing lookback)) * 100
Calculation: deep discount = range position < deep discount threshold
Calculation: deep premium = range position > deep premium threshold
Calculation: latest bullish OB = (low, high) of the bar before the most recent bar t where close[1] < open[1] AND close > high[1] AND (close - open) > OB body multiplier * (high[1] - low[1]); its age = bars since that bar
Calculation: latest bearish OB = (low, high) of the bar before the most recent bar t where close[1] > open[1] AND close < low[1] AND (open - close) > OB body multiplier * (high[1] - low[1]); its age = bars since that bar
Calculation: in bullish OB = low <= latest bullish OB high AND high >= latest bullish OB low AND latest bullish OB age < OB lookback
Calculation: in bearish OB = low <= latest bearish OB high AND high >= latest bearish OB low AND latest bearish OB age < OB lookback
Calculation: bullish FVG = low > high[2] AND (low - high[2]) >= FVG minimum size
Calculation: bearish FVG = high < low[2] AND (low[2] - high) >= FVG minimum size
Calculation: latest bullish FVG = (top = low, bottom = high[2]) at the most recent bar where bullish FVG is true; none if a bar after that bar and before the current bar has low <= bottom <= high
Calculation: latest bearish FVG = (top = low[2], bottom = high) at the most recent bar where bearish FVG is true; none if a bar after that bar and before the current bar has low <= top <= high
Calculation: near bullish FVG = low <= latest bullish FVG top AND high >= latest bullish FVG bottom
Calculation: near bearish FVG = low <= latest bearish FVG top AND high >= latest bearish FVG bottom
Calculation: SSL bar = low < Lowest(low[1], liquidity lookback) AND close > open AND close > low + sweep close fraction * (high - low)
Calculation: BSL bar = high > Highest(high[1], liquidity lookback) AND close < open AND close < high - sweep close fraction * (high - low)
Calculation: recent SSL = SSL bar is true on the current bar or on any of the previous sweep recency window bars
Calculation: recent BSL = BSL bar is true on the current bar or on any of the previous sweep recency window bars
Calculation: last swing high = high[pivot right bars] at the most recent bar where PivotHigh(high, pivot left bars, pivot right bars) is true
Calculation: last swing low = low[pivot right bars] at the most recent bar where PivotLow(low, pivot left bars, pivot right bars) is true
Calculation: optimal time = bar time is in optimal window 1 OR bar time is in optimal window 2
Calculation: allowed time = bar time is outside avoid window 1 AND bar time is outside avoid window 2
Calculation: T2 score = T2 score T1-T2 trend points if ((T1 uptrend AND T2 uptrend) OR (T1 downtrend AND T2 downtrend)) + T2 score OB points if ((in bullish OB AND close < swing midpoint AND T1 uptrend) OR (in bearish OB AND close > swing midpoint AND T1 downtrend)) + T2 score sweep points if (recent SSL OR recent BSL) + T2 score volume points if (volume > SMA(volume, volume average lookback) * volume multiplier) + T2 score time points if (optimal time AND allowed time) + T2 score BOS points if (close > last swing high OR close < last swing low) + T2 score FVG points if (near bullish FVG OR near bearish FVG)
Calculation: T3 score = T3 score T3-T4 trend points if ((T3 uptrend AND T4 uptrend) OR (T3 downtrend AND T4 downtrend)) + T3 score T2-T3 trend points if ((T2 uptrend AND T3 uptrend) OR (T2 downtrend AND T3 downtrend)) + T3 score deep zone points if ((deep discount AND T3 uptrend) OR (deep premium AND T3 downtrend)) + T3 score sweep points if (recent SSL OR recent BSL) + T3 score OB points if (in bullish OB OR in bearish OB) + T3 score fresh OB points if (latest bullish OB age < fresh OB age OR latest bearish OB age < fresh OB age)
Calculation: T4 score = T4 score T3-T4 trend points if ((T4 uptrend AND T3 uptrend) OR (T4 downtrend AND T3 downtrend)) + T4 score OB deep zone points if ((in bullish OB AND deep discount) OR (in bearish OB AND deep premium)) + T4 score sweep points if (recent SSL OR recent BSL) + T4 score all-trend points if ((T2 uptrend AND T3 uptrend AND T4 uptrend) OR (T2 downtrend AND T3 downtrend AND T4 downtrend)) + T4 score extreme zone points if (range position < extreme low threshold OR range position > extreme high threshold)
Long: T2 score >= T2 min score AND T1 uptrend AND close < swing midpoint AND (in bullish OB OR recent SSL OR near bullish FVG) AND allowed time
Short: T2 score >= T2 min score AND T1 downtrend AND close > swing midpoint AND (in bearish OB OR recent BSL OR near bearish FVG) AND allowed time
Long: T3 score >= T3 min score AND T3 uptrend AND T2 uptrend AND close < swing midpoint AND (in bullish OB OR recent SSL)
Short: T3 score >= T3 min score AND T3 downtrend AND T2 downtrend AND close > swing midpoint AND (in bearish OB OR recent BSL)
Long: T4 score >= T4 min score AND T4 uptrend AND T3 uptrend AND deep discount AND in bullish OB
Short: T4 score >= T4 min score AND T4 downtrend AND T3 downtrend AND deep premium AND in bearish OB
Exit: long, low <= entry price - T2 stop distance OR high >= entry price + T2 stop distance * T2 reward ratio
Exit: short, high >= entry price + T2 stop distance OR low <= entry price - T2 stop distance * T2 reward ratio
Exit: long, low <= entry price - T3 stop distance OR high >= entry price + T3 stop distance * T3 reward ratio
Exit: short, high >= entry price + T3 stop distance OR low <= entry price - T3 stop distance * T3 reward ratio
Exit: long, low <= entry price - T4 stop distance OR high >= entry price + T4 stop distance * T4 reward ratio
Exit: short, high >= entry price + T4 stop distance OR low <= entry price - T4 stop distance * T4 reward ratio
Long: SSL bar
Short: BSL bar
Long: close > last swing high
Short: close < last swing low
Long: bullish FVG
Short: bearish FVG
Long: in bullish OB
Short: in bearish OB
Long: close < swing midpoint
Short: close > swing midpoint