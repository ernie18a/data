Calculation: Regression center = value at the current bar of a least-squares polynomial fitted to the current close and a lookback of preceding closes, using bar offsets as the independent variable.
Calculation: Regression deviation = square root of the mean squared residual of the same polynomial fit, multiplied by a configurable factor.
Calculation: Regression upper = regression center + regression deviation.
Calculation: Regression lower = regression center - regression deviation.
Long: Current time is within the configured trading window AND the last completed daily bar's high minus low is at most the protection threshold AND current low <= regression lower AND position side is not long.
Short: Current time is within the configured trading window AND the last completed daily bar's high minus low is at most the protection threshold AND current low > regression lower AND current high >= regression center AND position side is not short.
Exit: long, current bid >= regression upper OR current time is within the configured trading window AND the last completed daily bar's high minus low > the protection threshold.
Exit: short, current bid <= regression upper OR current time is within the configured trading window AND the last completed daily bar's high minus low > the protection threshold.