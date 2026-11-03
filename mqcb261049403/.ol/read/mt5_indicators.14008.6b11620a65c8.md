Calculation: Smoothed price = a configurable smoothing of a configurable price derived from each higher-timeframe bar’s open, high, low, and close.
Calculation: Regression line = the least-squares linear regression of the latest smoothed prices over a configurable lookback, evaluated at a configurable point in that lookback.
Calculation: Trigger line = 2 × the current regression line − the regression line from a configurable number of bars earlier.
Long: Regression line > Trigger line (both calculated on the higher timeframe using its bar still forming)
Short: Regression line <= Trigger line (both calculated on the higher timeframe using its bar still forming)