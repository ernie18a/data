Calculation: Smoothed bear power = a moving average of (low minus a separate moving average of a selected OHLC-derived price); the two averages have independently selected methods and lookbacks.
Calculation: Gap = the smoothed series (high minus a moving average of open) minus the previous bar's smoothed series (high minus a moving average of close); the open and close averages share a method and lookback, and the two smoothing averages share a separately selected method and lookback.
Long: Current chart-bar smoothed bear power > previous chart-bar smoothed bear power.
Short: Current chart-bar smoothed bear power < previous chart-bar smoothed bear power.
Long: Current chart-bar gap > 0.
Short: Current chart-bar gap < 0.
Long: Gap on the last completed bar of a selected higher or lower timeframe > 0 AND gap on its preceding bar <= 0.
Short: Gap on the last completed bar of a selected higher or lower timeframe < 0 AND gap on its preceding bar >= 0.
Exit: long, gap on the last completed bar of a selected higher or lower timeframe < 0.
Exit: short, gap on the last completed bar of a selected higher or lower timeframe > 0.
Exit: long, low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.