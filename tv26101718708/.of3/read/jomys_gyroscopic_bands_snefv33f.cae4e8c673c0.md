Calculation: Trajectory = (nz(close[1]) - nz(close[2]) + nz(Trajectory[1]) * P1) / (P1 + 1)
Calculation: Gravity = 10^P2 / abs(close)
Calculation: Gyroscopic line = close while the count of bars with volume > -1 is at most P3; afterward, prior Gyroscopic line + Gravity + Trajectory if prior Gyroscopic line < close, otherwise prior Gyroscopic line - Gravity + Trajectory
Long: close > Gyroscopic line
Short: close < Gyroscopic line
Exit: long, close = Gyroscopic line
Exit: short, close = Gyroscopic line