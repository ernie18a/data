Calculation: upper_wick = high - max(open, close); lower_wick = min(open, close) - low; body = abs(close - open)
Calculation: supply_level = the lowest high among earlier bars that satisfied the Short condition, considering only highs not yet reached since that bar (no later bar, including the current one, has high >= that high), and that are above the current close
Calculation: demand_level = the highest low among earlier bars that satisfied the Long condition, considering only lows not yet reached since that bar (no later bar, including the current one, has low <= that low), and that are below the current close
Long: volume > multiplier * simple moving average of volume AND lower_wick > body AND close > open
Short: volume > multiplier * simple moving average of volume AND upper_wick > body AND close < open
Long: demand_level exists AND (close - demand_level) < fraction * ATR
Short: supply_level exists AND (supply_level - close) < fraction * ATR