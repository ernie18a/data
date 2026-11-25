Calculation: Compression tier = 3 if Bollinger Bands(close, squeeze lookback, BB multiplier) are strictly inside Keltner Channels centered on SMA(close, same lookback), using SMA(True Range, same lookback) and the tight multiplier; else 2 if inside the middle channel; else 1 if inside the loose channel; else 0. Use the same squeeze lookback for all bands and channels. On T timeframes use the last completed T bar; on chart bars use the current bar.
Calculation: Squeeze momentum = LinearRegression(close - (((Highest(high, squeeze lookback) + Lowest(low, squeeze lookback)) / 2 + SMA(close, squeeze lookback)) / 2, squeeze lookback, 0). On T timeframes use the last completed T bar; on chart bars use the current bar.
Calculation: Tier-weighted lean for a set of enabled timeframes = sum of sign(Squeeze momentum) * (Compression tier + 1) across that set.
Calculation: Squeeze fire on T = Compression tier was greater than 0 on the preceding T bar and is 0 on the last completed T bar; firing direction is the sign of Squeeze momentum on that T bar.
Long: On chart bars, Squeeze momentum on the last completed bar of any enabled T1...Tn is greater than 0.
Short: On chart bars, Squeeze momentum on the last completed bar of any enabled T1...Tn is less than 0.
Long: On chart bars, any enabled T1...Tn has a Squeeze fire with positive firing direction.
Short: On chart bars, any enabled T1...Tn has a Squeeze fire with negative firing direction.
Long: The count of enabled T1...Tn with a bullish Squeeze fire is at least the minimum fire count and exceeds the count with a bearish Squeeze fire, and, when higher-timeframe alignment is required, no bullish-firing T has a negative nonzero Tier-weighted lean across enabled higher-duration T timeframes.
Short: The count of enabled T1...Tn with a bearish Squeeze fire is at least the minimum fire count and exceeds the count with a bullish Squeeze fire, and, when higher-timeframe alignment is required, no bearish-firing T has a positive nonzero Tier-weighted lean across enabled higher-duration T timeframes.
Long: The count of enabled T1...Tn with positive Squeeze momentum exceeds the count with negative Squeeze momentum.
Short: The count of enabled T1...Tn with negative Squeeze momentum exceeds the count with positive Squeeze momentum.
Long: Tier-weighted lean across all enabled T1...Tn is positive.
Short: Tier-weighted lean across all enabled T1...Tn is negative.
Long: Squeeze momentum on the enabled T timeframe with the greatest duration is positive.
Short: Squeeze momentum on the enabled T timeframe with the greatest duration is negative.
Long: A confirmed pivot low in price is below the preceding pivot low, the corresponding pivot-low value of CMF(high, low, close, volume, CMF lookback) is above its preceding value, and the distance between price pivots is at most the maximum pivot gap; use the same separate left and right pivot lookbacks for price and CMF.
Short: A confirmed pivot high in price is above the preceding pivot high, the corresponding pivot-high value of CMF(high, low, close, volume, CMF lookback) is below its preceding value, and the distance between price pivots is at most the maximum pivot gap; use the same separate left and right pivot lookbacks for price and CMF.
Long: A bullish CMF-price pivot divergence was detected within the persistence lookback and no bearish CMF-price pivot divergence was detected within that lookback.
Short: A bearish CMF-price pivot divergence was detected within the persistence lookback and no bullish CMF-price pivot divergence was detected within that lookback.
Calculation: Exit acceleration z-score = let m = EMA(RSI(close, exit RSI lookback), momentum EMA lookback), v = EMA(m - m[1], velocity EMA lookback), and a = EMA(v - v[1], acceleration EMA lookback); (a - SMA(a, acceleration z-score lookback)) / StDev(a, acceleration z-score lookback), or 0 when that standard deviation is 0. Evaluate on current chart bars.
Calculation: Exit volume z-score = (volume - SMA(volume, climax volume lookback)) / StDev(volume, climax volume lookback), or 0 when that standard deviation is 0. Evaluate on current chart bars.
Calculation: Close position in range = (close - low) / (high - low), or 0.5 when high equals low.
Calculation: Upper wick fraction = (high - max(close, open)) / (high - low), or 0 when high equals low.
Calculation: Lower wick fraction = (min(close, open) - low) / (high - low), or 0 when high equals low.
Calculation: Post-fire re-compression = after a chart squeeze fire, true once Compression tier on a chart bar becomes greater than 0 within the re-compression window, and remains true until the next chart squeeze fire. A chart squeeze fire is Compression tier greater than 0 on the preceding chart bar and 0 on the current chart bar; its direction is the sign of current chart Squeeze momentum.
Calculation: Chart higher-timeframe conflict = an active chart fire and at least one enabled T with duration greater than the chart duration, where the sign of Tier-weighted lean across those higher-duration T timeframes is nonzero and opposes the chart fire direction. Use the last completed bar of each T timeframe.
Calculation: Squeeze Exit Score = 0 without an active chart fire or when the sum of the five exit weights is 0; otherwise 100 times the weighted mean of: deceleration term (0 unless active long and Exit acceleration z-score is at or below its negative threshold, or active short and it is at or above the threshold's negation; when true, min(1, abs(z-score) / (2 * abs(threshold)))); climax term (0 unless the volume z-score meets its threshold, chart range is at least the range multiplier times ATR(chart, ATR lookback), and rejection matches the active side; when true, min(1, volume z-score / (2 * threshold))); Post-fire re-compression as 1 or 0; Chart higher-timeframe conflict as 1 or 0; and staleness term (0 unless bars since chart fire exceed typical hold, then min(1, (bars since fire - typical hold) / typical hold)). Use separate weights for each term. Evaluate on current chart bars.
Exit: Long, an active bullish chart fire and Exit acceleration z-score at or below the negative deceleration threshold.
Exit: Short, an active bearish chart fire and Exit acceleration z-score at or above the negation of the negative deceleration threshold.
Exit: Long, an active bullish chart fire, Exit volume z-score at or above its threshold, chart range at least the range multiplier times ATR(chart, ATR lookback), and (Close position in range at or below 1 minus the close-position threshold or Upper wick fraction at or above that threshold).
Exit: Short, an active bearish chart fire, Exit volume z-score at or above its threshold, chart range at least the range multiplier times ATR(chart, ATR lookback), and (Close position in range at or above the close-position threshold or Lower wick fraction at or above that threshold).
Exit: Long, an active bullish chart fire and Post-fire re-compression.
Exit: Short, an active bearish chart fire and Post-fire re-compression.
Exit: Long, an active bullish chart fire and Chart higher-timeframe conflict.
Exit: Short, an active bearish chart fire and Chart higher-timeframe conflict.
Exit: Long, an active bullish chart fire and bars since chart fire exceed typical hold.
Exit: Short, an active bearish chart fire and bars since chart fire exceed typical hold.
Exit: Long, an active bullish chart fire and Squeeze Exit Score is at least the caution level and below the exit level.
Exit: Short, an active bearish chart fire and Squeeze Exit Score is at least the caution level and below the exit level.
Exit: Long, an active bullish chart fire and Squeeze Exit Score is at least the exit level.
Exit: Short, an active bearish chart fire and Squeeze Exit Score is at least the exit level.
Exit: Long, an active bullish chart fire and the score state changes from HOLD to CAUTION or changes to EXIT from a state other than EXIT.
Exit: Short, an active bearish chart fire and the score state changes from HOLD to CAUTION or changes to EXIT from a state other than EXIT.