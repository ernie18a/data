Calculation: Smoothed price-zone oscillator = JMA(100 × N / D, smoothing period, phase), using 0 when D = 0, where α = 2 / (period + 1), N[0] = 0, N = N[1] + α(sign(close − close[1]) × close − N[1]), D[0] = volume[0], D = D[1] + α(close − D[1]), and sign(x) = 1 if x > 0, −1 if x < 0, otherwise 0
Long: Smoothed price-zone oscillator > threshold
Short: Smoothed price-zone oscillator < threshold