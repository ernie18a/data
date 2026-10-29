Calculation: Rolling VWAP = sum(close × volume) / sum(volume) over a rolling lookback of chart-timeframe bars
Calculation: 2-deviation bands = rolling VWAP ± 2 × volume-weighted mean absolute deviation of close from rolling VWAP over the same lookback
Calculation: OBV RSI = RSI of cumulative volume, adding volume when close rises and subtracting volume when close falls
Long: close ≤ lower 2-deviation band AND OBV RSI ≤ lower RSI threshold AND position is flat AND bars since last exit > cooldown
Short: close ≥ upper 2-deviation band AND OBV RSI ≥ higher RSI threshold AND position is flat AND bars since last exit > cooldown
Exit: long, close crosses above rolling VWAP OR close < entry price × (1 − stop fraction)
Exit: short, close crosses below rolling VWAP OR close > entry price × (1 + stop fraction)