Calculation: Williams %R = -100 × (lookback highest high − close) ÷ (lookback highest high − lookback lowest low)
Calculation: CEEMDAN-Kalman %R = apply a recursive Kalman filter to %R calculated from the 8-bar simple moving average of close, using that average ± true range as the high and low; use a 20-bar variance of the unfiltered %R as measurement noise, process noise 2, and initial state −50
Calculation: Jurik-smoothed Williams %R = Jurik moving average of Williams %R, using the same lookback
Long: Williams %R > its prior-bar value OR CEEMDAN-Kalman %R > its prior-bar value OR Jurik-smoothed Williams %R > its prior-bar value
Short: Williams %R ≤ its prior-bar value OR CEEMDAN-Kalman %R ≤ its prior-bar value OR Jurik-smoothed Williams %R ≤ its prior-bar value