Calculation: First MA = selected SMA, EMA, HMA, VWMA, or TEMA of selected source using the first MA lookback
Calculation: Slope threshold = slope-magnitude parameter × 0.01
Calculation: First-MA slope state = up when ROC(First MA, slope lookback) crosses above Slope threshold, down when it crosses below −Slope threshold, otherwise unchanged; initially neutral
Long: First MA crosses above the independently selected SMA, EMA, HMA, VWMA, or TEMA of selected source using the second MA lookback
Short: First MA crosses below the independently selected SMA, EMA, HMA, VWMA, or TEMA of selected source using the second MA lookback
Exit: Short, First-MA slope state changes from down to up
Exit: Long, First-MA slope state changes from up to down