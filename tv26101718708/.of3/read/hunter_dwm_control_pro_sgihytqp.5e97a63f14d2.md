Calculation: Strong bullish candle = close > open AND close - open > high - max(open, close) + min(open, close) - low
Calculation: Strong bearish candle = close < open AND open - close > high - max(open, close) + min(open, close) - low
Calculation: Structural references(T1, T2, T3) = on each timeframe’s still-forming bars, retain the low of the latest strong bullish candle and the high, low, and time of the latest strong bearish candle that closes below that retained bullish low; T1 is shortest, T2 intermediate, and T3 longest
Calculation: Structural breakout(T) = close(T, still-forming bar) > stored bearish structure high(T) AND time(T, still-forming bar) > stored bearish structure time(T)
Calculation: Structural breakout event(T) = Structural breakout(T) is true and was false on the previous T bar
Calculation: Active structural cycle(T) = a structural breakout event has occurred for the current bearish structure and its time matches the structure time stored at that event
Calculation: Locked invalidation low(T) = low of the bearish structure stored at the latest structural breakout event(T)
Calculation: Primary first target(T) = stored bearish structure high(T) + target-range multiple × (stored bearish structure high(T) - stored bearish structure low(T))
Calculation: First target hit(T) = latched after a confirmed T close at or above Primary first target(T) during the matching active structural cycle; reset on a new breakout
Long: Structural breakout(T1) OR Structural breakout(T2) OR Structural breakout(T3)
Long: On confirmed T1 chart bars, Structural breakout event(T1) AND Active structural cycle(T1) AND close(T1) >= Locked invalidation low(T1) AND no active T1 trade-state cycle AND First target hit(T1) is false
Exit: long, Active structural cycle(T1) AND a confirmed T1 close has fallen below Locked invalidation low(T1)
Exit: long, Active structural cycle(T2) with matching current and last-completed cycle anchors AND last completed close(T2) < Locked invalidation low(T2), evaluated on the first T1 chart bar of a new T2 period
Exit: long, Active structural cycle(T3) with matching current and last-completed cycle anchors AND last completed close(T3) < Locked invalidation low(T3), evaluated on the first T1 chart bar of a new T3 period
Exit: long, on a confirmed T1 chart bar, active T1 trade-state cycle AND close(T1) < its locked invalidation low
Calculation: Bull feed (T1 chart bars) = if Strong bullish candle, low + feed fraction × abs(close - open); otherwise previous feed, or hl2 if unavailable
Calculation: Bear feed (T1 chart bars) = if Strong bearish candle, high - feed fraction × abs(close - open); otherwise previous feed, or hl2 if unavailable
Calculation: Bull Control (T1 chart bars) = EMA(Bull feed, radar control lookback)
Calculation: Bear Control (T1 chart bars) = EMA(Bear feed, the same radar control lookback)
Calculation: Radar normalized spread (T1 chart bars) = if ATR(ATR lookback) > 0, abs(Bull Control - Bear Control) / ATR(ATR lookback); otherwise 0
Calculation: Strength (T1 chart bars) = if SMA(abs(close - open), strength baseline lookback) != 0, (close - open) / SMA(abs(close - open), strength baseline lookback); otherwise 0
Calculation: Acceleration (T1 chart bars) = Strength - Strength[1], treating an unavailable prior Strength as zero
Long: On confirmed T1 chart bars, close(T1) crosses above the stored bearish structure high(T1) AND Structural breakout(T2) AND Radar normalized spread > compression threshold AND close(T1) > max(Bull Control, Bear Control) AND Bull Control >= Bull Control[1] AND Acceleration > 0 AND Strength > strength threshold