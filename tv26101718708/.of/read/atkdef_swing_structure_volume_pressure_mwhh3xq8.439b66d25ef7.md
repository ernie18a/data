Calculation: Swing period = ATR over a shorter lookback divided by the simple moving average of true range over a longer lookback, multiplied by a scaling parameter, rounded to the nearest integer, and clamped between minimum and maximum period parameters.
Calculation: Pressure balance = 100 × ((close − low) − (high − close)) / (high − low + a small positive constant).
Long: A pivot low is confirmed using the current swing period as both the left and right lookback.
Short: A pivot high is confirmed using the current swing period as both the left and right lookback.
Long: Pressure balance > a positive pressure threshold.
Short: Pressure balance <= the negative of the positive pressure threshold.