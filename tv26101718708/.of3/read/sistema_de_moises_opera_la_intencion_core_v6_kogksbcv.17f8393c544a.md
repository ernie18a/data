Calculation: Latest swing high = the most recent non-missing PivotHigh(high, swing lookback, swing lookback) confirmed on chart bars
Calculation: Latest swing low = the most recent non-missing PivotLow(low, swing lookback, swing lookback) confirmed on chart bars
Calculation: Prior high T3 = high of the last completed T3 bar, sampled on chart bars
Calculation: Prior low T3 = low of the last completed T3 bar, sampled on chart bars
Calculation: Prior high T4 = high of the last completed T4 bar, sampled on chart bars
Calculation: Prior low T4 = low of the last completed T4 bar, sampled on chart bars
Calculation: T1 bullish context = T1 close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback); values are from the current, possibly still-forming T1 bar, sampled on chart bars, and the EMAs are calculated on T1 bars
Calculation: T1 bearish context = T1 close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback); values are from the current, possibly still-forming T1 bar, sampled on chart bars, and the EMAs are calculated on T1 bars
Calculation: T2 bullish context = T2 close > EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback); values are from the current, possibly still-forming T2 bar, sampled on chart bars, and the EMAs are calculated on T2 bars
Calculation: T2 bearish context = T2 close < EMA(close, shorter EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback); values are from the current, possibly still-forming T2 bar, sampled on chart bars, and the EMAs are calculated on T2 bars
Calculation: High sweep = (Latest swing high exists AND high > Latest swing high AND close < Latest swing high) OR (high > Prior high T3 AND close < Prior high T3) OR (high > Prior high T4 AND close < Prior high T4)
Calculation: Low sweep = (Latest swing low exists AND low < Latest swing low AND close > Latest swing low) OR (low < Prior low T3 AND close > Prior low T3) OR (low < Prior low T4 AND close > Prior low T4)
Calculation: Recent high sweep = bars since High sweep <= sweep-memory bars on chart bars
Calculation: Recent low sweep = bars since Low sweep <= sweep-memory bars on chart bars
Calculation: Bullish impulse = close > open AND abs(close - open) / max(high - low, minimum tick size) >= minimum body fraction AND max(high - low, minimum tick size) >= ATR(ATR lookback) * minimum impulse ATR multiple AND close > high[1]
Calculation: Bearish impulse = close < open AND abs(close - open) / max(high - low, minimum tick size) >= minimum body fraction AND max(high - low, minimum tick size) >= ATR(ATR lookback) * minimum impulse ATR multiple AND close < low[1]
Calculation: Bullish intent = Bullish impulse OR (Latest swing high exists AND close > Latest swing high)
Calculation: Bearish intent = Bearish impulse OR (Latest swing low exists AND close < Latest swing low)
Calculation: Recent bullish intent = bars since Bullish intent <= displacement-memory bars on chart bars
Calculation: Recent bearish intent = bars since Bearish intent <= displacement-memory bars on chart bars
Calculation: Bullish post-sweep intent = Recent low sweep AND Recent bullish intent AND bars since Bullish intent < bars since Low sweep
Calculation: Bearish post-sweep intent = Recent high sweep AND Recent bearish intent AND bars since Bearish intent < bars since High sweep
Calculation: Upper liquidity target = (Latest swing high exists AND close < Latest swing high) OR close < Prior high T3 OR close < Prior high T4
Calculation: Lower liquidity target = (Latest swing low exists AND close > Latest swing low) OR close > Prior low T3 OR close > Prior low T4
Calculation: Range position = 100 * (close - lowest(low, range lookback)) / max(highest(high, range lookback) - lowest(low, range lookback), minimum tick size)
Calculation: Midrange = NOT (Range position <= discount cutoff) AND NOT (Range position >= premium cutoff)
Calculation: Near upper liquidity = (Latest swing high exists AND abs(close - Latest swing high) <= ATR(ATR lookback) * liquidity proximity ATR multiple) OR abs(close - Prior high T3) <= ATR(ATR lookback) * liquidity proximity ATR multiple OR abs(close - Prior high T4) <= ATR(ATR lookback) * liquidity proximity ATR multiple
Calculation: Near lower liquidity = (Latest swing low exists AND abs(close - Latest swing low) <= ATR(ATR lookback) * liquidity proximity ATR multiple) OR abs(close - Prior low T3) <= ATR(ATR lookback) * liquidity proximity ATR multiple OR abs(close - Prior low T4) <= ATR(ATR lookback) * liquidity proximity ATR multiple
Calculation: Long score = long T1-context weight when T1 bullish context + long T2-context weight when T2 bullish context + long low-sweep weight when Recent low sweep + long upper-target weight when Upper liquidity target + long post-sweep-intent weight when Bullish post-sweep intent, otherwise long recent-intent weight when Recent bullish intent + long discount weight when Range position <= discount cutoff, otherwise long midrange-context weight when Midrange AND T1 bullish context + long lower-proximity weight when Near lower liquidity
Calculation: Short score = short T1-context weight when T1 bearish context + short T2-context weight when T2 bearish context + short high-sweep weight when Recent high sweep + short lower-target weight when Lower liquidity target + short post-sweep-intent weight when Bearish post-sweep intent, otherwise short recent-intent weight when Recent bearish intent + short premium weight when Range position >= premium cutoff, otherwise short midrange-context weight when Midrange AND T1 bearish context + short upper-proximity weight when Near upper liquidity
Long: T1 bullish context
Short: T1 bearish context
Long: Recent low sweep
Short: NOT Recent low sweep AND Recent high sweep
Long: Bullish post-sweep intent OR (NOT Bearish post-sweep intent AND Recent bullish intent AND NOT Recent bearish intent)
Short: NOT Bullish post-sweep intent AND (Bearish post-sweep intent OR (Recent bearish intent AND NOT Recent bullish intent))
Long: Range position <= discount cutoff
Short: Range position >= premium cutoff
Long: Long score - Short score > score-gap threshold
Short: Short score - Long score > score-gap threshold