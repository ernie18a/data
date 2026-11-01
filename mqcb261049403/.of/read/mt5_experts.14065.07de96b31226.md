Calculation: Weighted DeMarker = sum of five DeMarker values with progressively longer lookbacks, each multiplied by its corresponding weight; the third uses the same weight as the second.
Calculation: Signal line = weighted DeMarker / smoothing period + previous signal line * (smoothing period - 1) / smoothing period; initialize at the seed bar to weighted DeMarker / smoothing period.
Calculation: Indicator-timeframe values = weighted DeMarker and signal line computed on a configurable timeframe that may be higher or lower than the chart timeframe, or the chart timeframe itself; use a configurable bar offset, either the bar still forming or a completed bar, and its immediately preceding bar. For a completed-bar offset, evaluate when a new indicator-timeframe bar begins.
Long: Chart-timeframe weighted DeMarker > chart-timeframe signal line.
Short: Chart-timeframe weighted DeMarker < chart-timeframe signal line.
Long: Indicator-timeframe weighted DeMarker > indicator-timeframe signal line AND its preceding-bar weighted DeMarker < its preceding-bar signal line.
Short: Indicator-timeframe weighted DeMarker < indicator-timeframe signal line AND its preceding-bar weighted DeMarker > its preceding-bar signal line.
Exit: long, indicator-timeframe weighted DeMarker < indicator-timeframe signal line.
Exit: short, indicator-timeframe weighted DeMarker > indicator-timeframe signal line.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.