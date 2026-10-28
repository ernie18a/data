Calculation: Prior range = highest high and lowest low over the lookback bars before the current bar
Calculation: Long target = entry price + an ATR-based distance; long stop = low of the sweep bar minus an ATR-based buffer
Calculation: Short target = entry price − an ATR-based distance; short stop = high of the sweep bar plus an ATR-based buffer
Long: low < prior lowest low OR (low < prior lowest low AND close > prior lowest low) OR (previous bar low < its prior lowest low AND close > current prior lowest low)
Short: high > prior highest high OR (high > prior highest high AND close < prior highest high) OR (previous bar high > its prior highest high AND close < current prior highest high)
Exit: long, high >= long target OR low <= long stop
Exit: short, low <= short target OR high >= short stop