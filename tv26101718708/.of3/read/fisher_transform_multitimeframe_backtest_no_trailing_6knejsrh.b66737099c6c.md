Calculation: Fisher trend state = on chart bars, set to 1 when the raw Fisher Transform of the selected price source, lookback, and normalized price weight is greater than the current smoothed Fisher value and the change in rounded smoothed Fisher is nonnegative; set to -1 when the raw Fisher Transform is less than the current smoothed Fisher value and that change is nonpositive; otherwise retain the prior state; smoothed Fisher = 0.5 * (raw Fisher Transform + prior completed T1 smoothed Fisher); use the current still-forming T1 bar and prior completed T1 range, or current chart bar data when chart interval mode is selected
Long: Fisher trend state > 0
Short: Fisher trend state < 0
Long: Fisher trend state > Fisher trend state[1]
Short: Fisher trend state < Fisher trend state[1]
Long: datetime is within the configured inclusive backtest window AND Fisher trend state > Fisher trend state[1]
Short: datetime is within the configured inclusive backtest window AND Fisher trend state < Fisher trend state[1]