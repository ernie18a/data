Calculation: Selected price = configured price series derived from OHLC data.
Calculation: Trend bands = selected price’s configured moving average ± configured deviation multiplier × standard deviation of selected price; ratchet the upper band downward to its prior value during a downtrend and the lower band upward to its prior value during an uptrend.
Calculation: Trend state = up when selected price > previous upper trend band; down when selected price < previous lower trend band; otherwise retain the previous state. Use chart bars, or the still-forming bar of the configured higher timeframe when it exceeds the chart timeframe.
Long: Trend state = up AND previous trend state ≠ up
Short: Trend state = down AND previous trend state ≠ down