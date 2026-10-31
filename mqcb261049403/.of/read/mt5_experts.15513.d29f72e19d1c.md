Calculation: Double-smoothed price = apply a first moving average to a price series, then apply a second moving average to the result; the first smoothing has a longer lookback than the second. Calculate separately for open, close, and the selected price on the chart timeframe or a higher timeframe, using the last completed bar or, if configured, the bar still forming.
Long: Double-smoothed close > double-smoothed open
Short: Double-smoothed close < double-smoothed open
Long: Selected price > its double-smoothed value
Short: Selected price < its double-smoothed value
Long: Double-smoothed close > double-smoothed open AND the preceding bar's double-smoothed close <= its double-smoothed open
Short: Double-smoothed close < double-smoothed open AND the preceding bar's double-smoothed close >= its double-smoothed open
Exit: long, double-smoothed close < double-smoothed open OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, double-smoothed close > double-smoothed open OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance