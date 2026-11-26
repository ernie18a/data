Calculation: upper line = linear extrapolation to the current chart bar of the fourth-most-recent and most-recent ZigZag highs (depth, deviation, and backstep parameters; calculated on T1 bars including the still-forming bar; each pivot is placed at the chart-bar shift matching its T1 shift)
Calculation: lower line = linear extrapolation to the current chart bar of the fourth-most-recent and most-recent ZigZag lows (depth, deviation, and backstep parameters; calculated on T1 bars including the still-forming bar; each pivot is placed at the chart-bar shift matching its T1 shift)
Long: flat AND close < lower line + offset AND SMA(close, shorter lookback) > SMA(close, longer lookback)
Short: flat AND close > upper line - offset AND SMA(close, shorter lookback) < SMA(close, longer lookback)
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance