Calculation: Trend line = highest high over a lookback ending at the evaluated bar minus a configurable fraction of the difference between that highest high and the lowest low over the same lookback. Evaluate it on a configurable higher or lower timeframe, using the last completed bar by default or the forming bar if configured.
Calculation: Lagged trend line = trend line a configurable number of indicator-timeframe bars earlier.
Long: Trend line > lagged trend line
Long: Trend line > lagged trend line AND previous indicator-timeframe bar's trend line <= its lagged trend line
Short: Trend line < lagged trend line
Short: Trend line < lagged trend line AND previous indicator-timeframe bar's trend line >= its lagged trend line
Exit: long, trend line < lagged trend line OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, trend line > lagged trend line OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance