Calculation: Displaced smoothed moving average = smoothed moving average of median price (high + low) / 2, shifted forward by the same configurable number of bars for both lookbacks; use the value at the current bar of a configurable timeframe, which may be higher or lower than or equal to the chart timeframe, using its still-forming bar.
Calculation: Profit distance = maximum of a configurable minimum price distance and the average high minus the average low over a configurable lookback of completed bars on a configurable timeframe, which may be higher or lower than or equal to the chart timeframe.
Long: Shorter-lookback displaced smoothed moving average > longer-lookback displaced smoothed moving average.
Short: Shorter-lookback displaced smoothed moving average < longer-lookback displaced smoothed moving average.
Exit: Long, current price > entry price + profit distance.
Exit: Short, current price < entry price - profit distance.