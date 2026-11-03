Calculation: Signal timeframe = chart timeframe when unset; otherwise the configured timeframe, which may be higher or lower than the chart timeframe; use its last completed bar when close-wait is enabled, otherwise its still-forming bar.
Calculation: Trend moving average = selected moving-average method applied to the selected source over the selected lookback.
Calculation: SSL exit line = moving average of highs or lows over the exit lookback, using the high average while close is below the low average and the low average otherwise; retain the prior side when close is between the averages, defaulting to the low average.
Calculation: SSL baseline = selected moving-average method applied to highs and lows over the baseline lookback; use the high average while close is below the low average and the low average otherwise, retaining the prior side between the averages and defaulting to the low average.
Calculation: SSL continuation line = selected moving-average method applied to highs and lows over the shorter continuation lookback; use the high average while close is below the low average and the low average otherwise, retaining the prior side between the averages and defaulting to the low average.
Calculation: Rapid Hull curve = WMA(2 × WMA(close, half the lookback) − WMA(close, lookback), square root of the lookback); define A = prior curve − 2 × current curve and B = 2 × current curve − prior curve.
Calculation: ATR-adaptive Jurik moving average = Jurik filter of the selected source, with its period adapted between half the base period and the base period according to the current ATR's position between its recent minimum and maximum.
Long: trend moving average is rising after falling on the preceding bar AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Short: trend moving average is falling after rising on the preceding bar AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Long: close crosses above the SSL exit line AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Short: close crosses below the SSL exit line AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Long: close > SSL continuation line AND close > SSL baseline AND close − ATR-smoothed true range × continuation threshold < SSL continuation line
Short: close < SSL continuation line AND close < SSL baseline AND close + ATR-smoothed true range × continuation threshold > SSL continuation line
Long: A < prior A AND prior A ≥ A from two bars earlier AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Short: B < prior B AND prior B ≥ B from two bars earlier AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Long: ATR-adaptive Jurik moving average crosses above its value on the preceding bar AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Short: ATR-adaptive Jurik moving average crosses below its value on the preceding bar AND (close-wait is disabled OR the signal-timeframe bar is confirmed)
Long: close > SSL baseline line
Short: close < SSL baseline line
Long: selected trend moving average > its value on the preceding bar
Short: selected trend moving average < its value on the preceding bar
Long: current low > high from two bars earlier AND preceding close > high from two bars earlier
Short: current high < low from two bars earlier AND preceding close < low from two bars earlier
Long: a confirmed pivot low occurs, with its center bar lower than the specified number of bars on both sides
Short: a confirmed pivot high occurs, with its center bar higher than the specified number of bars on both sides