Calculation: Kalman change = Kalman(applied price, smoothing parameter) - Kalman(applied price, smoothing parameter)[1]
Calculation: Kalman change standard deviation = standard deviation(Kalman change, lookback)
Calculation: Lower threshold = lower multiplier × Kalman change standard deviation
Calculation: Upper threshold = higher multiplier × Kalman change standard deviation
Long: Kalman change > Lower threshold AND Kalman change <= Upper threshold
Long: Kalman change > Upper threshold
Short: Kalman change < -Lower threshold AND Kalman change >= -Upper threshold
Short: Kalman change < -Upper threshold