Calculation: Kalman estimate = previous estimate + (input price − previous estimate) × square root of smoothing coefficient + current Kalman velocity, where input price is the configured OHLC-derived price
Calculation: Kalman velocity = previous velocity + (input price − previous estimate) × smoothing coefficient
Long: Kalman mode and Kalman velocity > 0 OR Trend mode and current Kalman estimate >= previous Kalman estimate
Short: Kalman mode and Kalman velocity <= 0 OR Trend mode and current Kalman estimate < previous Kalman estimate
