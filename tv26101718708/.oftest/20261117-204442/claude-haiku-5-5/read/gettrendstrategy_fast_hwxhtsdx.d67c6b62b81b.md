Calculation: trend close = close of the timeframe bar still forming at the current bar, aggregated from the data bars
Calculation: trend open = open of the timeframe bar still forming at the current bar, aggregated from the data bars
Long: crossover(trend close, trend open)
Short: crossunder(trend close, trend open)
Exit: long, crossunder(trend close, trend open)
Exit: short, crossover(trend close, trend open)