Calculation: Smoothed applied price = a selected OHLC-derived price smoothed by a selected averaging method; the smoothing and regression use the same lookback.
Calculation: Linear-regression forecast = least-squares regression of the smoothed applied price over the lookback, evaluated at the lookback end minus the trigger offset; on the selected higher timeframe, use the bar still forming.
Calculation: Trigger line = twice the current linear-regression forecast minus its value the trigger offset of bars earlier.
Long: Linear-regression forecast < Trigger line
Short: Linear-regression forecast > Trigger line