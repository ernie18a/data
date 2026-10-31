Calculation: Smoothed trend momentum of a price series = Jurik moving average of the difference between a shorter and a longer finite impulse response filter applied to that series; each filter is a weighted sum of the current and preceding values with its own ordered coefficient vector.
Long: Chart-timeframe smoothed trend momentum of an applied price > 0
Short: Chart-timeframe smoothed trend momentum of an applied price < 0
Long: Chart-timeframe smoothed trend momentum of close > chart-timeframe smoothed trend momentum of open
Short: Chart-timeframe smoothed trend momentum of close < chart-timeframe smoothed trend momentum of open
Long: Higher-timeframe smoothed trend momentum of close on the last completed bar > smoothed trend momentum of open on that bar AND smoothed trend momentum of close on the preceding higher-timeframe bar <= smoothed trend momentum of open on that bar
Short: Higher-timeframe smoothed trend momentum of close on the last completed bar < smoothed trend momentum of open on that bar AND smoothed trend momentum of close on the preceding higher-timeframe bar >= smoothed trend momentum of open on that bar
Exit: short, higher-timeframe smoothed trend momentum of close on the last completed bar > smoothed trend momentum of open on that bar
Exit: long, higher-timeframe smoothed trend momentum of close on the last completed bar < smoothed trend momentum of open on that bar
Exit: long, low <= entry price - stop distance OR high >= entry price + profit-target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - profit-target distance