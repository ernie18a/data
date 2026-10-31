Calculation: Slope = 100 times the least-squares linear-regression slope of a moving average of the selected OHLC price, over a lookback equal to the moving-average length, with time ordered oldest to newest. Calculate on the higher timeframe using its last completed bar; alternatively, use its still-forming bar when configured.
Calculation: Trigger = Slope shifted back by a configurable number of higher-timeframe bars.
Long: Slope > Trigger AND previous higher-timeframe bar's Slope <= its Trigger.
Short: Slope < Trigger AND previous higher-timeframe bar's Slope >= its Trigger.
Exit: long, Slope < Trigger OR low <= entry price minus the stop-loss distance OR high >= entry price plus the take-profit distance.
Exit: short, Slope > Trigger OR high >= entry price plus the stop-loss distance OR low <= entry price minus the take-profit distance.