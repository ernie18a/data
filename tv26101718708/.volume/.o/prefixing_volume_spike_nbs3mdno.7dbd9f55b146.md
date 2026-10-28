Calculation: Same-time volume average = mean of positive volumes from the prior lookback days, sampled at the same time of day on completed bars
Calculation: Spike ratio = current bar volume / same-time volume average
Long: bar time is within the configured pre-fixing window AND the optional date range is enabled or the bar is within it AND spike ratio ≥ mild threshold AND close > open
Short: bar time is within the configured pre-fixing window AND the optional date range is enabled or the bar is within it AND spike ratio ≥ mild threshold AND close < open