Calculation: Kalman velocity and variance = On each completed chart bar, set y = 100 × ln(max(source price, 10^-20)). Initialize position x = y, velocity v = 0, and covariance entries a = 1, b = 0, c = 1 on the first bar, then perform the update on that same bar. For each update, predict X = x + v, A = a + 2b + c + Q, B = b + c, C = c + Q; calculate gains g1 = A / (A + R), g2 = B / (A + R), and innovation e = y - X. Update x = X + g1 × e, v = v + g2 × e, a = (1 - g1) × A, b = (1 - g1) × B, c = C - g2 × B. Q and R are process and measurement noise parameters.
Calculation: Significance bounds = lower bound v - k × sqrt(max(c, 10^-10)) and upper bound v + k × sqrt(max(c, 10^-10)), where k is a sigma multiplier.
Long: Kalman velocity > 0
Short: Kalman velocity < 0
Long: lower significance bound > 0
Short: upper significance bound < 0
Long: lower significance bound was > 0 a confirmation-delay number of bars ago AND its preceding value was <= 0 AND the number of bars since the previous long significance-cross signal is >= the signal spacing parameter or no such signal has occurred
Short: upper significance bound was < 0 a confirmation-delay number of bars ago AND its preceding value was >= 0 AND the number of bars since the previous short significance-cross signal is >= the signal spacing parameter or no such signal has occurred
Exit: long, previous lower significance bound > 0 AND current lower significance bound <= 0 AND current upper significance bound >= 0
Exit: short, previous upper significance bound < 0 AND current lower significance bound <= 0 AND current upper significance bound >= 0