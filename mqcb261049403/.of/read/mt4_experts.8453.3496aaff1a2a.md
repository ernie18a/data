Calculation: support = lowest low over the lookback window of completed bars on a lower timeframe than the chart timeframe
Calculation: resistance = highest high over the lookback window of completed bars on a lower timeframe than the chart timeframe
Calculation: EMA of open = exponential moving average of open prices over the lookback window on the chart timeframe, including the bar still forming
Long: chart bar open > EMA of open AND current price > resistance
Short: chart bar open < EMA of open AND current price < support
Exit: long, current price <= support OR (position is profitable AND current price < support)
Exit: short, current price >= resistance OR (position is profitable AND current price > resistance)