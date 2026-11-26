Calculation: ChartDerivative = selected smoothing method(100 * (selected applied price(open, high, low, close) - selected applied price(open, high, low, close)[chart slowing lookback]) / chart slowing lookback, chart smoothing lookback, chart smoothing phase) on chart bars
Long: ChartDerivative > 0
Short: ChartDerivative < 0
Calculation: T1Derivative = selected smoothing method(100 * (selected applied price(open, high, low, close) - selected applied price(open, high, low, close)[T1 slowing lookback]) / T1 slowing lookback, T1 smoothing lookback, T1 smoothing phase) on T1 bars using the bar still forming, with values read on chart bars
Long: T1Derivative > 0
Short: T1Derivative < 0