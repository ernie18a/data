Calculation: Daily VWAP = volume-weighted average of typical price (high + low + close) / 3, reset each day; use the current bar.
Calculation: VWAP score = clamp(weighted sign of close versus VWAP plus a smaller sign of VWAP slope).
Calculation: TICK score = clamp(short-term EMA of NYSE TICK divided by a scale).
Calculation: VOLD score = clamp(long-lookback z-score of NYSE up-volume minus down-volume divided by a scale).
Calculation: ADD score = clamp NYSE advance-decline value divided by a scale.
Calculation: CVD = cumulative volume, adding volume when close exceeds open and subtracting it when close is below open; reset daily. CVD score = clamp(long-lookback z-score of the change in CVD over a shorter lookback, divided by a scale).
Calculation: MACD score = clamp(MACD histogram divided by a fraction of ATR).
Calculation: MFI score = clamp(MFI centered on its midpoint and divided by a scale).
Calculation: Connors RSI(2) score = positive at the most oversold cutoff, less positive at a higher oversold cutoff, negative at the corresponding overbought cutoffs, and zero between them; include only when current VIX is below its regime threshold, or when VIX is unavailable or disabled.
Calculation: Master score = weighted average of the available component scores; omit unavailable or disabled components from both numerator and denominator.
Calculation: Put spread short strike = round down to the nearest $5 of close minus a configurable buffer; call spread short strike = round up to the nearest $5 of close plus the same buffer. The buffer is either a configurable ATR multiple or a configurable point distance.
Calculation: Expected move = configured expected move when provided, otherwise ATR multiplied by the square root of a configurable bar horizon. Directional drift = master score multiplied by a configurable factor and expected move.
Calculation: Put-spread POP = normal CDF of (close + directional drift − put short strike) / expected move. Call-spread POP = normal CDF of (call short strike − close − directional drift) / expected move.
Long: master score crosses above the positive signal threshold AND put-spread POP is at least the minimum POP.
Short: master score crosses below the negative signal threshold AND call-spread POP is at least the minimum POP.