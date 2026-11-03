Calculation: Trigger main line = least-squares linear-regression value projected to the latest bar, calculated from the selected applied price over a lookback.
Calculation: Trigger signal line = exponential moving average of the Trigger main line, with a shorter smoothing period than the main line’s lookback.
Long: On the configured indicator timeframe (higher or lower than the chart timeframe), using consecutive completed bars, Trigger main line crosses above Trigger signal line.
Short: On the configured indicator timeframe (higher or lower than the chart timeframe), using consecutive completed bars, Trigger main line crosses below Trigger signal line.
Exit: Long, on the configured indicator timeframe using consecutive completed bars, Trigger main line crosses below Trigger signal line.
Exit: Short, on the configured indicator timeframe using consecutive completed bars, Trigger main line crosses above Trigger signal line.