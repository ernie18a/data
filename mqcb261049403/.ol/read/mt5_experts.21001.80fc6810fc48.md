Calculation: Double-smoothed average = a moving average of a selected OHLC-derived price, followed by a second moving average of the first; each smoothing has independently selected method and parameters.
Calculation: Slow average = double-smoothed average on a higher timeframe than the fast average, using the last completed higher-timeframe bar; its slope is compared with the preceding higher-timeframe bar.
Calculation: Fast average = double-smoothed average on the chart timeframe, using the last completed bar; its slope is compared with the preceding chart bar.
Calculation: Mapped higher-timeframe average = double-smoothed average on a higher timeframe than the chart, using the higher-timeframe bar still forming; map its slope to each chart bar and compare that mapped slope with the preceding chart bar's mapped slope.
Long: Slow average > its preceding value AND fast average > its preceding value AND the preceding fast-average slope <= 0
Short: Slow average < its preceding value AND fast average < its preceding value AND the preceding fast-average slope >= 0
Long: Mapped higher-timeframe average slope < 0 AND its preceding chart-bar mapped slope >= 0
Short: Mapped higher-timeframe average slope > 0 AND its preceding chart-bar mapped slope <= 0
Exit: long, slow average < its preceding value OR fast average < its preceding value
Exit: short, slow average > its preceding value OR fast average > its preceding value
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance