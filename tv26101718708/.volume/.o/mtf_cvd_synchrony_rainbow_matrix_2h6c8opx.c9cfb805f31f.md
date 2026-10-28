Calculation: Per-timeframe CVD score = clamp to 0–100 of 50 + 50 × EMA(close-location value × volume) / rolling maximum of the absolute EMA; close-location value = 0 when high = low, otherwise ((close − low) − (high − close)) / (high − low). Calculate on each of five configured timeframes using its own smoothing and normalization lookbacks; use the last completed bar historically and the forming bar in real time.
Calculation: Master score = weighted average of the five per-timeframe CVD scores, with greater weights on the third and fourth timeframes than on the others.
Calculation: CVD pivot divergence = compare consecutive confirmed pivot highs or lows of the smoothed close-location-value-times-volume series and price highs or lows at those same bars; a pivot is confirmed after the same lookback interval used before it.
Long: Any per-timeframe or Master CVD score ≥ 50.
Short: Any per-timeframe or Master CVD score < 50.
Long: Any per-timeframe or Master CVD score ≥ 62 (buy pressure), ≥ 71 (strong buy), or ≥ 85 (buy climax).
Short: Any per-timeframe or Master CVD score ≤ 38 (sell pressure), ≤ 29 (strong sell), or ≤ 15 (sell climax).
Long: On any of the five timeframes or the Master, price makes a lower low and CVD makes a higher low at consecutive confirmed CVD pivot lows.
Short: On any of the five timeframes or the Master, price makes a higher high and CVD makes a lower high at consecutive confirmed CVD pivot highs.
Long: The first-timeframe CVD score ≤ 30 and the fifth-timeframe CVD score ≥ 70, or (when the strong divergence condition is false) the first-timeframe score ≤ 35 and the fifth-timeframe score ≥ 60.
Short: The first-timeframe CVD score ≥ 70 and the fifth-timeframe CVD score ≤ 30, or (when the strong divergence condition is false) the first-timeframe score ≥ 65 and the fifth-timeframe score ≤ 40.