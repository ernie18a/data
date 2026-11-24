Calculation: Volume POC(lookback, bins, T) = on T bars, the midpoint of the first equal-width price bin with maximum summed volume, across bins spanning Lowest(low, lookback) to Highest(high, lookback), assigning each bar's volume (missing volume as zero) to the bin containing its hl2; unavailable unless at least lookback + 1 bars are available, the range is positive, and some bin has positive volume
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) AND (trade-session filtering is disabled OR outside-session signals are enabled OR datetime is within the configured trade session)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback) AND (trade-session filtering is disabled OR outside-session signals are enabled OR datetime is within the configured trade session)
Long: On chart bars, EMA(close, shorter lookback, T1, still-forming T1 bar) > EMA(close, longer lookback, T1, still-forming T1 bar), separately for each trend-table timeframe T1–T6
Short: On chart bars, EMA(close, shorter lookback, T1, still-forming T1 bar) <= EMA(close, longer lookback, T1, still-forming T1 bar), separately for each trend-table timeframe T1–T6
Long: On chart bars, close >= Volume POC(lookback, bins, T7, still-forming T7 bar), separately for each POC timeframe T7–T9
Short: On chart bars, close < Volume POC(lookback, bins, T7, still-forming T7 bar), separately for each POC timeframe T7–T9