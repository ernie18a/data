Long: latest Google Finance price > Google Finance price at the last quote timestamp at or before (current time - lookback) + BarSize
Short: latest Google Finance price < Google Finance price at the last quote timestamp at or before (current time - lookback) - BarSize
Calculation: quote delay = latest Google Finance quote timestamp - timestamp of the last Google Finance quote at or before (current time - lookback)
Exit: long, time since entry >= quote delay
Exit: short, time since entry >= quote delay