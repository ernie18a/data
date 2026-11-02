Calculation: Timeframe votes = for each of five configured timeframes ordered from shortest to longest, assign the close-versus-EMA vote +1 when close > EMA(close), -1 when close < EMA(close), and 0 otherwise; assign the RSI vote +1 when RSI(close) > EMA(RSI(close)), -1 when RSI(close) < EMA(RSI(close)), and 0 otherwise. For a higher timeframe use the last completed bar; for a lower timeframe use the last completed intrabar within the chart bar; for the chart timeframe use the current bar.
Calculation: Raw score = sum of the two votes for a timeframe.
Calculation: Weighted score = score scale multiplied by the sum of each timeframe's raw score times its nonnegative weight, divided by the sum of the weights.
Calculation: Effective threshold = signal threshold multiplied by the volume multiplier if the optional volume filter is enabled AND chart-bar volume <= SMA(volume); otherwise the signal threshold.
Long: Close > EMA(close) OR RSI(close) > EMA(RSI(close)), on any configured timeframe.
Short: Close < EMA(close) OR RSI(close) < EMA(RSI(close)), on any configured timeframe.
Long: Weighted score > 0.
Short: Weighted score < 0.
Long: Weighted score > effective threshold AND previous chart bar's weighted score <= its effective threshold.
Short: Weighted score < -effective threshold AND previous chart bar's weighted score >= its negative effective threshold.