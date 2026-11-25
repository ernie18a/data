Calculation: K = Kalman filter(applied price, smoothing parameter, on T1 bars, last completed bar)
Long: K >= K[1] AND K[1] > K[2]
Short: K < K[1] AND K[1] <= K[2]