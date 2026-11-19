Calculation: upper boundary = maximum of the latest pivot-count PivotHigh(high, pivot lookback, pivot lookback) values
Calculation: lower boundary = minimum of the latest pivot-count PivotLow(low, pivot lookback, pivot lookback) values
Calculation: equilibrium line = (upper boundary + lower boundary) / 2 when both boundaries exist
Long: equilibrium line > equilibrium line[1]
Short: equilibrium line < equilibrium line[1]
Long: crossunder((high + low) / 2, lower boundary[1]) AND the chart bar is confirmed AND chart bar index minus signal-buffer index > signal cooldown
Short: crossover((high + low) / 2, upper boundary[1]) AND the chart bar is confirmed AND chart bar index minus signal-buffer index > signal cooldown