Calculation: Smoothed open and smoothed close = the same selected moving-average method and parameters applied separately to open and close. For the trading decisions, calculate them on the last completed bar of the selected higher or lower timeframe, or on its still-forming bar if configured.
Long: Smoothed close > smoothed open.
Short: Smoothed close < smoothed open.
Long: Smoothed close > smoothed open AND the preceding bar's smoothed close <= its smoothed open.
Short: Smoothed close < smoothed open AND the preceding bar's smoothed close >= its smoothed open.
Exit: long, smoothed close < smoothed open OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, smoothed close > smoothed open OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.