Calculation: Bullish FVG = low > high[2]
Calculation: Bearish FVG = high < low[2]
Calculation: MTF up(T) = EMA(close, shorter lookback parameter, on T bars) > EMA(close, longer lookback parameter, on T bars), sampled on chart bars with lookahead off using the current T bar in realtime and the most recently completed T bar historically; share both lookback parameters across T1–T8, assigned in source order
Long: A newly confirmed pivot high with swing lookback parameter on both sides is greater than the prior confirmed pivot high, OR a newly confirmed pivot low with that lookback on both sides is greater than the prior confirmed pivot low
Short: A newly confirmed pivot high with swing lookback parameter on both sides is less than or equal to the prior confirmed pivot high, OR a newly confirmed pivot low with that lookback on both sides is less than or equal to the prior confirmed pivot low
Long: MTF up(T1) OR MTF up(T2) OR MTF up(T3) OR MTF up(T4) OR MTF up(T5) OR MTF up(T6) OR MTF up(T7) OR MTF up(T8)
Short: NOT MTF up(T1) OR NOT MTF up(T2) OR NOT MTF up(T3) OR NOT MTF up(T4) OR NOT MTF up(T5) OR NOT MTF up(T6) OR NOT MTF up(T7) OR NOT MTF up(T8)
Long: On chart bars, the count of T1–T8 where MTF up(T) is true is at least the count where it is false
Short: On chart bars, the count of T1–T8 where MTF up(T) is true is less than the count where it is false
Long: The first FVG of either direction on each New York local date with bar opening time in [early-window start parameter, cutoff-time parameter) is a Bullish FVG
Short: The first FVG of either direction on each New York local date with bar opening time in [early-window start parameter, cutoff-time parameter) is a Bearish FVG
Long: The first FVG of either direction on each New York local date with bar opening time at or after the cutoff-time parameter is a Bullish FVG
Short: The first FVG of either direction on each New York local date with bar opening time at or after the cutoff-time parameter is a Bearish FVG
Long: On each New York local date, the first FVG satisfying Bullish FVG = MTF up(T6) within [double-FVG start-time parameter, cutoff-time parameter) is bullish, and a later bullish FVG in that window also satisfies Bullish FVG = MTF up(T6)
Short: On each New York local date, the first FVG satisfying Bullish FVG = MTF up(T6) within [double-FVG start-time parameter, cutoff-time parameter) is bearish, and a later bearish FVG in that window also satisfies Bullish FVG = MTF up(T6)