Calculation: Chart bullish bias = close > EMA(close, EMA lookback)
Calculation: Chart bearish bias = close < EMA(close, EMA lookback)
Calculation: Timeframe bias(T) = bullish if close(T) > EMA(close(T), EMA lookback), bearish if close(T) < EMA(close(T), EMA lookback), otherwise neutral; calculate on T bars while still forming and map to chart bars, for T1, T2, T3, T4, T5, and T6
Calculation: Resistance(T5) = among candidate highs high[i] in the previous S/R lookback T5 bars where high[i] > current T5 close, count j in those bars where abs(high[j] - high[i]) ≤ ATR(T5, ATR lookback) × touch tolerance AND close[j] < high[i]; keep candidates with at least minimum touches and distance high[i] - current T5 close below maximum level distance, and select the candidate with the smallest distance; calculate on T5 bars while the bar is still forming and map to chart bars
Calculation: Support(T5) = among candidate lows low[i] in the previous S/R lookback T5 bars where low[i] < current T5 close, count j in those bars where abs(low[j] - low[i]) ≤ ATR(T5, ATR lookback) × touch tolerance AND close[j] > low[i]; keep candidates with at least minimum touches and distance current T5 close - low[i] below maximum level distance, and select the candidate with the smallest distance; calculate on T5 bars while the bar is still forming and map to chart bars
Calculation: Bullish break = confirmation filter disabled OR chart bar confirmed, AND Resistance(T5) is defined, AND chart close > Resistance(T5)
Calculation: Bearish break = confirmation filter disabled OR chart bar confirmed, AND Support(T5) is defined, AND chart close < Support(T5)
Calculation: Long score = sum of bias weight for Chart bullish bias, break weight for Bullish break, candle weight for chart close > open, and timeframe-bias weight for each bullish T3, T4, and T5 bias; omit each weight when its condition is false
Calculation: Short score = sum of bias weight for Chart bearish bias, break weight for Bearish break, candle weight for chart close < open, and timeframe-bias weight for each bearish T3, T4, and T5 bias; omit each weight when its condition is false
Long: Chart bullish bias
Short: chart close ≤ EMA(close, EMA lookback)
Long: Timeframe bias(T1) is bullish
Short: Timeframe bias(T1) is bearish
Long: Timeframe bias(T2) is bullish
Short: Timeframe bias(T2) is bearish
Long: Timeframe bias(T3) is bullish
Short: Timeframe bias(T3) is bearish
Long: Timeframe bias(T4) is bullish
Short: Timeframe bias(T4) is bearish
Long: Timeframe bias(T5) is bullish
Short: Timeframe bias(T5) is bearish
Long: Timeframe bias(T6) is bullish
Short: Timeframe bias(T6) is bearish
Long: Bullish break
Short: Bearish break
Long: Long score > Short score AND Long score ≥ score threshold
Short: Short score > Long score AND Short score ≥ score threshold
Long: Chart bullish bias AND Bullish break AND max(Long score, Short score) ≥ score threshold
Short: Chart bearish bias AND Bearish break AND max(Long score, Short score) ≥ score threshold