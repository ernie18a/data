Calculation: Session midpoint = midpoint of session high and low; at each higher-timeframe session boundary, initialize both to the current chart bar’s (high + low) / 2, then after the configured wait update session high/low from chart-bar highs/lows.
Calculation: Trend direction = +1 when close is above session midpoint, −1 when below, and otherwise retain the prior direction; initially 0.
Calculation: Confirmed pivot high = most recent non-missing chart-timeframe pivot high, carried forward; use the pivot high confirmed one bar earlier. Pivot high uses the configured left and right lookbacks.
Calculation: Confirmed pivot low = most recent non-missing chart-timeframe pivot low, carried forward; use the pivot low confirmed one bar earlier. Pivot low uses the configured left and right lookbacks.
Long: flat AND trend direction = +1 AND the configured wait after the higher-timeframe session boundary has elapsed AND close > confirmed pivot high
Short: flat AND trend direction = −1 AND the configured wait after the higher-timeframe session boundary has elapsed AND close < confirmed pivot low
Exit: long, trend direction = −1 AND close < entry price AND close < confirmed pivot low
Exit: short, trend direction = +1 AND close > entry price AND close > confirmed pivot high