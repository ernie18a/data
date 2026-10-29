Calculation: Fisher Transform = Normalize each bar’s high-low midpoint within the highest high and lowest low over a lookback; smooth that location recursively, clamp it to [-0.99, 0.99], apply ln((1+x)/(1-x)), then recursively smooth the result. For a higher-timeframe calculation, use the still-forming bar; otherwise use the chart timeframe.
Long: Fisher Transform > 0
Short: Fisher Transform < 0