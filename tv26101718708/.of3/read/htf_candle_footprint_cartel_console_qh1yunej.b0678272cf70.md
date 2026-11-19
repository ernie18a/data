Calculation: T1 bias open = open of the most recently completed T1 candle, or the current forming T1 candle’s open before a T1 candle has completed
Calculation: analysis bars = chart bars from the previous T1 candle’s start through the current chart bar, or from the current T1 candle’s start if no previous T1 candle exists
Calculation: bin geometry = divide the range from the minimum low to the maximum high of the analysis bars into max(1, ceil(range / max(ATR(chart bars, lookback) × scale, minimum tick))) equal bins; each bin midpoint is half a bin step above its low
Calculation: binned volume delta = for each bin, sum the volume of analysis bars whose close is above their open and subtract the volume of those whose close is below their open, including a bar when the absolute difference between its close and the bin midpoint is at most one bin step
Calculation: candle body bounds = the lower and upper values of T1 bias open and current chart close
Long: current chart close > T1 bias open OR (bin midpoint is within candle body bounds AND binned volume delta > 0)
Short: current chart close <= T1 bias open OR (bin midpoint is within candle body bounds AND binned volume delta < 0)