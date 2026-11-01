Calculation: Trend lines = For each bar, let change = close − previous close, rise = max(change, 0), and fall = max(−change, 0). The rising run is the cumulative rise over consecutive positive changes, resetting to zero otherwise; the falling run is the cumulative fall over consecutive nonpositive changes, resetting to zero on a positive change. Over a lookback window, upper line = sum(rise) − sum(falling run), and lower line = sum(fall) − sum(rising run).
Long: Chart-timeframe upper line > chart-timeframe lower line
Short: Chart-timeframe upper line < chart-timeframe lower line
Long: On the selected indicator timeframe, the selected signal bar's upper line > its lower line AND the preceding bar's upper line <= its lower line. The indicator timeframe may be higher than, lower than, or equal to the chart timeframe; the signal bar may be the bar still forming or a completed bar at a configurable lag.
Short: On the selected indicator timeframe, the selected signal bar's upper line < its lower line AND the preceding bar's upper line >= its lower line. The indicator timeframe may be higher than, lower than, or equal to the chart timeframe; the signal bar may be the bar still forming or a completed bar at a configurable lag.
Exit: long, the selected indicator timeframe signal bar's upper line < its lower line
Exit: short, the selected indicator timeframe signal bar's upper line > its lower line
Exit: long, stop loss is enabled AND low <= entry price − stop-loss distance
Exit: long, take profit is enabled AND high >= entry price + take-profit distance
Exit: short, stop loss is enabled AND high >= entry price + stop-loss distance
Exit: short, take profit is enabled AND low <= entry price − take-profit distance