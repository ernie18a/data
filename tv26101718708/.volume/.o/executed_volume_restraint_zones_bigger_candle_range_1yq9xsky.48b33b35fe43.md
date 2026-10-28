Calculation: Relative volume = volume / simple moving average of volume
Calculation: Body fraction = abs(close - open) / (high - low), or 0 if high = low
Calculation: Upper-wick fraction = (high - max(open, close)) / (high - low), or 0 if high = low
Calculation: Lower-wick fraction = (min(open, close) - low) / (high - low), or 0 if high = low
Long: volume > minimum actual volume AND relative volume >= high-volume threshold AND lower-wick fraction >= minimum wick fraction AND (body fraction <= maximum body fraction OR lower-wick fraction >= strong-wick threshold)
Short: volume > minimum actual volume AND relative volume >= high-volume threshold AND upper-wick fraction >= minimum wick fraction AND (body fraction <= maximum body fraction OR upper-wick fraction >= strong-wick threshold)