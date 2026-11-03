Calculation: Stochastic RSI %K = the simple moving average of the stochastic value of RSI, using the same lookback for RSI and stochastic; Stochastic RSI %D = a simple moving average of %K
Calculation: Long stop = entry price − ATR × stop multiplier; while long, raise it to the greater of its current value and the previous bar’s low
Calculation: Short stop = entry price + ATR × stop multiplier; while short, lower it to the lesser of its current value and the previous bar’s high
Calculation: Long target = entry price + (entry price − initial long stop) × reward-to-risk ratio
Calculation: Short target = entry price − (initial short stop − entry price) × reward-to-risk ratio
Long: %K > %D AND previous bar’s %K ≤ previous bar’s %D AND close > VWAP AND datetime is within the configured entry session AND long trades are enabled AND position is flat
Short: %K < %D AND previous bar’s %K ≥ previous bar’s %D AND close < VWAP AND datetime is within the configured entry session AND short trades are enabled AND position is flat
Exit: long, low ≤ long stop OR high ≥ long target OR datetime is at or after the configured forced-exit time
Exit: short, high ≥ short stop OR low ≤ short target OR datetime is at or after the configured forced-exit time