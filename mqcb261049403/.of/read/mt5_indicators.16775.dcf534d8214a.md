Calculation: Median price = (high + low) / 2; moving average = Hull moving average of median price
Calculation: Average true range = simple average of max(high, previous close) - min(low, previous close) over its lookback
Calculation: Raw upper/lower bands = moving average ± multiplier × average true range. On each bar, carry the prior trend state; set it bullish if close > prior upper band, or bearish if close < prior lower band. The lower band is the maximum of its raw value and prior lower band while bullish; otherwise use its raw value. The upper band is the minimum of its raw value and prior upper band while bearish; otherwise use its raw value.
Long: close > prior upper band
Short: close < prior lower band