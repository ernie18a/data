Calculation: Extrapolated moving average = Let M be a configurable moving average of a configurable OHLC-derived price and N its lookback. At bar t, let a = M[t] - M[t-floor(N/4)], b = M[t] - 2*M[t-floor(N/4)] + M[t-floor(N/8)], and c = M[t] - 3*M[t-floor(N/4)] + 3*M[t-floor(N/8)] - M[t-floor(N/12)]. Smooth M[t] + a + b/2 + c/6 with a separately configurable moving average, then round to a configurable price increment.
Calculation: Direction = +1 when the extrapolated moving average is greater than its previous-bar value, -1 when it is less, and otherwise the previous direction; initialize direction to -1.
Long: Chart-timeframe direction = +1
Short: Chart-timeframe direction = -1
Long: Direction on a configurable higher or lower timeframe changes from -1 to +1 on its last completed bar
Short: Direction on a configurable higher or lower timeframe changes from +1 to -1 on its last completed bar
Exit: long, direction on the last completed bar of the configurable higher or lower timeframe = -1
Exit: short, direction on the last completed bar of the configurable higher or lower timeframe = +1
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance