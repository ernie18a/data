Calculation: Range oscillator = for each of five progressively longer lookbacks, 100 × (current bar midpoint of high and low − lowest low over the lookback) / (highest high − lowest low over the lookback), including the current bar; use zero when the range is zero.
Calculation: Fast line = weighted sum of the five range oscillators; the second and third oscillators use the same weight, while the others have separate weights.
Calculation: Slow line = fast line / smoothing length + previous slow line × (smoothing length − 1) / smoothing length. Initialize the slow line to the fast line / smoothing length on the bar with three times the longest lookback plus three preceding bars. Calculate the lines on the chart timeframe for the indicator markings, or on a configurable higher or lower timeframe for the trading signals, using its last completed bar or its still-forming bar according to the signal-bar setting.
Long: Fast line > slow line.
Short: Fast line < slow line.
Long: Fast line > slow line AND previous fast line < previous slow line.
Short: Fast line < slow line AND previous fast line > previous slow line.
Exit: long, fast line < slow line.
Exit: short, fast line > slow line.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.